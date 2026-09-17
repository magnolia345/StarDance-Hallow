extends RayCast3D
@onready var camera = $"../Camera3D" 
@onready var raycast = $"."
func _ready():
	raycast.add_exception(self)
func _physics_process(_delta):
	if is_colliding():
		var collider = get_collider()
		print(collider.name)
		
