# class for fetching assets stored inside
# a single scene file in a repository

#--------------------------------------#

extends Node

@export var httpRequest: HTTPRequest

var repoUrl = "https://raw.githubusercontent.com/thmsdmp-lgtm/TIPNav-Assets/refs/heads/main/data/assets.tscn"
signal assetUpdated


func _ready() -> void:
	# connections
	httpRequest.request_completed.connect(req_success)
	
	# delete old assets/data
	delete_old_assets()
	
	# get updated assets/data
	request_data()


func request_data() -> void:
	var err = httpRequest.request(repoUrl)
	
	if err != OK:
		print("Failed to fetch asset: ", err)


func req_success(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("Download failed with HTTP response code: ", response_code)
		print("Requesting again..")
		request_data()
		return
	
	print("Downloaded updated assets")
	
	# Save the downloaded TSCN directly in user://
	var asset_path := "user://assets.tscn"
	var file := FileAccess.open(asset_path, FileAccess.WRITE)
	
	if file == null:
		print("Failed to save assets.tscn")
		return
	
	file.store_buffer(body)
	file.close()
	
	print("Saved assets to: ", asset_path)
	
	# Fire updated signal
	assetUpdated.emit()


func delete_old_assets() -> void:
	var asset_path := "user://assets.tscn"
	
	if FileAccess.file_exists(asset_path):
		var err := DirAccess.remove_absolute(asset_path)
		
		if err == OK:
			print("Old assets.tscn deleted")
		else:
			print("Failed to delete old assets.tscn. Error code: ", err)
	else:
		print("No old assets.tscn found")
