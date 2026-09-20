extends Node3D
@onready var target = $"../player/Head/Camera3D"
@onready var light = $"../player/Head/Camera3D/SpotLight3D"
var check = false
var val
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func interact(node):
	var root = get_parent()
	val = root.find_child(String(node), true, false)
	val.hide()s
	
