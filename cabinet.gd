extends StaticBody3D

var is_open = false;

@onready var door1 = $tumbochka/door1a
@onready var door2 = $tumbochka/door2a

# Called when the node enters the scene tree for the first time.
func interact():
	if is_open:
		return
	is_open = true
	var tween = create_tween()
	tween.tween_property(door1, "rotation:y", deg_to_rad(90), 0.5)
	tween.parallel().tween_property(door2, "rotation:y", deg_to_rad(-90), 0.5)
