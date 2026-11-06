extends Node3D

# Items it asks for, in order (node names under "tools", any capitalization).
@export var requests: Array[String] = []

# What it says while waiting for each request (shown when you look at it).
@export_multiline var request_texts: Array[String] = []

# What it says right after you give it each item.
@export_multiline var thanks_texts: Array[String] = []

# Appears after the last item (e.g. Key 1). Hidden + Process Mode Disabled at start.
@export var reward: Node3D

# Optional: hidden after the last item (e.g. the creature itself, if it dies).
@export var hide_on_solve: Node3D
@export var idle_anim := "metarig|search"
@export var screech_anim := "metarig|screech"
@export var death_anim := "metarig|getup3"

@onready var anim: AnimationPlayer = find_child("AnimationPlayer", true, false)

var stage := 0
var solved := false
var ask_text := ""


func _ready() -> void:
	_update_ask_text()
	if anim:
		anim.play(idle_anim)

func puzzle_interact(player) -> void:
	if solved or requests.is_empty():
		return

	if player.held_item_name() != requests[stage].to_lower():
		player.show_message(ask_text)
		return

	var item = player.take_held_item()
	item.get_parent().queue_free()

	if stage < thanks_texts.size():
		player.show_message(thanks_texts[stage])

	stage += 1

	if stage < requests.size():
		_update_ask_text()
		return

	solved = true
	ask_text = ""

	if reward:
		reward.visible = true
		reward.process_mode = Node.PROCESS_MODE_INHERIT

	solved = true
	ask_text = ""
	_die_sequence()


func _update_ask_text() -> void:
	if stage < request_texts.size():
		ask_text = request_texts[stage]
	else:
		ask_text = ""
		
func _die_sequence() -> void:
	if anim:
		anim.play(screech_anim)
		await anim.animation_finished
		anim.play(death_anim)
		await anim.animation_finished

	if reward:
		reward.visible = true
		reward.process_mode = Node.PROCESS_MODE_INHERIT

	if hide_on_solve:
		hide_on_solve.visible = false
		hide_on_solve.process_mode = Node.PROCESS_MODE_DISABLED
