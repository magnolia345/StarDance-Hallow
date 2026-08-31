extends CharacterBody3D

@export var speed: float = 5.0
@onready var target_node = $"../player"
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _physics_process(delta: float) -> void:
	if not target_node:
		return
		
	# 1. Update the destination to the target's current position
	nav_agent.target_position = target_node.global_position
	
	# 2. Check if we have already reached the target
	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		return
		
	# 3. Get the next waypoint coordinate from the navigation system
	var next_path_pos = nav_agent.get_next_path_position()
	var current_pos = global_position
	
	# 4. Calculate direction and velocity vectors
	var direction = (next_path_pos - current_pos).normalized()
	
	# Keep the movement purely on the horizontal XZ plane (ignores steep vertical jerks)
	direction.y = 0 
	direction = direction.normalized()
	
	velocity = direction * speed
	
	# 5. Move the character using Godot's physics engine
	move_and_slide()




	
