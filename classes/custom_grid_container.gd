@tool
extends Panel
class_name CustomGridContainer

@export var spacing: float = 4.0:
	set(value):
		spacing = value
		update_layout()

func _process(delta: float) -> void:
	update_layout()

func update_layout() -> void:
	var children: Array[Control] = []

	for child in get_children():
		if child is Control:
			children.append(child)

	var count := children.size()
	if count == 0:
		return

	# Compute a nearly square grid
	var columns := ceili(sqrt(count))
	var rows := ceili(float(count) / columns)

	var cell_width := 1.0 / columns
	var cell_height := 1.0 / rows

	for i in range(count):
		var child := children[i]

		var row := i / columns
		var column := i % columns

		child.visible = true

		child.anchor_left = column * cell_width
		child.anchor_right = (column + 1) * cell_width
		child.anchor_top = row * cell_height
		child.anchor_bottom = (row + 1) * cell_height

		child.offset_left = spacing * 0.5
		child.offset_right = -spacing * 0.5
		child.offset_top = spacing * 0.5
		child.offset_bottom = -spacing * 0.5
