extends CharacterBody3D

enum State { WANDER, CHASE, SEARCH }

@export var wander_speed := 5.0
@export var chase_speed := 20.0
@export var wander_radius := 1000.0

@export var view_distance := 150.0
@export var view_angle := 360.0
@export var close_range := 2.0

@export var stop_distance := 3.5
@export var chase_repath_distance := 2.0

@export var search_duration := 5.0
@export var chase_memory := 7.0
@export var search_radius := 30.0
# attack stuff
@export var attack_range := 4.0
@export var attack_cooldown := 1.2
@export var detection_cooldown := 1.5

# Movement smoothing
@export var acceleration := 15.0
@export var turn_speed := 10.0

# Stuck recovery
@export var stuck_timeout := 1.5

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var eyes: Node3D = $Eyes

var state: State = State.WANDER
var player: Node3D

var navigation_ready := false
var current_path := PackedVector3Array()
var path_index := 0

var retry_timer := 0.0
var memory_timer := 0.0
var attack_timer := 0.0
var cooldown_timer := 0.0
var vision_timer := 0.0
var search_timer := 0.0

var last_known_position := Vector3.ZERO

var has_chase_target := false
var last_chase_target := Vector3.ZERO

var stuck_timer := 0.0
var progress_check_timer := 0.0
var last_check_position := Vector3.ZERO
var debug = true
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node3D
	print("Enemy target: ", player.get_path())
	
	nav_agent.avoidance_enabled = false

	call_deferred("_initialize_navigation")


func _initialize_navigation() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame

	var map_id := nav_agent.get_navigation_map()

	if NavigationServer3D.map_get_regions(map_id).is_empty():
		push_error("Enemy: No navigation regions found!")
		return

	navigation_ready = true
	last_check_position = global_position


	_pick_random_destination()


# main looping heree
# --------------------------------------------------

func _physics_process(delta: float) -> void:
	if not navigation_ready:
		_stop_horizontal()
		move_and_slide()
		return

	if cooldown_timer > 0.0:
		cooldown_timer = maxf(0.0, cooldown_timer - delta)
	if attack_timer > 0.0:
		attack_timer -= delta
		
	# Check vision approximately every 0.15 seconds.
	vision_timer += delta

	if vision_timer >= 0.15:
		vision_timer = 0.0
		_check_vision()

	# Brief pause when recovering from a failed path.
	if retry_timer > 0.0:
		retry_timer = maxf(0.0, retry_timer - delta)
		_smooth_stop(delta)
		move_and_slide()
		return

	match state:
		State.WANDER:
			if _path_finished():
				_pick_random_destination()

		State.CHASE:
			_update_chase_target()
			_try_attack()
			
		State.SEARCH:
			if memory_timer > 0.0:
				memory_timer -= delta
				last_known_position = player.global_position
				_update_chase_target()
			else:
				search_timer -= delta

				if search_timer <= 0.0:
					_change_state(State.WANDER)
				elif _path_finished():
					var offset := Vector3(
						randf_range(-search_radius, search_radius),
						0.0,
						randf_range(-search_radius, search_radius)
					)
					_calculate_path(last_known_position + offset)

	_move_along_path(delta)


# --------------------------------------------------
# VISION
# --------------------------------------------------

func _check_vision() -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D

	if not is_instance_valid(player):
		return

	if cooldown_timer > 0.0:
		return

	var visible := _can_see_player()
	if debug:
	# DEBUG: shows whether vision is working and the enemy's current state.
		print("State: ", State.keys()[state],
			" | Can see player: ", visible,
			" | Distance: ", global_position.distance_to(player.global_position))
		print("Enemy: ", global_position, " | Eyes: ", eyes.global_position, " | Player: ", player.global_position)
	
	match state:
		State.WANDER:
			if visible:
				_change_state(State.CHASE)

		State.CHASE:
			if not visible:
				_change_state(State.SEARCH)

		State.SEARCH:
			if visible:
				_change_state(State.CHASE)


