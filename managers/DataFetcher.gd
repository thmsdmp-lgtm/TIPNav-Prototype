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
	
	# wipe old assets / data if found
	delete_user_folder("user://Assets")
	
	# get updated assets / data
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
	
	# Create Assets folder
	var folder_path := "user://Assets"
	
	if !DirAccess.dir_exists_absolute(folder_path):
		var dir_err := DirAccess.make_dir_recursive_absolute(folder_path)
		
		if dir_err != OK:
			print("Failed to create Assets folder: ", dir_err)
			return
	
	# Save the downloaded TSCN
	var asset_path := "user://Assets/assets.tscn"
	var file := FileAccess.open(asset_path, FileAccess.WRITE)
	
	if file == null:
		print("Failed to save assets.tscn")
		return
	
	file.store_buffer(body)
	file.close()
	
	print("Saved assets to: ", asset_path)
	
	# Fire updated signal
	assetUpdated.emit()

func delete_user_folder(path: String) -> void:
	var full_path = path

	if DirAccess.dir_exists_absolute(full_path):
		_delete_dir_recursive(full_path)
		print("Folder successfully deleted: ", full_path)
	else:
		print("Folder does not exist: ", full_path)

func _delete_dir_recursive(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if file_name != "." and file_name != "..":
				var item_path = path.path_join(file_name)
				if dir.current_is_dir():
					_delete_dir_recursive(item_path) # Recurse into subfolder
				else:
					DirAccess.remove_absolute(item_path) # Remove file
			file_name = dir.get_next()

		dir.list_dir_end()
		DirAccess.remove_absolute(path) # Remove the now-empty folder
