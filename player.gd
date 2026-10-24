extends CharacterBody3D

# this is for attacks/respawn
@export var max_hits := 5
var hits_taken := 0
var blood_tween: Tween
var spawn_transform: Transform3D
var dead := false
@onready var blood_screen: CanvasItem = $CanvasLayer/ImageForGodot
#-----

const JUMP_VELOCITY = 8
const sensitivity = 0.003
const stamina = 6
const stop_time = 2
const BOB_FREQ: float = 3
const BOB_AMP: float = 0.3
var SPEED = 3
var stamina_level = 6
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
var debug = false
var held = null
var inventory = []
var cam_height = 1.6
var current_bob = Vector3.ZERO
@onready var ray = $Head/Camera3D/RayCast3D
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var progress = $CanvasLayer/Stamina
@onready var flashlight = $Head/Camera3D/SpotLight3D
@onready var tools = $"../tools"
@onready var hand = $Head/Camera3D/Hand
@onready var text = $CanvasLayer/TextEdit
@onready var dialogue = $CanvasLayer/Dialogue
var dialogue_id := 0
var hovering := false
var message_active := false
var held_object = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spawn_transform = global_transform
	progress.position = Vector2(250, 0)
func help(event):
	if event is InputEventKey:
		if false:
			print("key pressed: ", event.keycode)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, 
			deg_to_rad(-70), deg_to_rad(60))
		
func _physics_process(delta: float) -> void:
	if dead:
		return
	crouching(delta)
	if Input.is_key_pressed(KEY_SHIFT) and stamina_level > 0 and crouch == 0:
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
	
	var target = ray.get_collider()
	var looked = _find_interactable(target)
	if looked and not looked.solved and not message_active:
		dialogue.text = looked.ask_text
		dialogue.show()
		hovering = true
	elif hovering and not message_active:
		dialogue.hide()
		hovering = false
	if Input.is_action_just_pressed("interact"):
		var interactable = _find_interactable(target)
		if interactable:
			interactable.puzzle_interact(self)
		elif held_object:
			drop()
		elif ray.is_colliding():
			if target is RigidBody3D:
				held_object = target
				for r in get_tree().get_nodes_in_group("follow"):
					if r.get_node_or_null(r.remote_path) == target:
						r.remote_path = NodePath()
				target.freeze = true
				set_collision_all(target, false)
				add_collision_exception_with(target)
				ray.add_exception(target)
		raycast()
	progress.value = stamina_level
	var bob = Vector3.ZERO
	if is_on_floor() and velocity.length() > 0.0 and crouch == 0:
		t_bob += delta * velocity.length() * BOB_AMP
		if checky:
			bob.y = sin(t_bob * BOB_FREQ) * BOB_AMP
		if checkx:
			bob.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP
	else:
		t_bob = 0
	current_bob = current_bob.lerp(bob, delta * 10.0)
	camera.position = Vector3(0, cam_height, 0) + current_bob

	if held_object:
		var original_scale = held_object.get_parent().global_basis.get_scale()
		held_object.global_transform = Transform3D(hand.global_basis.orthonormalized().scaled_local(original_scale), hand.global_position)
		
func reset():
	position = Vector3(50, 2, 4)
func crouching(delta):
	var target_height = 1.6
	if Input.is_key_pressed(KEY_C) and is_on_floor():
		crouch = 1
		resistance = 0.5
		target_height = -2
	else:
		crouch = 0
		resistance = 1
	cam_height = lerp(cam_height, float(target_height), delta * 10.0)
func raycast():
	if ray.is_colliding():
		var collider = ray.get_collider()
		
		var final_name = collider.name # Fallback default
		
		# 1. If it hits a generic StaticBody, try to use the parent
		if collider is RigidBody3D or StaticBody3D :
			var parent = collider.get_parent()
			# Don't let it print the root scene name "main"
			if parent != null and parent.name != "main":
				final_name = parent.name
			else:
				# If the parent IS main, use the mesh name or the collider itself
				final_name = collider.name
		print(final_name)
		return collider
func set_collision_all(node, on):
	if node is CollisionObject3D:
		node.collision_layer = 1 if on else 0
		node.collision_mask = 1 if on else 0
	for child in node.get_children():
		set_collision_all(child, on)	
func drop():
	set_collision_all(held_object, true)
	remove_collision_exception_with(held_object)
	ray.remove_exception(held_object)
	held_object.freeze = false
	held_object.linear_velocity = -camera.global_transform.basis.z * 3
	held_object = null
		
		
func take_hit() -> void:
	if dead:
		return
	hits_taken += 1
	print("Player hit! ", hits_taken, "/", max_hits)
	_flash_blood()

	if hits_taken >= max_hits:
		_die()


func _flash_blood() -> void:
	if blood_tween:
		blood_tween.kill()

	blood_screen.visible = true
	blood_screen.modulate.a = 1.0

	blood_tween = create_tween()
	blood_tween.tween_property(blood_screen, "modulate:a", 0.0, 0.8)
	blood_tween.tween_callback(func(): blood_screen.visible = false)
	
	
func held_item_name() -> String:
	if held_object == null:
		return ""
	return held_object.get_parent().name.to_lower()


func take_held_item():
	var item = held_object
	remove_collision_exception_with(item)
	ray.remove_exception(item)
	held_object = null
	return item


func show_message(msg: String) -> void:
	if msg == "":
		return
	dialogue_id += 1
	var my_id = dialogue_id
	dialogue.text = msg
	dialogue.show()
	message_active = true
	await get_tree().create_timer(max(3.0, msg.length() * 0.07)).timeout
	if my_id == dialogue_id:
		message_active = false
		dialogue.hide()

func _find_interactable(node):
	while node:
		if node.has_method("puzzle_interact"):
			return node
		node = node.get_parent()
	return null


func _die() -> void:
	dead = true
	if held_object:
		drop()
	show_message("You died...")
	await get_tree().create_timer(2.0).timeout
	global_transform = spawn_transform
	velocity = Vector3.ZERO
	hits_taken = 0
	dead = false
	for e in get_tree().get_nodes_in_group("enemy"):
		e.reset_enemy()
