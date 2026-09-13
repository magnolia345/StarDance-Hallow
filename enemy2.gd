extends CharacterBody3D

enum State { WANDER, CHASE, SEARCH }

@export var wander_speed := 10.0
@export var chase_speed := 20
@export var view_distance := 150.0
@export var view_angle := 360.0  # degrees, half-angle each side
@export var wander_radius := 10.0
@export var search_duration := 5.0
@export var detection_cooldown := 1.5  # grace period after losing player

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var eyes: Node3D = $Eyes  # empty node at "head" height
@onready var vision_check_timer: Timer = $VisionCheckTimer

var state: State = State.WANDER
var player: Node3D
var last_known_position: Vector3
var search_timer := 0.0
var cooldown_timer := 0.0
var can_see_player := false

func _ready():

	player = get_tree().get_first_node_in_group("player")
	print("Player found: ", player)
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	vision_check_timer.timeout.connect(_check_vision)
	vision_check_timer.wait_time = 0.15
	vision_check_timer.start()
	_pick_new_wander_point()

func _physics_process(delta):

	if cooldown_timer > 0:
		cooldown_timer -= delta

	match state:
		State.WANDER:
			_wander()
		State.CHASE:
			_chase()
		State.SEARCH:
			_search(delta)

	_move_along_path()

# ---------------- VISION ----------------

func _check_vision():
	print("enemy body pos: ", global_position, " | eyes pos: ", eyes.global_position, " | player pos: ", player.global_position)
	if not player or cooldown_timer > 0:
		print("blocked by: no player or cooldown (cooldown=", cooldown_timer, ")")
		return false

	print("eyes pos: ", eyes.global_position, " | player pos: ", player.global_position)  # <-- goes here

	var to_player = player.global_position - eyes.global_position
	can_see_player = _can_see_player()
	print(can_see_player)
	match state:
		State.WANDER:
			if can_see_player:
				_change_state(State.CHASE)
		State.CHASE:
			if not can_see_player:
				_change_state(State.SEARCH)
		State.SEARCH:
			if can_see_player:
				_change_state(State.CHASE)


func _can_see_player() -> bool:
	if not player or cooldown_timer > 0:
		print("blocked by: no player or cooldown (cooldown=", cooldown_timer, ")")
		return false

	print("eyes pos: ", eyes.global_position, " | player pos: ", player.global_position)

	# --- floor test ---
	var space_state = get_world_3d().direct_space_state
	var test_query = PhysicsRayQueryParameters3D.create(eyes.global_position, eyes.global_position + Vector3(0, -20, 0))
	var test_result = space_state.intersect_ray(test_query)
	print("floor test: ", test_result)
	# --- end floor test ---

	var to_player = player.global_position - eyes.global_position
	var dist = to_player.length()
	print("dist: ", dist, " (max: ", view_distance, ")")
	if dist > view_distance:
		print("too far")
		return false

	var angle = rad_to_deg(eyes.global_transform.basis.z.signed_angle_to(to_player.normalized(), Vector3.UP))
	print("angle: ", angle, " (max: ", view_angle, ")")
	if abs(angle) > view_angle:
		print("outside FOV")
		return false

	var space_state2 = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(eyes.global_position, player.global_position)
	query.exclude = [self]
	query.collision_mask = 0xFFFFFFFF
	var result = space_state2.intersect_ray(query)
	print("ray result: ", result)

	return result and result.collider.is_in_group("player")
# ---------------- STATES ----------------

func _wander():
	nav_agent.max_speed = wander_speed
	if nav_agent.is_navigation_finished():
		_pick_new_wander_point()

func _pick_new_wander_point():
	var random_point = global_position + Vector3(
		randf_range(-wander_radius, wander_radius),
		0,
		randf_range(-wander_radius, wander_radius)
	)
	nav_agent.target_position = random_point

func _chase():
	nav_agent.max_speed = chase_speed
	nav_agent.target_position = player.global_position

func _enter_search():
	last_known_position = player.global_position
	nav_agent.target_position = last_known_position
	search_timer = search_duration

func _search(delta):
	nav_agent.max_speed = chase_speed
	if nav_agent.is_navigation_finished():
		search_timer -= delta
		rotate_y(deg_to_rad(60) * delta)  # scan around while standing at last known spot
		if search_timer <= 0:
			_change_state(State.WANDER)

# ---------------- STATE SWITCHING ----------------

func _change_state(new_state: State):
	state = new_state
	match new_state:
		State.SEARCH:
			_enter_search()
			cooldown_timer = 0.0
		State.WANDER:
			_pick_new_wander_point()
			cooldown_timer = detection_cooldown
		State.CHASE:
			pass

# ---------------- MOVEMENT ----------------

func _move_along_path():
	if nav_agent.is_navigation_finished():
		if state == State.CHASE:
			# still close to player but path considered "done" - face and hold or nudge forward
			var to_player = player.global_position - global_position
			to_player.y = 0
			if to_player.length() > 0.1:
				velocity = to_player.normalized() * nav_agent.max_speed
				look_at(global_position + to_player.normalized(), Vector3.UP)
			else:
				velocity = Vector3.ZERO
			move_and_slide()
			return
		velocity = Vector3.ZERO
		move_and_slide()
		return

	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position)
	direction.y = 0
	direction = direction.normalized()

	velocity = direction * nav_agent.max_speed
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)

	move_and_slide()

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()
