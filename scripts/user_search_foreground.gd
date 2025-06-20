extends Control

@onready var ui_searching_btn: Button = $SearchStatusControl/HBoxContainer/SearhingStatus/SearchingBtn
@onready var ui_error_texture_btn: Button = $SearchStatusControl/HBoxContainer/ErrorBtn


var searching: bool = false
var rotation_speed: float = 5.0


func search() -> void:
	pass


func _process(delta: float) -> void:
	if searching:
		ui_searching_btn.rotation += rotation_speed * delta