func _can_see_player() -> bool:
	if not is_instance_valid(player):
		return false

	var to_player := player.global_position - eyes.global_position
	var distance_to_player := to_player.length()

	if distance_to_player > view_distance:
		return false

	if distance_to_player < close_range:
		return true

	# A 360-degree angle allows vision in every direction.
	# Smaller values create a forward-facing vision cone.
	var forward := -eyes.global_transform.basis.z

	var flat_forward := Vector3(forward.x, 0.0, forward.z)
	var flat_to_player := Vector3(to_player.x, 0.0, to_player.z)

	if flat_forward.length_squared() > 0.001:
		if flat_to_player.length_squared() > 0.001:
			var angle := rad_to_deg(
				flat_forward.normalized().signed_angle_to(
					flat_to_player.normalized(),
					Vector3.UP
				)
			)

			if absf(angle) > view_angle * 0.5:
				return false

	# Walls block the enemy's line of sight.
	var query := PhysicsRayQueryParameters3D.create(
		eyes.global_position,
		player.global_position + Vector3.UP
	)

	query.exclude = [self]

	var result := get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		return false

	var collider = result.get("collider")
	if debug:
		print("Ray hit: ", collider.name)
	return is_instance_valid(collider) and collider.is_in_group("player")


# --------------------------------------------------
# CHASE
# --------------------------------------------------

func _update_chase_target() -> void:
	if not is_instance_valid(player):
		_change_state(State.WANDER)
		return

	var to_player := player.global_position - global_position
	to_player.y = 0.0

	# Stop when close enough to the player.
	if to_player.length() <= stop_distance:
		current_path.clear()
		path_index = 0
		has_chase_target = false
		return

	var destination := _closest_navigation_point(
		player.global_position
	)

	var should_repath := (
		not has_chase_target
		or destination.distance_to(last_chase_target)
			>= chase_repath_distance
	)

	# Also recalculate when we've reached the end of a path
	# but the player is still too far away.
	if _path_finished() and to_player.length() > stop_distance + 0.5:
		should_repath = true

	if not should_repath:
		return

	if _calculate_path(destination):
		last_chase_target = destination
		has_chase_target = true
		if debug:
			print("CHASE PATH FOUND: ", destination)
	else:
		current_path.clear()
		path_index = 0
		has_chase_target = false
		retry_timer = 0.25
		if debug:
			print("CHASE PATH FAILED: ", destination)

func _try_attack() -> void:
	if attack_timer > 0.0 or not is_instance_valid(player):
		return

	var to_player := player.global_position - global_position
	to_player.y = 0.0

	if to_player.length() <= attack_range and player.has_method("take_hit"):
		player.take_hit()
		attack_timer = attack_cooldown

# --------------------------------------------------
# SEARCH
# --------------------------------------------------

func _enter_search() -> void:
	if is_instance_valid(player):
		last_known_position = player.global_position
	else:
		last_known_position = global_position

	search_timer = search_duration
	memory_timer = chase_memory
	current_path.clear()
	path_index = 0

	_calculate_path(
		_closest_navigation_point(last_known_position)
	)


# --------------------------------------------------
# STATE CHANGES
# --------------------------------------------------

func _change_state(new_state: State) -> void:
	if state == new_state:
		return

	state = new_state

	match state:
		State.WANDER:
			cooldown_timer = detection_cooldown
			has_chase_target = false
			_pick_random_destination()

		State.CHASE:
			cooldown_timer = 0.0
			has_chase_target = false
			current_path.clear()
			path_index = 0

		State.SEARCH:
			cooldown_timer = 0.0
			has_chase_target = false
			_enter_search()


# --------------------------------------------------
# RANDOM NAVIGATION
# --------------------------------------------------


func _pick_random_destination(escape: bool = false) -> void:
	var map_id := nav_agent.get_navigation_map()

	var start_point := NavigationServer3D.map_get_closest_point(
		map_id,
		global_position
	)

	current_path.clear()
	path_index = 0

	var search_radius := wander_radius

	if escape:
		search_radius *= 2.5
		if debug:
			print("Enemy stuck! Finding another destination.")

	var best_path := PackedVector3Array()
	var best_distance := 0.0

	for attempt in range(40):
		var destination := NavigationServer3D.map_get_random_point(
			map_id,
			nav_agent.navigation_layers,
			false
		)
		var distance := start_point.distance_to(destination)

		if distance < 10.0 or distance > wander_radius:
			continue

		var candidate_path: PackedVector3Array = NavigationServer3D.map_get_path(
			map_id,
			start_point,
			destination,
			true,
			nav_agent.navigation_layers
		)

		if candidate_path.size() < 2:
			continue

		best_distance = distance
		best_path = candidate_path
		break

	if best_path.size() >= 2:
		current_path = best_path
		path_index = 1
		stuck_timer = 0.0
		progress_check_timer = 0.0
		last_check_position = global_position
		if debug:
			print("Wander destination distance: ", best_distance)
	else:
		current_path.clear()
		path_index = 0
		retry_timer = 0.5
		if debug:
			print("WANDER FAILED: no suitable destination found.")


