extends StaticBody3D

var is_open = false

func interact():
	is_open = not is_open
	var doors = get_parent()  # Cube_004_Cube_005_Material_001_0
	var tween = create_tween()
	var rot = 90.0 if is_open else 0.0
	tween.tween_property(doors, "rotation:y", deg_to_rad(rot), 0.5)
