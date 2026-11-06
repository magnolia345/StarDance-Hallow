extends CharacterBody3D

@export var speed: float = 5.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player =  $"../player"# Update to your player's actual path
@onready var back = $"../player/CanvasLayer/ImageForGodot"
@onready var raycast = $RayCast3D
var see = false
var check = false
var player_in_vision_range: bool = false
var max_vision_distance = 20
func _ready():
	back.hide()

func _physics_process(delta: float) -> void:
	if check:
		nav_agent.target_position = player.global_position
		if nav_agent.is_navigation_finished():
		
			return

	# 3. Get the next immediate vector point along the calculated path
		var next_path_position: Vector3 = nav_agent.get_next_path_position()
		var next_path_pos = nav_agent.get_next_path_position()
	# 4. Calculate the direction and velocity
		var current_position: Vector3 = global_position
		var new_velocity: Vector3 = (next_path_pos - current_position).normalized() * 10
	
	# 5. Move the CharacterBody3D
		velocity = new_velocity
		move_and_slide()
	# 2. Check if we've already reached the target

func _on_path_timer_timeout():
	nav_agent.target_position = player.global_position
func see_can() -> bool:
	var space_state = get_world_3d().direct_space_state
	var start_pos = global_position + Vector3(0, 1.5, 0) # Adjust for eye-height
	var end_pos = player.global_position + Vector3(0, 1.0, 0) # Target player chest/head
	if start_pos.distance_to(end_pos) > max_vision_distance:
		return false
		
	# 2. Create the ray parameters
	var query = PhysicsRayQueryParameters3D.create(start_pos, end_pos)
	
	# 3. Exclude the enemy itself so it doesn't hit its own collider	
	query.exclude = [self.get_rid()]
	
	# 4. Set the collision mask (make sure it checks player and environment layers)
	query.collision_mask = 0b1111 
	
	# 5. Cast the ray
	var result = space_state.intersect_ray(query)
	
	# 6. Analyze the result
	if result:
		if result.collider == player:
			return true
			
	return false
