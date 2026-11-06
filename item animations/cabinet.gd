extends StaticBody3D

var is_open = false
var option = true
var open1 = false
var open2 = false
var open3 = false
var open4 = false

func _input(event):
	if event is InputEventKey and event.keycode == KEY_E:
		if event.pressed and not event.is_echo():
			interact()

func interact():
		is_open = not is_open
		var root = get_parent().get_parent().get_parent().get_parent()
		var door1 = root.find_child("door1a", true, false)
		var door2 = root.find_child("door2a", true, false)
		var door3 = root.find_child("door3a", true, false)
		var door4 = root.find_child("door4a", true, false)
		var shelf1 = root.find_child("shelf1a", true, false)
		var shelf2 = root.find_child("shelf2a", true, false)
		var shelf3 = root.find_child("shelf3a", true, false)
		print("found door1: ", door1)
		var tween = create_tween()
		if door1 and is_open:
			tween.parallel().tween_property(door1, "rotation:z", deg_to_rad(-90), 0.5)
		else:
			tween.parallel().tween_property(door1, "rotation:z", deg_to_rad(0), 0.5)
		if door2 and is_open:
			tween.parallel().tween_property(door2, "rotation:z", deg_to_rad(-90), 0.5)

		else:
			tween.parallel().tween_property(door2, "rotation:z", deg_to_rad(0), 0.5)
			
		if door3 and is_open:
			tween.parallel().tween_property(door3, "rotation:z", deg_to_rad(90), 0.5)
			
		else:
			tween.parallel().tween_property(door3, "rotation:z", deg_to_rad(0), 0.5)
		if door4 and is_open:
			tween.parallel().tween_property(door4, "rotation:z", deg_to_rad(90), 0.5)
			
		else:
			tween.parallel().tween_property(door4, "rotation:z", deg_to_rad(0), 0.5)
		if shelf1 and is_open:
			tween.parallel().tween_property(shelf1, "position:x", 0.761, 0.5)
		else:
			tween.parallel().tween_property(shelf1, "position:x", 0.25, 0.5)
		if shelf2 and is_open:
			tween.parallel().tween_property(shelf2, "position:x", 0.761, 0.5)
		else:
			tween.parallel().tween_property(shelf2, "position:x", 0.25, 0.5)
		if shelf3 and is_open:
			tween.parallel().tween_property(shelf3, "position:x", 0.761, 0.5)
		else:
			tween.parallel().tween_property(shelf3, "position:x", 0.25, 0.5)
