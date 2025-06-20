extends Control



@onready var beatmap_head_info_control: Control = $BgPanel/BeatmapHeadInfo
@onready var gameplay_details_control: Control = $BgPanel/GameplayDetails
@onready var beatmap_content_control: Control = $BgPanel/BeatmapContentControl

@onready var beatmapset_name_label: Label = $BgPanel/BeatmapHeadInfo/BeatmapsetNameLabel
@onready var artist_label: Label = $BgPanel/BeatmapHeadInfo/ArtistLabel
@onready var diff_name_label: Label = $BgPanel/BeatmapHeadInfo/DiffNameLabel
@onready var beatmap_status_label: Label = $BgPanel/BeatmapHeadInfo/Status
@onready var beatmap_id_btn: Button = $BgPanel/BeatmapHeadInfo/IdBtn
@onready var beatmap_bg: TextureRectRounded = $BgPanel/BeatmapsetImage

@onready var map_perfect : Button = $BgPanel/GameplayDetails/HitCirclesPanel/HBoxContainer/MapPerfectCountBtn
@onready var map_geki : Button = $BgPanel/GameplayDetails/HitCirclesPanel/HBoxContainer/MapGekiCountBtn
@onready var map_good : Button = $BgPanel/GameplayDetails/HitCirclesPanel/HBoxContainer/MapGoodCountBtn
@onready var map_katu : Button = $BgPanel/GameplayDetails/HitCirclesPanel/HBoxContainer/MapKatuCountBtn
@onready var map_bad : Button = $BgPanel/GameplayDetails/HitCirclesPanel/HBoxContainer/MapBadCountBtn
@onready var map_miss : Button = $BgPanel/GameplayDetails/HitCirclesPanel/HBoxContainer/MapMissCountBtn2

@onready var verbose_rank_rtl = $BgPanel/GameplayDetails/VerboseRankRTL

@onready var beatmap_ar : Button = $BgPanel/BeatmapContentControl/GridContainer/AR_Btn
@onready var beatmap_ac : Button = $BgPanel/BeatmapContentControl/GridContainer/AC_Btn
@onready var beatmap_cs : Button = $BgPanel/BeatmapContentControl/GridContainer/CS_Btn
@onready var beatmap_dr : Button = $BgPanel/BeatmapContentControl/GridContainer/DR_Btn
@onready var beatmap_bpm : Button = $BgPanel/BeatmapContentControl/GridContainer/BPM_Btn
@onready var beatmap_diff_rating : Button = $BgPanel/BeatmapContentControl/GridContainer/DiffRating_Btn
@onready var beatmap_circle_count : Button = $BgPanel/BeatmapContentControl/GridContainer/CircleCount_Btn
@onready var beatmap_slider_count : Button = $BgPanel/BeatmapContentControl/GridContainer/SliderCount_Btn


func _ready() -> void:
	#beatmap_head_info_control.visible = false
	#gameplay_details_control.visible = false
	#beatmap_content_control.visible = false
	pass

func update_gameplay_details(gameplay_data: Dictionary, username: String) -> void:

	if gameplay_data == {}:
		push_error("Gameplay data is empty")
		return

	var map_pp = "0"
	if gameplay_data.MapPP == null:
		map_pp = "0"
	else:
		map_pp = "%.2f" % gameplay_data.MapPP

	# Verbose Rank (Rich Text)
	var rank_color: String = "silver"
	match gameplay_data.MapRank:
		"X": rank_color = "gold"
		"XH": rank_color = "silver"
		"SH": rank_color = "silver"
		"S": rank_color = "gold"
		"A": rank_color = "green"
		"B": rank_color = "blue"
		"C": rank_color = "purple"
		"D", "F": rank_color = "red"
		_: rank_color = "silver"
		

	var data_for_text = {
		"username": username,
		"color": rank_color,
		"MapRank": gameplay_data.MapRank,
		"MapPP": map_pp, # Already a string
		"MapAccuracy": "%.2f" % (gameplay_data.MapAccuracy * 100)
	}

	var basetext = "[center] [i] {username} [/i] got rank [color={color}]{MapRank}[/color] in this map. {MapPP} PP | {MapAccuracy} % [/center]".format(data_for_text)
	verbose_rank_rtl.text = basetext

	map_perfect.text = "%d" % gameplay_data.MapPerfect
	map_geki.text = "%d" %  gameplay_data.MapGeki
	map_good.text = "%d" %  gameplay_data.MapGood
	map_katu.text = "%d" %  gameplay_data.MapKatu
	map_bad.text = "%d" % gameplay_data.MapBad
	map_miss.text = "%d" %  gameplay_data.MapMiss


func update_beatmap_data(beatmap_info: Dictionary, raw_gameplay_data: Dictionary, current_texture: Texture) -> void:

	var beatmapset_name: String = "No title."
	var artist: String = "No Artist"
	var diff_name: String = "No DiffName"
	

	if beatmap_info == {}: # Empty beatmap, use gameplay details instead
		print(raw_gameplay_data)


		push_warning("beatmap_info is empty, using raw_gameplay_data instead...")
		beatmapset_name = raw_gameplay_data.Filename
		artist = "(please connect to osu! to get this info)"
		diff_name = ""


		if raw_gameplay_data.MapHash != null:
			beatmap_id_btn.text = raw_gameplay_data.MapHash
		else:
			beatmap_id_btn.text = "No Hash or ID"

	else:
		beatmapset_name = beatmap_info.beatmapset.title
		beatmap_status_label.text = beatmap_info.status.to_upper()
		diff_name = beatmap_info.version

		# Change status text and it's color
		match beatmap_info.status:
			"ranked", "approved":
				beatmap_status_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
				var style = beatmap_status_label.get("theme_override_styles/normal")
				if style and style is StyleBoxFlat:
					style.bg_color = Color(0.15, 0.5, 0.15)
			"loved":
				beatmap_status_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.8))
				var style = beatmap_status_label.get("theme_override_styles/normal")
				if style and style is StyleBoxFlat:
					style.bg_color = Color(0.5, 0.15, 0.5)
			"wip":
				beatmap_status_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.2))
				var style = beatmap_status_label.get("theme_override_styles/normal")
				if style and style is StyleBoxFlat:
					style.bg_color = Color(0.5, 0.5, 0.15)
			"graveyard":
				beatmap_status_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
				var style = beatmap_status_label.get("theme_override_styles/normal")
				if style and style is StyleBoxFlat:
					style.bg_color = Color(0.5, 0.15, 0.15)
			_:
				beatmap_status_label.add_theme_color_override("font_color", Color(1, 1, 1))
				var style = beatmap_status_label.get("theme_override_styles/normal")
				if style and style is StyleBoxFlat:
					style.bg_color = Color(0.2, 0.2, 0.2)

		beatmap_id_btn.text = "%d" % beatmap_info.id


	# Set basic info to respective labels
	beatmapset_name_label.text = beatmapset_name
	artist_label.text = artist
	diff_name_label.text = diff_name


	# Updating image
	if current_texture != null:
		beatmap_bg.texture = current_texture
