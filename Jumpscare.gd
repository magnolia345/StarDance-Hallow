extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D2
@onready var raycast = $RayCast3D
@onready var anim_player = $JUMPSCARE/AnimationPlayer

const SPEED = 30.0

# 1. We create an export variable so you can assign your Player node in the Inspector
@export var player: CharacterBody3D
func _ready():
	# Stop the process loop until the navigation map finishes syncing
	set_physics_process(false)
	call_deferred("actor_setup")

func actor_setup():
	# Await exactly one physics frame for the Navigation Server to link
	await get_tree().physics_frame
	set_physics_process(true)
func _physics_process(delta):
	if not player:
		return # Stop if the player node isn't assigned yet

	# 2. Point the raycast directly at the player
	raycast.look_at(player.global_position, Vector3.UP)
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		# 3. If the ray hits the player directly (no walls in between), SET THE TARGET
		if collider == player:
			nav_agent.target_position = player.global_position
			var target_look = Vector3(player.global_position.x, global_position.y, player.global_position.z)
			look_at(target_look, Vector3.UP)

	# 4. Handle navigation movement along the calculated path
	if not nav_agent.is_navigation_finished():
		var next_path_pos = nav_agent.get_next_path_position()
		# Make sure to utilize get_next_path_position() to guide velocity vectors!
		velocity = global_position.direction_to(next_path_pos) * SPEED
		move_and_slide()
	else:
		velocity = Vector3.ZERO
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= 5:
		velocity = Vector3.ZERO
		
		# Turn to face player exactly
		var target_look = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		look_at(target_look, Vector3.UP)
		
		# Play the attack animation safely
		anim_player.play("Scene")
		
		anim_player.animation_finished.connect(func(anim_name): queue_free())
		anim_player.animation_finished.connect(func(anim_name): player.end())

		
