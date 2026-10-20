extends Node3D

# Name of the item this needs (the item's node name under "tools", any capitalization).
@export var required_item := ""

# Hidden node that appears when solved (e.g. the wrench). Optional.
@export var reward: Node3D

# Where the used item gets placed and stays (e.g. a Marker3D on the table). Optional.
@export var place_point: Node3D

# If there's no place_point: true = item disappears, false = player keeps holding it.
@export var consume_item := false

# Dialogue
@export_multiline var ask_text := ""      # shown when interacting without the right item
@export_multiline var solved_text := ""   # shown when solved (and on later interactions)

var solved := false


func puzzle_interact(player) -> void:
	if solved:
		player.show_message(solved_text)
		return

	if player.held_item_name() != required_item.to_lower():
		player.show_message(ask_text)
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

	player.show_message(solved_text)
	
