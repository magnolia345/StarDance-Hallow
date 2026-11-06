extends StaticBody3D

var is_open = false

@onready var player: Node3D = get_tree().get_first_node_in_group("player")
@onready var raycast: RayCast3D = get_tree().get_first_node_in_group("interact_raycast")

@onready var cabinet_root: Node = get_parent().get_parent().get_parent().get_parent()

@onready var door1 = cabinet_root.find_child("Box1__0", true, false)
@onready var door2 = cabinet_root.find_child("Box2__0", true, false)
@onready var door3 = cabinet_root.find_child("Box3__0", true, false)
@onready var door4 = cabinet_root.find_child("Box4__0", true, false)
@onready var door5 = cabinet_root.find_child("Box5__0", true, false)
@onready var door6 = cabinet_root.find_child("Box6__0", true, false)
@onready var door7 = cabinet_root.find_child("Box7__0", true, false)
@onready var door8 = cabinet_root.find_child("Box8__0", true, false)
@onready var door9 = cabinet_root.find_child("Box9__0", true, false)

var active_tween: Tween

func _input(event):
	if not raycast:
		return
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

	if active_tween and active_tween.is_valid():
		active_tween.kill()
	var tween = create_tween()
	check(collider, door1, tween, -90, false)
	check(collider, door2, tween, -90, false)
	check(collider, door3, tween, -90, false)
	check(collider, door4, tween, -90, false)
	check(collider, door5, tween, -90, false)
	check(collider, door6, tween, -90, false)
	check(collider, door7, tween, -90, false)
	check(collider, door8, tween, -90, false)
	check(collider, door9, tween, -90, false)


func _tween_door(tween: Tween, door: Node3D, open_angle_deg: float):
	if not door:
		return
	var target_deg = open_angle_deg if is_open else 0.0
	tween.parallel().tween_property(door, "rotation:z", deg_to_rad(target_deg), 0.5)

func _tween_shelf(tween: Tween, shelf: Node3D):
	if not shelf:
		return
	var target_x = 0.0 if is_open else -1.424
	tween.parallel().tween_property(shelf, "position:y", target_x, 0.5)
func check(collider, door, tween, deg, type):
	if type:
		if collider == door or door.is_ancestor_of(collider):
			_tween_door(tween, door, deg)
			return
	else:
		if collider == door or door.is_ancestor_of(collider):
			_tween_shelf(tween, door)
			return
