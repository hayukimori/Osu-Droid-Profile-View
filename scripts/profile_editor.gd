extends Node
class_name ProfileEditor

# Node task: Edit Profile Info


enum AVATAR_REQUEST_METHOD {OLD, NEW = 1}

#NOTE: (?size=256) is required, if it's not included, it returns an error: `{'error': 'Invalid size'}`
var new_avatar_request_api_url: String = "https://new.osudroid.moe/api2/frontend/avatar/userid/%d?size=256"
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
@export var rank_country_flag_texture_rect: TextureRectRounded
@export var profile_picture_texture_rect: TextureRectRounded

@export_category("Settings")
@export var avatar_request_api_method: AVATAR_REQUEST_METHOD = AVATAR_REQUEST_METHOD.OLD
@export_dir var flags_directory: String = "res://assets/textures/country_flags"
@export_file("*.png", "*.jpg", "*.webp", "*.svg") var default_profile_picture: String



class GeneralTools:
	func detect_image_format(data: PackedByteArray) -> String:
		if data.size() >= 9:
			var png_header := PackedByteArray([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
			if data.slice(0, 8) == png_header:
				return "png"
		if data.size() >= 2:
			if data[0] == 0xFF and data[1] == 0xD8:
				return "jpg"
		if data.size() >= 12:
			var riff_str = data.slice(0, 4).get_string_from_ascii()
			var webp_str = data.slice(8, 12).get_string_from_ascii()
			if riff_str == "RIFF" and webp_str == "WEBP":
				return "webp"
		return "unknown"
	
	func format_numbers_dots(number: int) -> String:
		var str_num = str(number)
		var result = ""
		var counter = 0

		for i in range(str_num.length() - 1, -1, -1):
			result = str_num[i] + result
			counter += 1
			if counter %3== 0 and i != 0:
				result = "." + result
		return result



# Create image tools
var gen_tools: GeneralTools = GeneralTools.new()


# => Update profile
func update_profile(player_data: Dictionary) -> void:
	get_user_pfp(player_data.UserId)
	update_flags(player_data.Region)
	set_username(player_data.Username)
	set_rankings(player_data.CountryRank, player_data.GlobalRank)
	set_overall_infos(player_data)



# => Set buttons (play count, accuracy, pp, etc) content.
func set_overall_infos(player_data: Dictionary) -> void:
	play_count_btn.text = "%d" % player_data.OverallPlaycount
	overall_score_btn.text = "%s" % gen_tools.format_numbers_dots(int(player_data.OverallScore))
	accuracy_btn.text = "%.2f" % (player_data.OverallAccuracy * 100) + "%"

	
	if player_data.OverallPP == null:
		pp_btn.text = "0.00"
	else:
		pp_btn.text = "%.2f" % player_data.OverallPP


# => Sets the player's rankings
func set_rankings(country_rk: int, global_rk: int) -> void:
	national_rank_label.text = "# %d" % country_rk
	global_rank_label.text = "# %d" % global_rk


# => Sets the player's username
func set_username(username: String) -> void:
	username_label.text = username


# => Update country flag
func update_flags(region: String) -> void:
	var flag_path = flags_directory + "/%s.svg" % region

	if ResourceLoader.exists(flag_path):
		rank_country_flag_texture_rect.texture = load(flag_path)
		country_flag_texture_rect.texture = load(flag_path)
	else:
		rank_country_flag_texture_rect.texture = null
		country_flag_texture_rect.texture = null

	



# => Gets User profile picture and send it to the profile picture (TextureRectRounded)
func get_user_pfp(uid: int) -> void:
	# New http request, add it as a child
	var http_request = HTTPRequest.new()
	add_child(http_request)

	http_request.request_completed.connect(self._http_image_requester_request_completed)


	# Verify current request method, and launches corresponding method
	match avatar_request_api_method:
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





#######################################
# Subfunctions
#######################################
func _http_image_requester_request_completed(result, _response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Image couldn't be downloaded. Result: %d" % result)
	
	var image = Image.new()
	var format = gen_tools.detect_image_format(body)
	var err = OK

	match format:
		"png":
			err = image.load_png_from_buffer(body)
		"jpg", "jpeg":
			err = image.load_jpg_from_buffer(body)
		"webp":
			err = image.load_webp_from_buffer(body)
		_:
			push_error("Unsupported image format: %s" % format)
			err = image.load(default_profile_picture)

	if err != OK:
		push_error("Couldn't load image. Error code: %d" % err)
		return
	else:
		var texture = ImageTexture.create_from_image(image)
		profile_picture_texture_rect.texture = texture
