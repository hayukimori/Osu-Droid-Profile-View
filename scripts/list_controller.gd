extends Node

enum LIST_MODE { HISTORY = 0, TOP_PLAYS = 1}

@export_category("Nodes settings")
@export var list_mode_label: Label
@export var list_mode_btn: Button


@export_category("Post data")
@export var gameplay_data: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
