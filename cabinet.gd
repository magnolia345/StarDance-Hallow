extends StaticBody3D

var is_open = false

@onready var player: Node3D =$"../../../../../../../../player"
@onready var raycast: RayCast3D = $"../../../../../../../../player/Head/Camera3D/RayCast3D"

@onready var cabinet_root: Node = get_parent().get_parent().get_parent().get_parent()

@onready var door1 = cabinet_root.find_child("door1a", true, false)
@onready var door2 = cabinet_root.find_child("door2a", true, false)
@onready var door3 = cabinet_root.find_child("door3a", true, false)
@onready var door4 = cabinet_root.find_child("door4a", true, false)
@onready var shelf1 = cabinet_root.find_child("shelf1a", true, false)
@onready var shelf2 = cabinet_root.find_child("shelf2a", true, false)
@onready var shelf3 = cabinet_root.find_child("shelf3a", true, false)

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
	check(collider, door3, tween, 90, true)
	check(collider, door4, tween, 90, true)
	check(collider, shelf1, tween, 90, false)
	check(collider, shelf2, tween, 90, false)
	check(collider, shelf3, tween, 90, false)

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
func try(tween):
	_tween_door(tween, door2, -90)
	_tween_door(tween, door3, 90)
	_tween_door(tween, door4, 90)
	_tween_shelf(tween, shelf1)
	_tween_shelf(tween, shelf2)
	_tween_shelf(tween, shelf3)
