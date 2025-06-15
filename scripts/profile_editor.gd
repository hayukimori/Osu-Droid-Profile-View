extends Node
# Node task: Edit Profile Info


enum AVATAR_REQUEST_METHOD {OLD, NEW}

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
	pass