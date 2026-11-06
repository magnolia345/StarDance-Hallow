extends Node3D
@onready var target = $"../player/Head/Camera3D"
@onready var light = $"../player/Head/Camera3D/SpotLight3D"
@onready var hand = $"../player/Head/Camera3D/Hand"
var held = null
var check = false
var val
var checker = false
var try
var cake_normal_scale = 11.111
var cake_held_scale = 5

@onready var cake = find_child("cake", true, false)
# Called when the node enters the scene tree for the first time.

func _ready() -> void:

	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func interacts(node):
	var root = node
	val = root.find_child(String(node), true, false)
	val.hide()
func interact(node):
	node.global_position = hand.global_position
	if node == cake or cake.is_ancestor_of(node):
		cake.scale = cake_held_scale

func drop_cake():
	cake.scale = cake_normal_scale
