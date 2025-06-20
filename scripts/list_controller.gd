extends Node
class_name ListController

enum LIST_MODE { HISTORY = 0, TOP_PLAYS = 1 }

@export_category("Nodes settings")
@export var list_mode_label: Label
@export var list_mode_btn: Button
@export_file("*.tscn") var base_play_score
@export var play_list_vbox: VBoxContainer
@export var connect_to_osu: bool = false
@export var osu_key_manager: OAuth2Helper
@export var beatmap_info_controller: Control

var current_list_mode: LIST_MODE = LIST_MODE.HISTORY
var current_loaded_plays: Array = []
var buffer_gameplay_data = {}

var status_texts: Dictionary = {
	"history": "History",
	"empty_history": "History (empty)",
	"top_plays": "Top Plays",
	"empty_top_plays": "Top Plays (empty)"
}


var current_access_token: String = ""


func _ready() -> void:
	list_mode_btn.pressed.connect(swap_list_mode)


	# Gets a access token
	if connect_to_osu:
		osu_key_manager.load_config()
		current_access_token = await osu_key_manager.get_token()
	



# Generates a list of PlayScore objects using a Dict from the osu!droid api
func gen_list(gameplay_data: Dictionary, list_mode: LIST_MODE) -> void:

	if current_loaded_plays.size() > 0:
		clearLoadedPlays()


	current_list_mode = list_mode
	buffer_gameplay_data = gameplay_data

	var data_scores: Array = gameplay_data.Last50Scores

	# Filter by list mode. (if list is empty, the label changes to (Empty) and returns)
	match list_mode:
		0: 
			data_scores = gameplay_data.Last50Scores
			list_mode_label.text = status_texts.history
			if data_scores.size() == 0:
				list_mode_label.text = status_texts.empty_history; return

		1: 
			data_scores = gameplay_data.Top50Plays
			list_mode_label.text = status_texts.top_plays
			if data_scores.size() == 0:
				list_mode_label.text = status_texts.empty_top_plays; return
				
		_: push_error("Invalid LIST_MODE"); return
	

	var psi: PackedScene = load(base_play_score)

	# Loops each item in data_scores,
	# instantiates a play score scene, apply the settings for it, 
	# and append it to an Array

	for item in data_scores:
		var map_pp: float = 0

		if item.MapPP == null:
			map_pp = 0.0
		else:
			map_pp = item.MapPP

		var nsc = psi.instantiate()
		#nsc.search_beatmap_online = false

		nsc.filename = item.Filename
		nsc.mods = item.Mods
		nsc.map_score = item.MapScore
		nsc.map_rank = item.MapRank

		nsc.map_combo = item.MapCombo
		nsc.map_geki = item.MapGeki
		nsc.map_perfect = item.MapPerfect
		nsc.map_katu = item.MapKatu
		nsc.map_good = item.MapGood
		nsc.map_bad = item.MapBad
		nsc.map_miss = item.MapMiss

		nsc.map_accuracy = item.MapAccuracy
		nsc.map_pp = map_pp
		nsc.username = gameplay_data.Username
		nsc.local_bm_hash = item.MapHash
		
		if connect_to_osu:
			nsc.search_beatmap_online = true
			nsc.access_token = current_access_token


		# Add as a child (main scene)
		play_list_vbox.add_child(nsc)
		current_loaded_plays.append(nsc)

	for play in current_loaded_plays:
		play.send_info_to_panel.connect(self.send_to_panel)

# swaps between the two items, if the current one is HISTORY, swaps it to TOP_PLAYS
func swap_list_mode() -> void:
	if buffer_gameplay_data == {}:
		push_error("No data found in buffer. Please run gen_list before use this command")
		return

	match current_list_mode:
		0: gen_list(buffer_gameplay_data, LIST_MODE.TOP_PLAYS)
		1: gen_list(buffer_gameplay_data, LIST_MODE.HISTORY)
		_: push_error("List mode not found"); return


# Executes queue_free on all scenes present in the list.
# Also clears the list
func clearLoadedPlays() -> void:
	for play in current_loaded_plays:
		play.queue_free()
	current_loaded_plays.clear()
	

func send_to_panel(beatmap_data, raw_gameplay_data, current_texture, username) -> void:
	beatmap_info_controller.update_gameplay_details(raw_gameplay_data, username)