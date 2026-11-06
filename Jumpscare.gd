extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D2
@onready var raycast = $RayCast3D
@onready var anim_player = $JUMPSCARE/AnimationPlayer
var start_transform: Transform3D

const SPEED = 30.0

@export var player: CharacterBody3D
func _ready():
	start_transform = global_transform
	set_physics_process(false)
	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame
	set_physics_process(true)
func _physics_process(delta):
	if not player:
		return 

	raycast.look_at(player.global_position, Vector3.UP)
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider == player:
			nav_agent.target_position = player.global_position
			var target_look = Vector3(player.global_position.x, global_position.y, player.global_position.z)
			look_at(target_look, Vector3.UP)

	if not nav_agent.is_navigation_finished():
		var next_path_pos = nav_agent.get_next_path_position()
		velocity = global_position.direction_to(next_path_pos) * SPEED
		move_and_slide()
	else:
		velocity = Vector3.ZERO
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= 5:
		velocity = Vector3.ZERO
		
		var target_look = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		look_at(target_look, Vector3.UP)
		
		anim_player.play("Scene")
		
		anim_player.animation_finished.connect(func(anim_name): queue_free())
		anim_player.animation_finished.connect(func(anim_name): player.end())

func reset_enemy() -> void:
	global_transform = start_transform
	velocity = Vector3.ZERO
