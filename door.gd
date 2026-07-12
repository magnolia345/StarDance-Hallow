extends Node3D
var door = false
var interaction = true
@export var animation: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func interact(distance):
	if interaction and distance < 10:
		door = not door
		if door:
			animation.play("open")
		else:
			animation.play("close")
		await get_tree().create_timer(1.0, false ).timeout
		interaction = true
