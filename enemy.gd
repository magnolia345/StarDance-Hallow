extends CharacterBody3D

@export var speed: float = 5.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player =  $"../player"# Update to your player's actual path
@onready var back = $"../player/CanvasLayer/ImageForGodot"
@onready var ray_cast: RayCast3D = $RayCast3D
var player_in_vision_range: bool = false
func _ready():
	back.hide()
	ray_cast.add_exception(self)
func _physics_process(delta: float) -> void:
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
func can_see_player() -> bool:
	if not player_in_vision_range or not is_instance_valid(player):
		return false
		
	# Target position is relative to the RayCast3D's global origin
	ray_cast.target_position = player.global_position - global_position
	
	# Force physics frame precision check right now
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider == player:
			return true # Clear line of sight in 3D space!
			
	return false # A wall, pillar, or floor blocked the RayCast3D

# --- Signal Connections from Area3D ---

func _on_vision_area_body_entered(body: Node3D) -> void:
	if body == player:
		player_in_vision_range = true

func _on_vision_area_body_exited(body: Node3D) -> void:
	if body == player:
		player_in_vision_range = false
