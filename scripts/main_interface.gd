extends Control

enum SEARCH_TYPE { UID=0, USERNAME=1}

@onready var profile_editor: ProfileEditor = $ProfileEditor
@onready var player_requester: HTTPRequest = $PlayerRequestHTTP

@export var username_search_url: String = "https://new.osudroid.moe/api2/frontend/profile-username/%s"
@export var uid_search_url: String = "https://new.osudroid.moe/api2/frontend/profile-uid/%d"


func _ready() -> void:
	#profile_editor.update_profile()
	player_requester.connect("request_completed", self._player_requester_rq_completed)
	getProfile(SEARCH_TYPE.UID, 220439, "hayukimori")


# This function calls profile_requester.request, using uid(int) or username(string)
func getProfile(search_type: SEARCH_TYPE, uid: int = 0, username: String = "") -> void:
	var current_url: String = ""

	

	match search_type:
		SEARCH_TYPE.UID: current_url = uid_search_url % uid
		SEARCH_TYPE.USERNAME: current_url = uid_search_url % username
		_: push_error("Invalid search type"); return

	print_debug(current_url)
	var error = player_requester.request(current_url)

	if error != OK:
		push_error("An error ocurred in HTTP Request. Func: getProfile; Error: " + error)
		return	


# This function calls profile_editor, list_controller & beatmap_info_controller
func updateAll(data: Dictionary) -> void:
	if data:
		profile_editor.update_profile(data)
		


func _player_requester_rq_completed(result, _response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Profile could'nt be downloaded")
		return
	
	var string_body = body.get_string_from_utf8()
	if string_body.is_empty():
		push_error("Profile data is empty.")
		return
	
	var json = JSON.new()
	var parse_result = json.parse(string_body)
	if parse_result != OK:
		push_error("Couldn't parse the profile data.")
		return
	
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY or not data.has("UserId"):
		push_error("Invalid profile data received.")

		if data.has("error"):
			push_error("Error in profile data: %s" % data.error)
			# TODO: Add releasLoader(data.error) here
		return

	updateAll(data)