extends Node
class_name OAuth2Helper

var token_data = {
	"access_token": "",
	"expires_at": 0
}

var client_id: int = 0
var client_secret: String = ""

var http: HTTPRequest

func _ready():
	http = HTTPRequest.new()
	add_child(http)


# Saves a config file in osu_config.json.
func save_config(c_id: String, c_sec: String) -> bool:
	var path = "user://osu_config.json"
	var data = {
		"client_id": c_id,
		"client_secret": c_sec
	}

	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Couldn't create file.")
		return false

	var json_text = JSON.stringify(data)
	file.store_string(json_text)
	file.close()
	return true


# Load config file from osu_config.json
func load_config() -> bool:
	var path = "user://osu_config.json"
	if not FileAccess.file_exists(path):
		push_error("Config file not found: %s" % path)
		return false

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Couldn't open config file")
		return false

	var content = file.get_as_text()
	file.close()


	var json = JSON.new()
	var parse_result = json.parse(content)

	# Case 3: Not valid profile data/Json format
	if parse_result != OK:
		push_error("JSON Parsing error: %s" % parse_result)
		return false

	var data = json.get_data()
	if not (data.has("client_id") and data.has("client_secret")):
		push_error("Invalid config file: no client_id or client_secret found")
		return false

	client_id = data.client_id
	client_secret = data.client_secret
	return true


# Requests a new token from osu! api
func _request_token() -> Dictionary:
	var body = {
		"client_id": client_id,
		"client_secret": client_secret,
		"grant_type": "client_credentials",
		"scope": "public"
	}

	var headers = ["Content-Type: application/json"]
	var json_body = JSON.stringify(body)

	var err = http.request("https://osu.ppy.sh/oauth/token", headers, HTTPClient.METHOD_POST, json_body)
	if err != OK:
		push_error("Error requesting token: %d" % err)
		return {}

	var response = await http.request_completed
	var result = response[0]
	var response_code = response[1]
	var r_headers = response[2]
	var body_bytes = response[3]

	return {
		"result": result,
		"response_code": response_code,
		"headers": r_headers,
		"body_bytes": body_bytes
	}


# Gets token 
func get_token() -> String:
	var now = Time.get_unix_time_from_system()
	if token_data.access_token == "" or now >= token_data.expires_at:
		var response = await _request_token()
		if response.response_code != 200:
			push_error("Get Token Failed. Code: %d" % response.response_code)
			return ""


		var body_text = response.body_bytes.get_string_from_utf8()
		var json = JSON.new()
		var parse_result = json.parse(body_text)

		if parse_result != OK:
			push_error("Error parsing token response: %s" % parse_result.error)
			return ""

		var res = json.get_data()
		token_data.access_token = res.access_token
		token_data.expires_at = Time.get_unix_time_from_system() + int(res.expires_in) - 5
		return token_data.access_token
	else:
		return token_data.access_token
