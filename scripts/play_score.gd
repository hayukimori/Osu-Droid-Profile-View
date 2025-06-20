extends Label

signal send_info_to_panel(beatmap_data, raw_gameplay_data, current_texture, username)

# External info

@export_category("Settings")
@export var search_beatmap_online: bool = false
@export var access_token: String = ""
@export var osu_api_host = "https://osu.ppy.sh/api/v2"
@export var beatmap_endpoint = "/beatmaps/lookup"
@export var username: String


@export_category("Score info")
@export var raw_gameplay_data: Dictionary
@export var filename: String = "{ filename }"
@export var mods: Array = []
@export var map_score: int = 0
@export var map_rank: String = "S"

@export_category("Map Combo Info")
@export var map_combo: int = 0
@export var map_geki: int = 0
@export var map_perfect: int = 0
@export var map_katu: int = 0
@export var map_good: int = 0
@export var map_bad: int = 0
@export var map_miss: int = 0

@export_category("Misc info")
@export var map_accuracy: float = 0.0
@export var map_pp: float = 0.00
@export var local_bm_hash: String = ""



# Internal Nodes
@onready var btn_map_combo: Button = $PlayDetailsButtonsHBoxContainer/ComboCount
@onready var btn_map_score: Button = $PlayDetailsButtonsHBoxContainer/MapScore
@onready var btn_map_pp: Button = $PlayDetailsButtonsHBoxContainer/MapPP
@onready var btn_accuracy: Button = $PlayDetailsButtonsHBoxContainer/MapAccuracy

@onready var rank_texture_rect: TextureRect = $RankTexture
@onready var bg_texture_rect: TextureRectRounded = $BackgroundImage

@onready var label_filename: Label = $FilenameLabel
@onready var bm_button: Button = $BeatmapButton

@export var current_texture: Texture

var http: HTTPRequest

var image_ready: bool = false
var data_ready: bool  = false

var current_beatmap_data: Dictionary

func _ready() -> void:

	set_beatmap_info()

	if search_beatmap_online == true and access_token != "":
		http = HTTPRequest.new()
		add_child(http)
		await search_online()


func search_online() -> void:
	# Initiates headers
	var headers = [
		"Accept: application/json",
		"Content-Type: application/json",
		"Authorization: Bearer %s" % access_token
	]

	var end_url = "%s%s?checksum=%s" % [osu_api_host, beatmap_endpoint, local_bm_hash]

	# Requests to osu!api beatmap data
	var err = http.request(end_url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		push_error("Error requesting token: %d" % err)
		return


	# Stores data to variables
	var response = await http.request_completed
	var result = response[0]
	var response_code = response[1]
	var r_headers = response[2]
	var body_bytes = response[3]


	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Beatmap linker request failed with result: %s" % result)
		return
	
	var string_body : String = body_bytes.get_string_from_utf8()

	# Case 1: Body is empty
	if string_body.is_empty():
		push_error("Beatmap linker request returned an empty body.")
		return
	
	var json = JSON.new()
	var parse_result = json.parse(string_body)

	# Case 2: Json Parsing error
	if parse_result != OK:
		push_error("Failed to parse JSON response: %s" % json.get_error_message())
		return
	
	var data = json.get_data()
	
	# Case 3: Is not an array or dict
	if typeof(data) != TYPE_ARRAY and typeof(data) != TYPE_DICTIONARY:
		push_error("Expected a dictionary from JSON response, got: %s" % typeof(data))
		
		if data.has("error"):
			push_error("Error from API: %s" % data["error"])
			return

	current_beatmap_data = data[0] if typeof(data) == TYPE_ARRAY and data.size() > 0 else data
	if not current_beatmap_data.has("beatmapset") or not current_beatmap_data.beatmapset.has("covers"):
		push_error("Beatmap data is missing 'beatmapset' or 'covers' field.")
		#print("Raw data: %s" % data)
		return

	update_image(current_beatmap_data)


func update_image(complete_data: Dictionary) -> void:

	var headers = [
		"Content-Type: Application/json",
		"Authorization: Bearer %s" % access_token
	]
	var end_url = complete_data.beatmapset.covers.slimcover

	# Requests to osu!api beatmap data
	var err = http.request(end_url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		push_error("Error requesting token: %d" % err)
		return


	# Stores data to variables
	var response = await http.request_completed
	var result = response[0]
	#var response_code = response[1]
	#var r_headers = response[2]
	var body = response[3]



	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Image couldn't be downloaded.")
	
	var image = Image.new()
	var format = detect_image_format(body)
	var err_img = OK

	match format:
		"png":
			err_img = image.load_png_from_buffer(body)
		"jpg", "jpeg":
			err_img = image.load_jpg_from_buffer(body)
		"webp":
			err_img = image.load_webp_from_buffer(body)
		_:
			push_error("Unsupported image format: %s" % format)
			err_img = image.load("res://assets/textures/default_playscore_bg.png")

	if err != OK:
		push_error("Couldn't load the image. Error code: %d" % err)
		return

	else:
		var texture = ImageTexture.create_from_image(image)
		current_texture = texture
		bg_texture_rect.texture = texture

		image_ready = true
		data_ready = true



func detect_image_format(data: PackedByteArray) -> String:
	if data.size() >= 8:
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




func set_beatmap_info() -> void:
	if map_pp == null:
		map_pp = 0.0

	label_filename.text = filename
	btn_map_combo.text = "%d" % map_combo
	btn_map_score.text = "%s" % format_numbers_dots(map_score)
	btn_accuracy.text = "%.2f %%" % (map_accuracy * 100)
	btn_map_pp.text = "%.2f" % map_pp
	
	match map_rank:
		"X": rank_texture_rect.texture = preload("res://assets/textures/icons/map_rank_icons/X.png")
		"XH": rank_texture_rect.texture = preload("res://assets/textures/icons/map_rank_icons/XH.png")
		"SH": rank_texture_rect.texture = preload("res://assets/textures/icons/map_rank_icons/SH.png")
		"S": rank_texture_rect.texture = preload("res://assets/textures/icons/map_rank_icons/S.png")
		"A": rank_texture_rect.texture = preload("res://assets/textures/icons/map_rank_icons/A.png")
		"B": rank_texture_rect.texture = preload("res://assets/textures/icons/map_rank_icons/B.png")
		"C": rank_texture_rect.texture = preload("res://assets/textures/icons/map_rank_icons/C.png")
		"D": rank_texture_rect.texture = preload("res://assets/textures/icons/map_rank_icons/D.png")
		"F": rank_texture_rect.texture = preload("res://assets/textures/icons/map_rank_icons/F.png")
		_:
			rank_texture_rect.texture = preload("res://assets/textures/icons/map_rank_icons/D.png")
			print("Unknown rank: %s" % map_rank)




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



func _on_send_info_to_panel_pressed() -> void:
	if not data_ready and not image_ready:
		await wait_data()

	var beatmap_data_api = current_beatmap_data.duplicate()
	send_info_to_panel.emit(beatmap_data_api, raw_gameplay_data, current_texture, username)



func wait_data() -> void:
	while (!data_ready and !image_ready) == true:
		await get_tree().process_frame
