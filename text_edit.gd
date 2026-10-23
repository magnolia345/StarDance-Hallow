extends TextEdit

@export var raycast: RayCast3D
@export var tools: Node3D
@export var bathtub: Node3D
@export var bathtub1: Node3D
@export var bathtub2: Node3D
@onready var text_edit: TextEdit = $"."


func _process(_delta: float) -> void:
	var collider = raycast.get_collider()
	if collider and tools.is_ancestor_of(collider):
		wide(130.0)
		text_edit.text = "E to Interact"
		show()

	else:
		hide()
func wide(new_width: float) -> void:
	var center_x = text_edit.position.x + text_edit.size.x / 2.0
	text_edit.size.x = new_width
	text_edit.position.x = center_x - new_width / 2.0
