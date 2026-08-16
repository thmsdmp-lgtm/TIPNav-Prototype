# Category class for handling categories and classes
# returns a scene file in which you need to instantiate 
# add to scene tree using add_child()

#--------------------------------------#

extends Node
class_name CategoryHandler

# external
@export var categories:Array = ["buildings","rooms","facilities","offices"]

# internal
var updated:bool = false

#--------------------------------------#

# wait for updated
func _ready() -> void:
	await %DataHandler.assetUpdated
	updated = true

# get place from category (buildings , rooms , offices , facilities)
func get_p_from_cat(category:String,p_file_name:String):
	if !updated:
		print("WAIT FOR ASSET-UPDATED SIGNAL BEFORE CALLING CLASS")
		return
	
	var path := str("user://Assets/Categories/",category)
	var dir := DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir():
				
				if file_name == p_file_name:
					var file_path := str(path,"/",file_name)
					var place := load(file_path) as PackedScene
					return place
				
			file_name = dir.get_next()
	return

# get all place from a category
# returns an array
func get_all_p_from_cat(category:String):
	if !updated:
		print("WAIT FOR ASSET-UPDATED SIGNAL BEFORE CALLING CLASS")
		return
	if not category:
		return
	
	var path := str("user://Assets/Categories/",category)
	var dir := DirAccess.open(path)
	var places := []
	
	if dir:
		dir.list_dir_begin()
		
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir():
				var file_path := str(path,"/",file_name)
				
				var place := load(file_path) as PackedScene
				places.append(place)
				
			file_name = dir.get_next()
		
		return places
	return

# get place from file name
func get_p(p_file_name:String):
	if !updated:
		print("WAIT FOR ASSET-UPDATED SIGNAL BEFORE CALLING CLASS")
		return
	
	for cat in categories:
		var path := str("user://Assets/Categories/",cat)
		var dir := DirAccess.open(path)
		
		if dir:
			dir.list_dir_begin()
			
			var file_name = dir.get_next()
		
			while file_name != "":
				if not dir.current_is_dir():
					
					if file_name == p_file_name:
						var file_path := str(path,"/",file_name)
						var place := load(file_path) as PackedScene
						return place
				
				file_name = dir.get_next()
	return

# Get random place
func get_random_p():
	if not updated:
		print("WAIT FOR ASSET-UPDATED SIGNAL BEFORE CALLING CLASS")
		return
	
	var places: Array[PackedScene] = []
	
	for cat in categories:
		var path := "user://Assets/Categories/".path_join(cat)
		var dir := DirAccess.open(path)
		
		if dir:
			dir.list_dir_begin()
			
			var file_name := dir.get_next()
			
			while file_name != "":
				if not dir.current_is_dir() and file_name.ends_with(".tscn"):
					var file_path := path.path_join(file_name)
					var place := load(file_path) as PackedScene
					
					if place:
						places.append(place)
				
				file_name = dir.get_next()
			
			dir.list_dir_end()
	
	if places.is_empty():
		return
	
	return places.pick_random()
