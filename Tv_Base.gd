extends StaticBody3D

var is_open = false

@onready var player: Node3D = get_tree().get_first_node_in_group("player")
@onready var raycast: RayCast3D = get_tree().get_first_node_in_group("interact_raycast")

@onready var cabinet_root: Node = get_parent().get_parent().get_parent().get_parent()

@onready var door1 = cabinet_root.find_child("Drawers_low_001", true, false) if cabinet_root else null
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


func _tween_door(tween: Tween, door: Node3D, open_angle_deg: float):
	if not door:
		return
	var target_deg = open_angle_deg if is_open else 0.0
	tween.parallel().tween_property(door, "rotation:z", deg_to_rad(target_deg), 0.5)

func _tween_shelf(tween: Tween, shelf: Node3D):
	if not shelf:
		return
	var target_x = 0.0 if is_open else -28.794
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
