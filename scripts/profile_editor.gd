extends Node
# Node task: Edit Profile Info


enum AVATAR_REQUEST_METHOD {OLD = 0, NEW = 1}

var new_avatar_request_api_url: String = "https://new.osudroid.moe/api2/frontend/avatar/userid/%d"
var old_avatar_request_api_url: String = "https://osudroid.moe/user/avatar/%d.png"

@export_category("User Info")
@export var username_label: Label
@export var national_rank_label: Label
@export var global_rank_label: Label
@export var play_count_btn: Button
@export var accuracy_btn: Button
@export var pp_btn: Button
@export var overall_score_btn: Button

@export var country_flag_texture_rect: TextureRectRounded
@export var profile_picture_texture_rect: TextureRectRounded

@export_category("Settings")
@export var avatar_request_api_method: AVATAR_REQUEST_METHOD = AVATAR_REQUEST_METHOD.OLD
@export_dir var flags_directory: String = "res://assets/textures/country_flags"

@export_category("Post content")
@export var player_data: Dictionary = {}


func update_profile() -> void:
	get_user_pfp(player_data.UserId)


func get_user_pfp(uid: int) -> void:
	# New http request, add it as a child
	var http_request = HTTPRequest.new()
	add_child(http_request)

	http_request.request_completed.connect(self._http_image_requester_request_completed)

	# Verify current request method, and launches corresponding method
	match AVATAR_REQUEST_METHOD:
		AVATAR_REQUEST_METHOD.OLD:
			var error = http_request.request(old_avatar_request_api_url % uid)
			if error != OK:
				push_error("An error occurred in HTTP Request")

		AVATAR_REQUEST_METHOD.NEW:
			http_request.set_use_threads(true)
			http_request.set_timeout(10)

			var error = http_request.request(new_avatar_request_api_url % uid)
			if error != OK:
				push_error("An error occurred in HTTP Request")
		_:
			push_error("Invalid AVATAR_REQUEST_METHOD")
	

func _http_image_requester_request_completed(result, response_code, _headers, body):
	pass