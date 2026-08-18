# Category class for handling categories and places

#--------------------------------------#

#place
#- a dictionary containing information about a certain place
#
#get_panel()
#- returns an instantiated scene of the panel, only need to
#.add_child(panel) when called
#
#get_about()
#- returns an instantiated scene of the about page, only need to
#.add_child(panel) when called
#
#get_p(p_file_name:String)
#- returns a place with the same name as p_file_name
#
#get_random_p():
#- returns a random place
#
#get_all_p_from_cat(category:String)
#- returns a dictionary of places with the same category

#--------------------------------------#

extends Node
class_name PlaceProvider

# internal
@export_file_path("*.gd") var PlaceManager

signal active
var updated:bool = false
var categories:Array = []
var places:Dictionary = {
	# "name (folder name in asset repo)" : {
	#		"name" : name or place key in internal places table
	#		"category" : category string
	#		"panel_scene" : panel scene file,
	#		"about_scene" : about scene file
	#	}
}

#--------------------------------------#

# construct data
func _ready() -> void:
	await %DataManager.assetUpdated
	
	# get categories from Categories subfolder in Assets
	var path := "user://Assets/Categories"
	var dir := DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var cat_name = dir.get_next()
		
		while cat_name != "":
			if dir.current_is_dir():
				categories.append(cat_name)
			cat_name = dir.get_next()
		dir.list_dir_end()
	
	# construct place table
	for cat in categories:
		var cat_path := "user://Assets/Categories".path_join(cat)
		var cat_dir := DirAccess.open(cat_path)
		
		if cat_dir:
			cat_dir.list_dir_begin()
			var place_name := cat_dir.get_next()
			
			while place_name != "":
				# get panel
				var panel_path := cat_path.path_join(place_name).path_join("panel.tscn")
				var panel_scene := load(panel_path) as PackedScene
				# get about
				var about_path := cat_path.path_join(place_name).path_join("about.tscn")
				var about_scene := load(about_path) as PackedScene
				
				# construct
				places.set(place_name,{
					"name" : place_name,
					"category" : cat,
					"panel_scene" : panel_scene,
					"about_scene" : about_scene,
				})
				place_name = cat_dir.get_next()
			cat_dir.list_dir_end()
	
	updated = true
	active.emit()

# get panel from place, then attach script
func get_panel(place:Dictionary):
	if not PlaceManager:
		print("CANNOT FETCH AND SETUP, PLEASE SET PLACE MANAGER FOR PLACEPROVIDER")
	if !updated:
		print("WAIT FOR ASSET-UPDATED SIGNAL BEFORE CALLING CLASS")
		return
	if place.is_empty():
		print("COULD NOT FETCH AND SETUP PANEL, TABLE EMPTY")
		return
	if not place: return
	
	var panel = place.panel_scene
	panel = panel.instantiate()
	panel.set_script(load(PlaceManager))
	panel.data = place.duplicate(true)
	return panel

# get panel from place. (about page transition will be handled
# by another script which is instantiated by the panel script)
func get_about(place:Dictionary):
	if !updated:
		print("WAIT FOR ASSET-UPDATED SIGNAL BEFORE CALLING CLASS")
		return
	if place.is_empty():
		print("COULD NOT FETCH ABOUT, TABLE EMPTY")
		return
	if not place: return
	
	var about = place.panel_scene
	about = about.instantiate()
	return about

# get place from category (buildings , rooms , offices , facilities)
func get_p_from_cat(category:String,p_file_name:String):
	if !updated:
		print("WAIT FOR ASSET-UPDATED SIGNAL BEFORE CALLING CLASS")
		return
	if places.is_empty() or categories.is_empty():
		print("COULD NOT FETCH, CACHE EMPTY. CHECK ASSET REPO STRUCTURE")
		return
	if not category or not p_file_name: return
	
	var place = places[p_file_name]
	if place["category"] == category:
		return place
	return

# get all place from a category
# returns an array
func get_all_p_from_cat(category:String):
	if !updated:
		print("WAIT FOR ASSET-UPDATED SIGNAL BEFORE CALLING CLASS")
		return
	if places.is_empty() or categories.is_empty():
		print("COULD NOT FETCH, CACHE EMPTY. CHECK ASSET REPO STRUCTURE")
		return
	if not category:
		return
	
	var final_p := {}
	
	for p_name in places:
		if places[p_name]["category"] == category:
			final_p.set(p_name,places[p_name]["panel_scene"])
	return final_p

# get place from file name
func get_p(p_file_name:String):
	if !updated:
		print("WAIT FOR ASSET-UPDATED SIGNAL BEFORE CALLING CLASS")
		return
	if places.is_empty() or categories.is_empty():
		print("COULD NOT FETCH, CACHE EMPTY. CHECK ASSET REPO STRUCTURE")
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
	if places.is_empty() or categories.is_empty():
		print("COULD NOT FETCH, CACHE EMPTY. CHECK ASSET REPO STRUCTURE")
		return
	
	var p_name = places.keys().pick_random()
	return places[p_name]
