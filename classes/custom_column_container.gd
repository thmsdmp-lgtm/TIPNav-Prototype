@tool
extends Control
class_name CustomColumnContainer

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
	var children: Array[Control] = []
	
	for child in get_children():
		if child is Control:
			children.append(child)

	var count := children.size()
	if count == 0:
		return

	var cell_width := 1.0 / count

	for i in range(count):
		var child := children[i]

		child.visible = true

		# Stretch each child equally across the width
		child.anchor_left = i * cell_width
		child.anchor_right = (i + 1) * cell_width
		child.anchor_top = 0.0
		child.anchor_bottom = 1.0

		child.offset_left = spacing * 0.5
		child.offset_right = -spacing * 0.5
		child.offset_top = spacing * 0.5
		child.offset_bottom = -spacing * 0.5
