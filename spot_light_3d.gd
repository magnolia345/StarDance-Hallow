extends SpotLight3D

var check = true
var flash_check = true
var battery_life = 200
var decrement = 1
var battery_check = false
var flash = 0
const freq = 0.4

@onready var battery = $"../../../CanvasLayer/Battery_life"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
func _input(event):
	if event is InputEventKey and event.keycode == KEY_F:
		if event.pressed and not event.is_echo():
			flash_check = not flash_check
func _process(delta: float):
	if battery_check:
		if flash_check and battery_life > 0:
			show()
			battery_life -= decrement * delta
		else:
			hide()
		battery.value = battery_life
	else:
		battery.hide()
		if flash_check:
			show()
		else:
			hide()
	flash = randf_range(0, 1)
	if flash < freq and flash > 0:
		light_energy = randf_range(4.0, 8.0)

	
