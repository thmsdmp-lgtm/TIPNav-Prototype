# Category class for handling categories and classes
# returns an array containing the scene and category of the place
# instantiate scene using .instantiate() then .add_child()

#--------------------------------------#

extends Node
class_name CategoryHandler

# external
@export var categories:Array = []

# internal
signal active
var updated:bool = false
var places:Dictionary = {
	# "filename" : {
	#		"name" : name or place key in internal places table
	#		"scene" : scene file,
	#		"category" : category string
	#	}
}

#--------------------------------------#

# wait for updated
func _ready() -> void:
	await %DataHandler.assetUpdated
	
	# get categories from Categories subfolder in Assets
	var catFol := "user://Assets/Categories"
	var catDir := DirAccess.open(catFol)
	if catDir:
		catDir.list_dir_begin()
		
		var catName := catDir.get_next()
		
		while catName != "":
			if catDir.current_is_dir():
				categories.append(catName)
			catName = catDir.get_next()
		catDir.list_dir_end()
	
	# load all places and construct an dictionary of them
	for cat in categories:
		var path := "user://Assets/Categories".path_join(cat)
		var dir := DirAccess.open(path)
		
		if dir:
			dir.list_dir_begin()
			
			var p_name := dir.get_next()
			
			while p_name != "":
				if not dir.current_is_dir() and p_name.ends_with(".tscn"):
					var p_path := path.path_join(p_name)
					var scene := load(p_path) as PackedScene
					
					if scene:
						var place := {
							"name" : p_name.get_basename(),
							"scene" : scene,
							"category" : cat,
						}
						places.set(p_name.get_basename(),place)
				p_name = dir.get_next()
			dir.list_dir_end()
	
	updated = true
	active.emit()

# get place from category (buildings , rooms , offices , facilities)
func get_p_from_cat(category:String,p_file_name:String):
	if !updated:
		print("WAIT FOR ASSET-UPDATED SIGNAL BEFORE CALLING CLASS")
		return
	if not category or not p_file_name: return
	var place = places[p_file_name]
	if place["category"] == category:
		return place
	return

# get all place from a category
# returns an array, "name" : scene
func get_all_p_from_cat(category:String):
	if !updated:
		print("WAIT FOR ASSET-UPDATED SIGNAL BEFORE CALLING CLASS")
		return
	if not category:
		return
	
	var final_p := {}
	
	for p_name in places:
		if places[p_name].category == category:
			final_p.set(p_name,places[p_name]["scene"])
	return final_p


# get place from file name
func get_p(p_file_name:String):
	if !updated:
		print("WAIT FOR ASSET-UPDATED SIGNAL BEFORE CALLING CLASS")
		return
	if not p_file_name: return
	
	for p_name in places:
		if p_name == p_file_name:
			return places[p_name]
	return

# Get random place
func get_random_p():
	if not updated:
		print("WAIT FOR ASSET-UPDATED SIGNAL BEFORE CALLING CLASS")
		return
	
	var p_name = places.keys().pick_random()
	return places[p_name]
