extends StaticBody3D

var is_open = false

@onready var player: Node3D =$"../../../../../player"
@onready var raycast: RayCast3D = $"../../../../../player/Head/Camera3D/RayCast3D"

@onready var cabinet_root: Node = get_parent().get_parent().get_parent().get_parent()

@onready var door1 = cabinet_root.find_child("Material258", true, false)
@onready var door2 = cabinet_root.find_child("Material240", true, false)
@onready var door3 = cabinet_root.find_child("Material253", true, false)
@onready var door4 = cabinet_root.find_child("Material2132", true, false)
@onready var shelf1 = cabinet_root.find_child("Material2106", true, false)
@onready var shelf2 = cabinet_root.find_child("Material2110", true, false)
@onready var shelf3 = cabinet_root.find_child("Material2123", true, false)
@onready var door5 = cabinet_root.find_child("Material2235", true, false)
@onready var door6 = cabinet_root.find_child("Material2861", true, false)
@onready var door7 = cabinet_root.find_child("Material2213", true, false)
@onready var door8 = cabinet_root.find_child("Material2294", true, false)
@onready var door9= cabinet_root.find_child("Material2300", true, false)
func _input(event):
	if event is InputEventKey and event.keycode == KEY_E:
		if event.pressed and not event.is_echo():
			interact()

func interact():
	if not raycast.is_colliding():
		return

	var collider = raycast.get_collider()
	if collider != cabinet_root and not cabinet_root.is_ancestor_of(collider):
		return

	is_open = not is_open
	var tween = create_tween()
	check(collider, door1, tween, -90, true)
	check(collider, door2, tween, -90, true)
	check(collider, door3, tween, -90, true)
	check(collider, door4, tween, -90, true)
	check(collider, shelf1, tween, -90, true)
	check(collider, shelf2, tween, -90, true)
	check(collider, shelf3, tween, -90, true)
	check(collider, door5, tween, -90, true)
	check(collider, door6, tween, -90, true)
	check(collider, door7, tween, -90, true)
	check(collider, door8, tween, -90, true)
	check(collider, door9, tween, -90, true)
func _tween_door(tween: Tween, door: Node3D, open_angle_deg: float):
	if not door:
		return
	var target_deg = open_angle_deg if is_open else 0.0
	tween.parallel().tween_property(door, "rotation:z", deg_to_rad(target_deg), 0.5)

func _tween_shelf(tween: Tween, shelf: Node3D):
	if not shelf:
		return
	var target_x = 0.761 if is_open else 0.25
	tween.parallel().tween_property(shelf, "position:x", target_x, 0.5)
func check(collider, door, tween, deg, type):
	if type:
		if collider == door or door.is_ancestor_of(collider):
			_tween_door(tween, door, deg)
			return
	else:
		if collider == door or door.is_ancestor_of(collider):
			_tween_shelf(tween, door)
			return
