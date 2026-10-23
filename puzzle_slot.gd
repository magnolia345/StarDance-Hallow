extends Node3D

# Name of the item this needs (the item's node name under "tools", any capitalization).
@export var required_item := ""

# Hidden node that appears when solved (e.g. the wrench). Optional.
@export var reward: Node3D

# Where the used item gets placed and stays (e.g. a Marker3D on the table). Optional.
@export var place_point: Node3D

# If there's no place_point: true = item disappears, false = player keeps holding it.
@export var consume_item := false
@export var hide_on_solve: Node3D
@export var uses_needed := 1
@export var progress_text := "Screws removed:"
var uses := 0

# Dialogue
@export_multiline var ask_text := ""      # shown when interacting without the right item
@export_multiline var solved_text := ""   # shown when solved (and on later interactions)

var solved := false


func puzzle_interact(player) -> void:
	if required_item == "":
		player.show_message(ask_text)
		return
	if solved:
		player.show_message(solved_text)
		return

	if player.held_item_name() != required_item.to_lower():
		player.show_message(ask_text)
		return
	uses += 1
	if uses < uses_needed:
		player.show_message("%s %d/%d" % [progress_text, uses, uses_needed])
		return
	if place_point:
		var item = player.take_held_item()
		var original_scale = item.get_parent().global_basis.get_scale()
		item.global_transform = Transform3D(place_point.global_basis.orthonormalized().scaled_local(original_scale), place_point.global_position)
	elif consume_item:
		var item = player.take_held_item()
		item.get_parent().queue_free()

	solved = true

	if reward:
		reward.visible = true
		reward.process_mode = Node.PROCESS_MODE_INHERIT

	if hide_on_solve:
		hide_on_solve.visible = false
		hide_on_solve.process_mode = Node.PROCESS_MODE_DISABLED
		
	player.show_message(solved_text)

	
