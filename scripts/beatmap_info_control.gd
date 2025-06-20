extends Control

@onready var beatmap_head_info_control: Control = $BgPanel/BeatmapHeadInfo
@onready var gameplay_details_control: Control = $BgPanel/GameplayDetails
@onready var beatmap_content_control: Control = $BgPanel/BeatmapContentControl

@onready var beatmapset_name_label: Label = $BgPanel/BeatmapHeadInfo/BeatmapsetNameLabel
@onready var artist_label: Label = $BgPanel/BeatmapHeadInfo/ArtistLabel
@onready var diff_name_label: Label = $BgPanel/BeatmapHeadInfo/DiffNameLabel
@onready var beatmap_status_label: Label = $BgPanel/BeatmapHeadInfo/Status

@onready var map_perfect : Button = $BgPanel/GameplayDetails/HitCirclesPanel/HBoxContainer/MapPerfectCountBtn
@onready var map_geki : Button = $BgPanel/GameplayDetails/HitCirclesPanel/HBoxContainer/MapGekiCountBtn
@onready var map_good : Button = $BgPanel/GameplayDetails/HitCirclesPanel/HBoxContainer/MapGoodCountBtn
@onready var map_katu : Button = $BgPanel/GameplayDetails/HitCirclesPanel/HBoxContainer/MapKatuCountBtn
@onready var map_bad : Button = $BgPanel/GameplayDetails/HitCirclesPanel/HBoxContainer/MapBadCountBtn
@onready var map_miss : Button = $BgPanel/GameplayDetails/HitCirclesPanel/HBoxContainer/MapMissCountBtn2

@onready var beatmap_ar : Button = $BgPanel/BeatmapContentControl/GridContainer/AR_Btn
@onready var beatmap_ac : Button = $BgPanel/BeatmapContentControl/GridContainer/AC_Btn
@onready var beatmap_cs : Button = $BgPanel/BeatmapContentControl/GridContainer/CS_Btn
@onready var beatmap_dr : Button = $BgPanel/BeatmapContentControl/GridContainer/DR_Btn
@onready var beatmap_bpm : Button = $BgPanel/BeatmapContentControl/GridContainer/BPM_Btn
@onready var beatmap_diff_rating : Button = $BgPanel/BeatmapContentControl/GridContainer/DiffRating_Btn
@onready var beatmap_circle_count : Button = $BgPanel/BeatmapContentControl/GridContainer/CircleCount_Btn
@onready var beatmap_slider_count : Button = $BgPanel/BeatmapContentControl/GridContainer/SliderCount_Btn


func _ready() -> void:
	beatmap_head_info_control.visible = false
	gameplay_details_control.visible = false
	beatmap_content_control.visible = false