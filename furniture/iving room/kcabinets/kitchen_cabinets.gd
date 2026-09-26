extends StaticBody3D

var is_open = false
var option = true
var open1 = false
var open2 = false
var open3 = false
var open4 = false 
var collider 
@onready var raycast = $"../../../../../../../../player/Head/Camera3D/RayCast3D"
func _input(event):
	if event is InputEventKey and event.keycode == KEY_E:
		if event.pressed and not event.is_echo():
				interact()
			
	
func interact():
		is_open = not is_open
		var root = get_parent().get_parent().get_parent().get_parent()
		var door1 = root.find_child("Material258", true, false)
		var door2 = root.find_child("Material240", true, false)
		var door3 = root.find_child("Material253", true, false)
		var door4 = root.find_child("Material2132", true, false)
		var shelf1 = root.find_child("Material2106", true, false)
		var shelf2 = root.find_child("Material2110", true, false)
		var shelf3 = root.find_child("Material2123", true, false)
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
			tween.parallel().tween_property(door3, "rotation:z", deg_to_rad(-90), 0.5)
			
		else:
			tween.parallel().tween_property(door3, "rotation:z", deg_to_rad(0), 0.5)
		if door4 and is_open:
			tween.parallel().tween_property(door4, "rotation:z", deg_to_rad(-90), 0.5)
			
		else:
			tween.parallel().tween_property(door4, "rotation:z", deg_to_rad(0), 0.5)
		if shelf1 and is_open:
			tween.parallel().tween_property(shelf1, "rotation:z", deg_to_rad(-90), 0.5)
		else:
			tween.parallel().tween_property(shelf1, "rotation:z", deg_to_rad(0), 0.5)
		if shelf2 and is_open:
			tween.parallel().tween_property(shelf2, "rotation:z", deg_to_rad(-90), 0.5)
		else:
			tween.parallel().tween_property(shelf2, "rotation:z", deg_to_rad(0), 0.5)
		if shelf3 and is_open:
			tween.parallel().tween_property(shelf3, "rotation:z", deg_to_rad(-90), 0.5)
		else:
			tween.parallel().tween_property(shelf3, "rotation:z", deg_to_rad(0), 0.5)
