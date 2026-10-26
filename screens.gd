extends CanvasLayer

@onready var escape_screen: Control = $EscapeScreen
@onready var game_over_screen: Control = $GameOverScreen


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	escape_screen.hide()
	game_over_screen.hide()
	$EscapeScreen/PlayAgain.pressed.connect(restart)
	$GameOverScreen/PlayAgain.pressed.connect(restart)


func show_escape() -> void:
	_show(escape_screen)


func show_game_over() -> void:
	_show(game_over_screen)


func _show(screen: Control) -> void:
	screen.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
