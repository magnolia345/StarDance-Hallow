extends Node3D

# The puzzles that must be solved first (e.g. hook and lock).
@export var slots: Array[Node] = []

# The part of the door that swings (door_door_0).
@export var door_panel: Node3D
@export var open_angle := -90.0

# Trigger in the doorway that ends the game.
@export var exit_area: Area3D

var opened := false


func _ready() -> void:
	if exit_area:
		exit_area.monitoring = false
		exit_area.body_entered.connect(_on_exit_entered)


func _process(_delta: float) -> void:
	if opened or slots.is_empty():
		return
	for s in slots:
		if not s.solved:
			return
	_open()


func _open() -> void:
	opened = true
	if door_panel:
		var tween := create_tween()
		tween.tween_property(door_panel, "rotation_degrees:y", door_panel.rotation_degrees.y + open_angle, 1.5)
	if exit_area:
		exit_area.set_deferred("monitoring", true)


func _on_exit_entered(body: Node) -> void:
	if body.is_in_group("player"):
		get_tree().get_first_node_in_group("screens").show_escape()