func _calculate_path(destination: Vector3) -> bool:
	var map_id := nav_agent.get_navigation_map()

	var start_point := NavigationServer3D.map_get_closest_point(
		map_id,
		global_position
	)

	var end_point := _closest_navigation_point(destination)

	var new_path: PackedVector3Array = NavigationServer3D.map_get_path(
		map_id,
		start_point,
		end_point,
		true,
		nav_agent.navigation_layers
	)

	if new_path.size() < 2:
		return false

	current_path = new_path
	path_index = 1

	stuck_timer = 0.0
	progress_check_timer = 0.0
	last_check_position = global_position

	return true


func _closest_navigation_point(point: Vector3) -> Vector3:
	return NavigationServer3D.map_get_closest_point(
		nav_agent.get_navigation_map(),
		point
	)


func _path_finished() -> bool:
	return current_path.is_empty() or path_index >= current_path.size()


# --------------------------------------------------
# MOVEMENT
# --------------------------------------------------

func _move_along_path(delta: float) -> void:
	# If chasing and already close, stop and face the player.
	if state == State.CHASE and is_instance_valid(player):
		var to_player := player.global_position - global_position
		to_player.y = 0.0

		if to_player.length() <= stop_distance:
			_stop_horizontal()
			_turn_toward(to_player, delta)
			move_and_slide()
			return

	# No route currently available.
	if _path_finished():
		_smooth_stop(delta)
		move_and_slide()
		return

	# Skip waypoints already reached.
	while path_index < current_path.size():
		var offset := current_path[path_index] - global_position
		offset.y = 0.0

		if offset.length() < 0.6:
			path_index += 1
		else:
			break

	if _path_finished():
		_smooth_stop(delta)
		move_and_slide()
		return

	var next_point := current_path[path_index]
	var direction := next_point - global_position
	direction.y = 0.0

	if direction.length_squared() > 0.01:
		direction = direction.normalized()

		var speed := wander_speed

		if state == State.CHASE or state == State.SEARCH:
			speed = chase_speed

		# Gradually change velocity rather than snapping instantly.
		var desired_velocity := direction * speed

		velocity.x = move_toward(
			velocity.x,
			desired_velocity.x,
			acceleration * delta
		)

		velocity.z = move_toward(
			velocity.z,
			desired_velocity.z,
			acceleration * delta
		)

		_turn_toward(direction, delta)
	else:
		_smooth_stop(delta)

	move_and_slide()
	_check_if_stuck(delta)


func _turn_toward(direction: Vector3, delta: float) -> void:
	direction.y = 0.0

	if direction.length_squared() < 0.001:
		return

	var target_yaw := atan2(-direction.x, -direction.z)

	global_rotation.y = lerp_angle(
		global_rotation.y,
		target_yaw,
		minf(turn_speed * delta, 1.0)
	)


func _smooth_stop(delta: float) -> void:
	velocity.x = move_toward(
		velocity.x,
		0.0,
		acceleration * delta
	)

	velocity.z = move_toward(
		velocity.z,
		0.0,
		acceleration * delta
	)


func _stop_horizontal() -> void:
	velocity.x = 0.0
	velocity.z = 0.0


# --------------------------------------------------
# STUCK RECOVERY
# --------------------------------------------------

func _check_if_stuck(delta: float) -> void:
	if _path_finished():
		stuck_timer = 0.0
		progress_check_timer = 0.0
		last_check_position = global_position
		return

	progress_check_timer += delta

	if progress_check_timer < 0.4:
		return

	var movement := Vector2(
		global_position.x - last_check_position.x,
		global_position.z - last_check_position.z
	).length()

	if movement < 0.15:
		stuck_timer += progress_check_timer
	else:
		stuck_timer = 0.0

	last_check_position = global_position
	progress_check_timer = 0.0

	if stuck_timer >= stuck_timeout:
		stuck_timer = 0.0

		if state == State.WANDER:
			_pick_random_destination(true)

		elif state == State.CHASE:
			# Clear the old route and try calculating a new one.
			current_path.clear()
			path_index = 0
			has_chase_target = false

		elif state == State.SEARCH:
			_enter_search()
