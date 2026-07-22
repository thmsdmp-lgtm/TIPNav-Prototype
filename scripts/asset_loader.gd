extends Node

# fires when the data are updated
func _on_asset_fetcher_asset_updated() -> void:
	# check if sample scene exists
	var scene_path = "user://Assets/sample_scene.tscn"
	if not FileAccess.file_exists(scene_path):
		print("Scene file does not exist at: ", scene_path)
		return
	
	# Load the PackedScene resource from user://
	var packed_scene = ResourceLoader.load(scene_path) as PackedScene
	
	if packed_scene:
		# switch scenes
		get_tree().change_scene_to_packed(packed_scene)
	else:
		print("Failed to load scene resource from: ", scene_path)
