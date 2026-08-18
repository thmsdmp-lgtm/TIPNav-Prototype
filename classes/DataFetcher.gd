# class for fetching assets stored inside
# a repository

#--------------------------------------#

extends Node
class_name DataFetcher

@export var httpRequest:HTTPRequest
var repoUrl = "https://github.com/thmsdmp-lgtm/TIPNav-Assets/archive/refs/heads/main.zip"
signal assetUpdated

func _ready() -> void:
	# connections
	httpRequest.request_completed.connect(req_success)
	
	# wipe old assets / data if found
	delete_user_folder("user://Assets")
	
	# get updated assets / data
	var err = httpRequest.request(repoUrl)
	if err != OK:
		print("Failed to fetch asset")

func req_success(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("Download failed with HTTP response code: ", response_code)
		return
	print("downloaded updated assets")
	
	# Save as zip file in user:// (browser IndexedDB)
	var zip_path = "user://updated_assets.zip"
	var file = FileAccess.open(zip_path, FileAccess.WRITE)
	
	if file:
		file.store_buffer(body)
		file.close()
		print("Saved ZIP to: ", zip_path)
	
	# extract new assets
	unpack("user://updated_assets.zip","user://")
	
	# rename folder
	rename_folder("user://TIPNav-Assets-main","user://Assets")
	
	# wipe downloaded zip
	delete_file("user://updated_assets.zip")
	
	# print new contents
	#print_user_dir_contents("user://Assets")
	
	# fire updated signal
	assetUpdated.emit()

func unpack(zip_path: String, destination: String = "") -> void:
	var reader = ZIPReader.new()
	var err = reader.open(zip_path)
	if err != OK:
		print("Failed to open zip file. Error code: ", err)
		return

	# Base target path inside user://
	var target_base_path = destination

	var files = reader.get_files()
	for file_path in files:
		var destination_path = target_base_path.path_join(file_path)

		# Check if the entry is a directory (ends with '/')
		if file_path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(destination_path)
			continue

		# Ensure parent folders exist for files inside subdirectories
		var parent_dir = destination_path.get_base_dir()
		if not DirAccess.dir_exists_absolute(parent_dir):
			DirAccess.make_dir_recursive_absolute(parent_dir)

		# Write the extracted file
		var file_data = reader.read_file(file_path)
		var file = FileAccess.open(destination_path, FileAccess.WRITE)
		if file:
			file.store_buffer(file_data)
			file.close()
	
	reader.close()

func rename_folder(old_path: String, new_path: String) -> void:
	var err = DirAccess.rename_absolute(old_path, new_path)
	
	if err != OK:
		print("Failed to rename folder. Error code: ", err)

func print_user_dir_contents(path:String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir():
				print("[DIR]  user://", file_name)
			else:
				print("[FILE] user://", file_name)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	else:
		print("Failed to open user:// directory.")

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

func delete_file(file_path: String) -> void:
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		print("File successfully deleted: ", file_path)
	else:
		print("File does not exist: ", file_path)
