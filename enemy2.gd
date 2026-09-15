extends CharacterBody3D

enum State { WANDER, CHASE, SEARCH }

@export var wander_speed := 10.0
@export var chase_speed := 20.0
@export var view_distance := 150.0
@export var view_angle := 360.0  # degrees, half-angle each side
@export var wander_radius := 10.0
@export var search_duration := 5.0
@export var detection_cooldown := 1.5  # grace period after losing player
@export var close_range := 2.0  # inside this distance, vision auto-succeeds
@export var stop_distance := 1.5  # how close chase is allowed to get before holding

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var eyes: Node3D = $Eyes
@onready var vision_check_timer: Timer = $VisionCheckTimer

var state: State = State.WANDER
var player: Node3D
var last_known_position: Vector3
var search_timer := 0.0
var cooldown_timer := 0.0
var can_see_player := false

const DEBUG := true  # flip to true if you need the old verbose prints back


func _ready():
	player = get_tree().get_first_node_in_group("player")

	# --- IMPORTANT, DO THIS IN THE EDITOR ---
	# This enemy's collision_layer/collision_mask must NOT include the
	# player's physics layer. Otherwise move_and_slide() treats the player
	# like a wall and the enemy will shove/wedge against them instead of
	# stopping cleanly at stop_distance. Detection still works fine without
	# this layer overlap because vision uses a manual raycast, not physics
	# contact.

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
	if not player or cooldown_timer > 0:
		return

	can_see_player = _can_see_player()

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
		return false

	var to_player = player.global_position - eyes.global_position
	var dist = to_player.length()
	if dist > view_distance:
		return false

	# Point-blank range: skip angle/raycast, the enemy is basically on top
	# of the player, so line-of-sight checks are unreliable/meaningless here.
	if dist < close_range:
		return true

	var angle = rad_to_deg(eyes.global_transform.basis.z.signed_angle_to(to_player.normalized(), Vector3.UP))
	if abs(angle) > view_angle:
		return false

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		eyes.global_position,
		player.global_position + Vector3(0, 1.0, 0)
	)
	query.exclude = [self]
	query.collision_mask = 0xFFFFFFFF
	var result = space_state.intersect_ray(query)

	if DEBUG:
		print("ray result: ", result)

	return result and result.collider.is_in_group("player")


# ---------------- STATE BEHAVIOR ----------------

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
	var to_player = player.global_position - global_position
	# Don't keep re-targeting the player's exact position once we're
	# already close — that's what caused the wedge-into-wall bug.
	if to_player.length() > stop_distance:
		nav_agent.target_position = player.global_position


func _enter_search():
	last_known_position = player.global_position
	nav_agent.target_position = last_known_position
	search_timer = search_duration


func _search(delta):
	nav_agent.max_speed = chase_speed
	if nav_agent.is_navigation_finished():
		search_timer -= delta
		rotate_y(deg_to_rad(60) * delta)
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
			# Close enough that the navmesh says "arrived" - hold position,
			# just face the player. NEVER drive straight-line velocity here;
			# that ignores walls entirely and is what caused the enemy to
			# ram geometry and get permanently stuck off the navmesh.
			var to_player = player.global_position - global_position
			to_player.y = 0
			if to_player.length() > 0.1:
				look_at(global_position + to_player.normalized(), Vector3.UP)
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
