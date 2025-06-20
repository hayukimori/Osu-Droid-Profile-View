extends Control
class_name UserSearchForeground


signal submit_search(method: int, username: String, uid: int)


@onready var ui_searching_btn: Button = $SearchStatusControl/HBoxContainer/SearhingStatus/SearchingBtn
@onready var ui_done_btn: Button = $SearchStatusControl/HBoxContainer/DoneBtn
@onready var ui_nf_btn: Button = $SearchStatusControl/HBoxContainer/QuestionMarkBtn
@onready var ui_error_btn: Button = $SearchStatusControl/HBoxContainer/ErrorBtn
@onready var current_status_label: Label = $SearchStatusControl/HBoxContainer/StatusLabel

@onready var search_status_control: Control = $SearchStatusControl

@onready var uid_or_username_LE: LineEdit = $CentralSearch/UiD_Username_LineEdit
@onready var current_method_ob: OptionButton = $CentralSearch/SearchMethodOptionButton
@onready var search_btn: Button = $CentralSearch/AlternativeSearchButton

enum Models { LOADING = 0, ERROR = 1, NOT_FOUND = 2, DONE = 3 }


var searching: bool = false
var rotation_speed: float = 5.0



func _ready() -> void:
	search_status_control.visible = false
	search_btn.pressed.connect(_search_event)
	uid_or_username_LE.text_submitted.connect(_search_event)


func search(method: int, username_id: String) -> void:

	print_debug("username_id: %s" % username_id)

	var username: String = ""
	var uid: int = 0

	match method:
		0: # UID
			if username_id.is_valid_int():
				uid = int(username_id)
			else:
				update_panel(Models.ERROR, "Not an UID")
				return
		1: # Username
			username = username_id

		_: return # Unhandled
	submit_search.emit(method, username, uid)


func update_panel(model: Models, reason: String = "No reason.") -> void:
	search_status_control.visible = true

	match model:
		Models.LOADING: model_loading()
		Models.ERROR: model_error(reason)
		Models.NOT_FOUND: model_notfound()
		Models.DONE: model_done()
		_:
			current_status_label.text = "Unhandled model..."
			searching = false

func model_loading() -> void:
	current_status_label.text = "Loading..."
	searching = true

	# Buttons
	ui_error_btn.visible = false
	ui_searching_btn.visible = true
	ui_nf_btn.visible = false
	ui_done_btn.visible = false

func model_error(reason: String) -> void:
	current_status_label.text = "%s" % reason
	searching = false

	# Buttons
	ui_error_btn.visible = true
	ui_searching_btn.visible = false
	ui_nf_btn.visible = false
	ui_done_btn.visible = false

func model_notfound() -> void:
	current_status_label.text = "Profile not found"
	searching = false

	# Buttons
	ui_error_btn.visible = false
	ui_searching_btn.visible = false
	ui_nf_btn.visible = true
	ui_done_btn.visible = false

func model_done() -> void:
	current_status_label.text = "Done, redirecting to profile screen..."
	searching = false

	# Buttons
	ui_error_btn.visible = false
	ui_searching_btn.visible = false
	ui_nf_btn.visible = false
	ui_done_btn.visible = true

	await get_tree().create_timer(2).timeout
	search_status_control.visible = false


func _process(delta: float) -> void:
	if searching:
		ui_searching_btn.rotation += rotation_speed * delta



# Events
func _search_event(text: String ="") -> void:
	var current_text: String = text

	if text == "" and uid_or_username_LE.text == "":
		update_panel(Models.ERROR, "Empty input. Please, enter a nickname/uid and try again.")
		return

	if text == "":
		current_text = uid_or_username_LE.text

	update_panel(Models.LOADING)
	search(current_method_ob.selected, current_text)
