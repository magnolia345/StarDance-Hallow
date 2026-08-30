extends StaticBody3D

var is_open = false

func interact():
	if is_open:
		return
	is_open = true
	var root = get_parent().get_parent().get_parent().get_parent()
	var door1 = root.find_child("door1", true, false)
	var door2 = root.find_child("door2", true, false)
	var door3 = root.find_child("door3", true, false)
	var door4 = root.find_child("door4", true, false)
	print("found door1: ", door1)
	var tween = create_tween()
	if door1:
		tween.tween_property(door1, "rotation:y", deg_to_rad(90), 0.5)
	if door2:
		tween.parallel().tween_property(door2, "rotation:y", deg_to_rad(-90), 0.5)
	if door3:
		tween.parallel().tween_property(door3, "rotation:y", deg_to_rad(90), 0.5)
	if door4:
		tween.parallel().tween_property(door4, "rotation:y", deg_to_rad(-90), 0.5)
