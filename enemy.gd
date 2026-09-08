extends CharacterBody3D

@export var speed: float = 5.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player =  $"../player"# Update to your player's actual path

func _physics_process(delta: float) -> void:

	nav_agent.target_position = player.global_position
	
	# 2. Check if we've already reached the target


	# 3. Get the next immediate vector point along the calculated path
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	
	# 4. Calculate the direction and velocity
	var current_position: Vector3 = global_position
	var new_velocity: Vector3 = (next_path_position - current_position).normalized() * 10
	
	# 5. Move the CharacterBody3D
	velocity = new_velocity
	move_and_slide()
