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

# internal
var PlaceManager = "res://managers/PlaceManager.gd"

signal active
var updated:bool = false
var categories:Array = []
var assets:Control
var places:Dictionary = {
	# "name (folder name in asset repo)" : {
	#		"name" : name or place key in internal places table
	#		"category" : category string
	#		"panel" : panel scene file,
	#		"about" : about scene file
	#	}
}

#--------------------------------------#

# construct data
func _ready() -> void:
	await DataFetcher.assetUpdated
	
	# get assets
	var scene:PackedScene = load("user://assets.tscn")
	assets = scene.instantiate()
	
	# construct
	for child in assets.get_children():
		
		# get place tree
		if child.name == "places":
			
			# loop categories
			for cat in child.get_children():
				
				# store category
				categories.append(cat.name)
				
				# get places
				for place in cat.get_children():
					
					# get info
					var name:String = place.name
					var about:Control = place.get_node("about")
					var panel:Control = place.get_node("panel")
					if not about or not panel: return
					
					# store info
					places.set(name,{
						"name":name,
						"category":cat.name,
						"panel":panel,
						"about":about,
					})
	
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
	
	var panel = place.panel.duplicate()
	panel.set_script(load(PlaceManager))
	
	var data = place.duplicate(true)
	data.panel = place.panel.duplicate()
	data.about = place.about.duplicate()
	panel.data = data
	
	return panel

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
			final_p.set(p_name,places[p_name]["panel"])
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
