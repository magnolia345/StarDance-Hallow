extends CharacterBody3D


const JUMP_VELOCITY = 5
const sensitivity = 0.002
const stamina = 10
const stop_time = 2
const BOB_FREQ: float = 3
const BOB_AMP: float = 0.3
var SPEED = 10
var stamina_level = 10
var stamina_increment = 1
var time = 5
var head_bop = 0
var key = null
var crouch = 0
var jump = 0
var t_bob: float = 0.0
var resistance = 1
var checkx = true
var checky = true
var door = null


@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var progress = $CanvasLayer/Stamina
@onready var flashlight = $Head/Camera3D/SpotLight

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	show()
	progress.position = Vector2(250, 0)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, 
			deg_to_rad(-30), deg_to_rad(60))
		
func _physics_process(delta: float) -> void:
	crouching()
	if Input.is_key_pressed(KEY_SHIFT) and stamina_level > 0:
		SPEED = 20
		time = 0
		if key == 1:
			stamina_level -= stamina_increment * delta
			progress.show()
	else:
		SPEED = 10
		time += 1 * delta
		if stamina_level < stamina and time > stop_time:
			stamina_level += stamina_increment * delta
			progress.show()
		else:
			if stamina_level == stamina:
				progress.hide()
			else:
				progress.show()
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_key_pressed(KEY_TAB):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if not is_on_floor():
		velocity += get_gravity() * delta
		jump = 1
	else:
		jump = 0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and crouch == 0:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * resistance
		velocity.z = direction.z * SPEED * resistance
		key = 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		key = 0
	if position.y < -150:
		reset()

	move_and_slide()
	progress.value = stamina_level
	if is_on_floor and velocity.length() > 0.0 and crouch == 0:
		t_bob += delta * velocity.length() * BOB_AMP
		var pos: Vector3 = Vector3.ZERO
		if checky:
			pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP
		if checkx:
			pos.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP
		camera.transform.origin = pos
	else:
		t_bob = 0
		camera.transform.origin = camera.transform.origin.lerp(Vector3.ZERO, delta * 10.0)
func reset():
	position = Vector3(0, 0.6, 0)
func crouching():
	if Input.is_key_pressed(KEY_C) and is_on_floor():
		camera.position.y = 0
		crouch = 1
		#Move slower
		resistance = 0.5
	else:
		crouch = 0
		resistance = 1
