extends Label


# External info

@export_category("Settings")
@export var search_beatmap_online: bool = false
@export var access_token: String = ""

@export_category("Score info")
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

# Internal Nodes
@onready var btn_map_combo: Button = $PlayDetailsButtonsHBoxContainer/ComboCount
@onready var btn_map_score: Button = $PlayDetailsButtonsHBoxContainer/MapScore
@onready var btn_map_pp: Button = $PlayDetailsButtonsHBoxContainer/MapPP
@onready var btn_accuracy: Button = $PlayDetailsButtonsHBoxContainer/MapAccuracy

@onready var rank_texture_rect: TextureRect = $RankTexture
@onready var bg_texture_rect: TextureRectRounded = $BackgroundImage

@onready var label_filename: Label = $FilenameLabel
@onready var bm_button: Button = $BeatmapButton


func _ready() -> void:
	if search_beatmap_online:
		push_error("search_beatmap_online is not implemented yet")
		pass
	
	set_beatmap_info()


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
