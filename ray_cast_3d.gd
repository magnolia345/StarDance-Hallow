extends RayCast3D
@onready var camera = $"../Camera3D" 
@onready var raycast = $"."
func _ready():
	raycast.add_exception(self)

func _physics_process(_delta):
	if is_colliding():
		var collider = get_collider()
		var final_name = collider.name # Fallback default
		
		# 1. If it hits a generic StaticBody, try to use the parent
		if collider is StaticBody3D and "StaticBody" in collider.name:
			var parent = collider.get_parent()
			# Don't let it print the root scene name "main"
			if parent != null and parent.name != "main":
				final_name = parent.name
			else:
				# If the parent IS main, use the mesh name or the collider itself
				final_name = collider.name 
		
		print(final_name)
