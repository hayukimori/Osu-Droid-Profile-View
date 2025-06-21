extends Control

@onready var enable_owa_button: Button = $UserConfigBG/ApplicationSetupPanel/EnableOWA_Button
@onready var osu_client_id_le: LineEdit = $UserConfigBG/OsuConfigsPanel/ApplicationConfigControl/ClientID_LE
@onready var osu_secret_le: LineEdit = $UserConfigBG/OsuConfigsPanel/ApplicationConfigControl/ClientSecret_LE

@export var oa_helper: OAuth2Helper


func save_settings(settings: AppSettings) -> void:
	var path := "user://app_settings.tres"
	var error = ResourceSaver.save(settings, path)
	
	if error != OK:
		push_error("Error saving settings: %s" % error)


func load_settings() -> AppSettings:
	var path := "user://app_settings.tres"
	if not FileAccess.file_exists(path):
		var default_settings = AppSettings.new()
		save_settings(default_settings)
		return default_settings

	var loaded = ResourceLoader.load(path)
	if loaded is AppSettings:
		return loaded
	else:
		push_error("Erro ao carregar configurações.")
		return AppSettings.new()


func load_ui() -> void:
	var current_configs: AppSettings = load_settings()

	# Change "enable osu!web api" button text by current mode
	if current_configs.enable_osu_web_api == false:
		enable_owa_button.text = "Enable Osu!web API"
	else:
		enable_owa_button.text = "Disable Osu!web API"
	

	var osu_config: Dictionary = get_osu_config_content()
	if osu_config == {}:
		return
	
	osu_client_id_le.text = "%d" % osu_config.client_id
	osu_secret_le.text = osu_config.client_secret
	

func get_osu_config_content() -> Dictionary:
	# Get osu_config.json and load it's content
	var osu_config_path = "user://osu_config.json"
	if not FileAccess.file_exists(osu_config_path):
		push_warning("Config file not found: %s" % osu_config_path)
		return {}

	var file = FileAccess.open(osu_config_path, FileAccess.READ)
	if file == null:
		push_warning("Couldn't open config file")
		return {}

	var content = file.get_as_text()
	file.close()


	var json = JSON.new()
	var parse_result = json.parse(content)

	# Case 3: Not valid profile data/Json format
	if parse_result != OK:
		push_error("JSON Parsing error: %s" % parse_result)
		return {}

	var data = json.get_data()
	if not (data.has("client_id") and data.has("client_secret")):
		push_error("Invalid config file: no client_id or client_secret found")
		return {}
	
	return data

