extends Control

enum SEARCH_TYPE { UID=0, USERNAME=1}

@onready var profile_editor: ProfileEditor = $ProfileEditor
@onready var list_controller: ListController = $ListController
@onready var player_requester: HTTPRequest = $PlayerRequestHTTP
@onready var user_search_foreground: UserSearchForeground = $UserSearchForeground

@export var username_search_url: String = "https://new.osudroid.moe/api2/frontend/profile-username/%s"
@export var uid_search_url: String = "https://new.osudroid.moe/api2/frontend/profile-uid/%d"


var en_model_error: UserSearchForeground.Models = user_search_foreground.Models.ERROR
var en_model_done: UserSearchForeground.Models = user_search_foreground.Models.DONE
var en_model_nf: UserSearchForeground.Models = user_search_foreground.Models.NOT_FOUND


func _ready() -> void:
	player_requester.connect("request_completed", self._player_requester_rq_completed)

# This function calls profile_requester.request, using uid(int) or username(string)
func getProfile(search_type: SEARCH_TYPE, uid: int = 0, username: String = "") -> void:
	var current_url: String = ""	

	match search_type:
		0: current_url = uid_search_url % uid
		1: current_url = username_search_url % username
		_: push_error("Invalid search type"); return

	var error = player_requester.request(current_url)

	if error != OK:
		push_error("An error ocurred in HTTP Request. Func: getProfile; Error: " + error)
		return	


# This function calls profile_editor, list_controller & beatmap_info_controller
func updateAll(data: Dictionary) -> void:
	if data:
		profile_editor.update_profile(data)
		list_controller.gen_list(data, 0)
		


func _player_requester_rq_completed(result, _response_code, _headers, body):
	# Case 1: Profile not downloaded (any error from network, machine or url)
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Profile couldn't be downloaded")

		# Send to foreground as error
		user_search_foreground.update_panel(en_model_error, "Profile couldn't be downloaded")
		return

	var string_body = body.get_string_from_utf8()

	# Case 2: Empty response from the server
	if string_body.is_empty():
		push_error("Profile data is empty.")

		# Send to foreground as error
		user_search_foreground.update_panel(en_model_error, "Profile data is empty")
		return
	
	var json = JSON.new()
	var parse_result = json.parse(string_body)

	# Case 3: Not valid profile data/Json format
	if parse_result != OK:
		push_error("Couldn't parse the profile data.")
		
		# Send to foreground as error
		user_search_foreground.update_panel(en_model_error, "Couldn't parse the profile data.")
		return
	
	var data = json.get_data()

	# Case 4: Profile has not user data, like UserId (uid)
	if typeof(data) != TYPE_DICTIONARY or not data.has("UserId"):
		push_error("Invalid profile data received.")

		if data.has("error"):
			push_error("Error in profile data: %s" % data.error)
			if "not found" in data.error:
				user_search_foreground.update_panel(en_model_nf)
				return

		# Send to foreground as error
		user_search_foreground.update_panel(en_model_error, "Invalid profile data")		
		return

	user_search_foreground.update_panel(en_model_done)
	updateAll(data)


func _on_user_search_foreground_submit_search(method:int, username:String = "", uid: int = 0) -> void:
	getProfile(method, uid, username)
