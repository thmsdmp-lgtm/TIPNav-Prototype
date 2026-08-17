extends Control
class_name HomePage

# external
@export_file("*.tscn") var category_template
@export var category_Container:Control
@export var suggested_Container_1:Control
@export var suggested_Container_2:Control

# internal
var cat_templ_scene:PackedScene

func _ready() -> void:
	await %CategoryHandler.active
	
	# load shit
	cat_templ_scene = load(category_template) as PackedScene
	
	# fill suggestion containers
	fill_suggestions()
	
	# fill categories
	fill_categories()

# enter tab
func enter():
	visible = true

# exit tab
func exit():
	visible = false

# fill categories
func fill_categories():
	for child in category_Container.get_children():
		child.queue_free()
	for cat in %CategoryHandler.categories:
		var category = cat_templ_scene.instantiate()
		category.get_node("Label").text = cat
		category_Container.add_child(category)

# fill suggestion containers
func fill_suggestions():
	if !suggested_Container_1 or !suggested_Container_2: return
	
	# fill container 1
	for child:Control in suggested_Container_1.get_children():
		child.queue_free()
	for i in 5:
		var place = %CategoryHandler.get_random_p()
		if not place: continue
		
		var place_scene = place["scene"]
		if not place_scene: continue
		
		place_scene = place_scene.instantiate()
		suggested_Container_1.add_child(place_scene)
	
	# fill container 2
	for child:Control in suggested_Container_2.get_children():
		child.queue_free()
	for i in 5:
		var place = %CategoryHandler.get_random_p()
		if not place: continue
		
		var place_scene = place["scene"]
		if not place_scene: continue
		
		place_scene = place_scene.instantiate()
		suggested_Container_2.add_child(place_scene)
