@tool
extends Control
class_name CustomVerticalContainer

@export var spacing: float = 4.0:
	set(value):
		spacing = value
		update_layout()

func _ready() -> void:
	child_entered_tree.connect(func(_c):
		call_deferred("update_layout")
	)
	
	child_exiting_tree.connect(func(_c):
		call_deferred("update_layout")
	)

func update_layout() -> void:
	var y := 0.0

	for child in get_children():
		if !(child is Control):
			continue

		child.visible = true

		# Stretch horizontally
		child.anchor_left = 0.0
		child.anchor_right = 1.0
		child.anchor_top = 0.0
		child.anchor_bottom = 0.0

		child.offset_left = 0.0
		child.offset_right = 0.0

		# Stack vertically
		child.position.y = y

		y += child.size.y + spacing
		custom_minimum_size.y = max(0.0, y - spacing)
