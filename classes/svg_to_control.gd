@tool
extends Node
class_name svgToControl

## ---------------------------------------------------------------------------
## SVGToPanelImporter
## ---------------------------------------------------------------------------
## Reads an SVG file and rebuilds it as a tree of Control nodes under
## `target_panel`, applying each element's position, size and transform.
##
## INCLUDED:
##   - <g> groups           -> plain Control containers (holds children,
##                              carries the group's transform)
##   - <rect>                -> Panel + StyleBoxFlat (rx/ry become corner_radius)
##   - <circle> / <ellipse>  -> Panel + StyleBoxFlat, rounded to look circular
##   - <line> / <polygon> / <polyline> -> simple Control with custom _draw()
##   - transform="translate(...) rotate(...) scale(...)"
##
## IGNORED (by design):
##   - <path> (and anything inside it)
##   - <filter>, <feDropShadow>, <feGaussianBlur>, etc. (shadows/blur)
##   - <linearGradient>, <radialGradient>, <clipPath>, <mask>, <symbol>, <defs>
##   - <style> blocks (CSS is not parsed)
##   - <image> (embedded PNG/JPEG/raster images, whether linked or base64)
##
## USAGE:
##   1. Attach this script to any Node in your scene.
##   2. In the Inspector, set `svg_path` to your .svg file and `target_panel`
##      to the Control/Panel you want the shapes built under.
##   3. Tick the `import_now` checkbox in the Inspector (editor), or call
##      `import_svg_to_panel()` from code at runtime.
## ---------------------------------------------------------------------------

@export_file("*.svg") var svg_path: String
@export var target_panel: Control
@export var clear_target_before_import: bool = true

## Editor convenience: ticking this box runs the import immediately.
@export var import_now: bool = false:
	set(value):
		if value:
			import_svg_to_panel()
		import_now = false


func import_svg_to_panel() -> void:
	if svg_path.is_empty():
		push_error("SVGToPanelImporter: svg_path is empty.")
		return
	if target_panel == null:
		push_error("SVGToPanelImporter: target_panel is not set.")
		return

	var xml := XMLParser.new()
	var open_err := xml.open(svg_path)
	if open_err != OK:
		push_error("SVGToPanelImporter: could not open '%s' (error %d)" % [svg_path, open_err])
		return

	if clear_target_before_import:
		for c in target_panel.get_children():
			c.queue_free()

	var edited_root: Node = null
	if Engine.is_editor_hint() and target_panel.get_tree():
		edited_root = target_panel.get_tree().edited_scene_root

	var depth := 0
	var ignore_from_depth := -1          # -1 = not currently ignoring a subtree
	var parent_stack: Array[Control] = [target_panel]
	var group_depths: Array[int] = []    # depth at which each pushed group started

	while xml.read() == OK:
		var node_type := xml.get_node_type()

		if node_type == XMLParser.NODE_ELEMENT:
			var tag_name := xml.get_node_name()
			var is_empty := xml.is_empty()
			var attrs := _read_attributes(xml)
			var current_depth := depth
			if not is_empty:
				depth += 1

			if ignore_from_depth != -1:
				continue # inside an ignored subtree

			match tag_name:
				"path", "defs", "filter", "feDropShadow", "feGaussianBlur", \
				"feOffset", "feMerge", "feMergeNode", "feComposite", \
				"linearGradient", "radialGradient", "clipPath", "mask", \
				"symbol", "style", "image":
					if not is_empty:
						ignore_from_depth = current_depth
					continue

				"svg":
					continue # root wrapper only, just descend into children

				"g":
					var group := Control.new()
					group.name = attrs.get("id", "Group")
					group.mouse_filter = Control.MOUSE_FILTER_IGNORE
					_apply_transform(group, attrs.get("transform", ""))
					parent_stack[-1].add_child(group)
					if edited_root:
						group.owner = edited_root
					if not is_empty:
						parent_stack.append(group)
						group_depths.append(current_depth)
					continue

				"rect":
					_build_rect(parent_stack[-1], attrs, edited_root)
				"circle":
					_build_circle(parent_stack[-1], attrs, edited_root)
				"ellipse":
					_build_ellipse(parent_stack[-1], attrs, edited_root)
				"line":
					_build_line(parent_stack[-1], attrs, edited_root)
				"polygon":
					_build_polygon(parent_stack[-1], attrs, edited_root, true)
				"polyline":
					_build_polygon(parent_stack[-1], attrs, edited_root, false)
				_:
					pass # unsupported/unknown tag, skip quietly

		elif node_type == XMLParser.NODE_ELEMENT_END:
			depth -= 1
			if ignore_from_depth != -1:
				if depth == ignore_from_depth:
					ignore_from_depth = -1
				continue
			if not group_depths.is_empty() and depth == group_depths[-1]:
				group_depths.pop_back()
				parent_stack.pop_back()

	print("SVGToPanelImporter: import finished ('%s')." % svg_path)


# -----------------------------------------------------------------------
# Shape builders
# -----------------------------------------------------------------------

func _build_rect(parent: Control, attrs: Dictionary, edited_root: Node) -> void:
	var x := float(attrs.get("x", "0"))
	var y := float(attrs.get("y", "0"))
	var w := float(attrs.get("width", "0"))
	var h := float(attrs.get("height", "0"))
	# SVG allows rx/ry independently; StyleBoxFlat only has one radius per
	# corner, so we fall back to whichever of rx/ry is present.
	var radius := int(float(attrs.get("rx", attrs.get("ry", "0"))))

	var panel := Panel.new()
	panel.name = attrs.get("id", "Rect")
	panel.position = Vector2(x, y)
	panel.size = Vector2(w, h)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = _parse_fill(attrs)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	panel.add_theme_stylebox_override("panel", style)

	_apply_transform(panel, attrs.get("transform", ""))
	parent.add_child(panel)
	if edited_root:
		panel.owner = edited_root


func _build_circle(parent: Control, attrs: Dictionary, edited_root: Node) -> void:
	var cx := float(attrs.get("cx", "0"))
	var cy := float(attrs.get("cy", "0"))
	var r := float(attrs.get("r", "0"))

	var panel := Panel.new()
	panel.name = attrs.get("id", "Circle")
	panel.position = Vector2(cx - r, cy - r)
	panel.size = Vector2(r * 2.0, r * 2.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = _parse_fill(attrs)
	var radius := int(r)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	panel.add_theme_stylebox_override("panel", style)

	_apply_transform(panel, attrs.get("transform", ""))
	parent.add_child(panel)
	if edited_root:
		panel.owner = edited_root


func _build_ellipse(parent: Control, attrs: Dictionary, edited_root: Node) -> void:
	var cx := float(attrs.get("cx", "0"))
	var cy := float(attrs.get("cy", "0"))
	var rx := float(attrs.get("rx", "0"))
	var ry := float(attrs.get("ry", "0"))

	var panel := Panel.new()
	panel.name = attrs.get("id", "Ellipse")
	panel.position = Vector2(cx - rx, cy - ry)
	panel.size = Vector2(rx * 2.0, ry * 2.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = _parse_fill(attrs)
	# NOTE: StyleBoxFlat corners are circular, not elliptical, so a very
	# "flat" ellipse will look like a rounded rect rather than a true oval.
	# This is the accepted simplification for "rounded corner pixels".
	var radius := int(min(rx, ry))
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	panel.add_theme_stylebox_override("panel", style)

	_apply_transform(panel, attrs.get("transform", ""))
	parent.add_child(panel)
	if edited_root:
		panel.owner = edited_root


func _build_line(parent: Control, attrs: Dictionary, edited_root: Node) -> void:
	var x1 := float(attrs.get("x1", "0"))
	var y1 := float(attrs.get("y1", "0"))
	var x2 := float(attrs.get("x2", "0"))
	var y2 := float(attrs.get("y2", "0"))
	var stroke_width := float(attrs.get("stroke-width", "1"))

	var delta := Vector2(x2 - x1, y2 - y1)
	var length := delta.length()

	var panel := Panel.new()
	panel.name = attrs.get("id", "Line")
	panel.position = Vector2(x1, y1 - stroke_width * 0.5)
	panel.size = Vector2(length, stroke_width)
	panel.pivot_offset = Vector2(0.0, stroke_width * 0.5)
	panel.rotation = delta.angle()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = _parse_stroke(attrs)
	panel.add_theme_stylebox_override("panel", style)

	_apply_transform(panel, attrs.get("transform", ""))
	parent.add_child(panel)
	if edited_root:
		panel.owner = edited_root


func _build_polygon(parent: Control, attrs: Dictionary, edited_root: Node, closed: bool) -> void:
	var points_str: String = attrs.get("points", "")
	var num_regex := RegEx.new()
	num_regex.compile("-?[0-9]*\\.?[0-9]+")

	var nums: Array[float] = []
	for m in num_regex.search_all(points_str):
		nums.append(float(m.get_string()))

	var points := PackedVector2Array()
	var i := 0
	while i + 1 < nums.size():
		points.append(Vector2(nums[i], nums[i + 1]))
		i += 2

	if points.is_empty():
		return

	# Bounding box: the Control's position/size matches the shape's bounds,
	# and points are stored local to it, so `_apply_transform` still works.
	var min_pt := points[0]
	var max_pt := points[0]
	for p in points:
		min_pt = min_pt.min(p)
		max_pt = max_pt.max(p)

	var local_points := PackedVector2Array()
	for p in points:
		local_points.append(p - min_pt)

	var control := Control.new()
	control.name = attrs.get("id", "Polygon" if closed else "Polyline")
	control.position = min_pt
	control.size = max_pt - min_pt
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var fill_color := _parse_fill(attrs)
	var stroke_color := _parse_stroke(attrs)
	var stroke_width := float(attrs.get("stroke-width", "1"))

	control.draw.connect(func():
		if closed:
			control.draw_colored_polygon(local_points, fill_color)
		else:
			control.draw_polyline(local_points, stroke_color, stroke_width)
	)

	_apply_transform(control, attrs.get("transform", ""))
	parent.add_child(control)
	if edited_root:
		control.owner = edited_root


# -----------------------------------------------------------------------
# Attribute / transform / color helpers
# -----------------------------------------------------------------------

func _read_attributes(xml: XMLParser) -> Dictionary:
	var attrs := {}
	for i in xml.get_attribute_count():
		attrs[xml.get_attribute_name(i)] = xml.get_attribute_value(i)
	return attrs


func _apply_transform(control: Control, transform_str: String) -> void:
	if transform_str.is_empty():
		return

	var translate := Vector2.ZERO
	var scale := Vector2.ONE
	var rotation_deg := 0.0

	var func_regex := RegEx.new()
	func_regex.compile("(\\w+)\\(([^)]*)\\)")
	var num_regex := RegEx.new()
	num_regex.compile("-?[0-9]*\\.?[0-9]+")
	
	for fm in func_regex.search_all(transform_str):
		var func_name := fm.get_string(1)
		var raw_args := fm.get_string(2)
		
		var args: Array[float] = []
		for nm in num_regex.search_all(raw_args):
			args.append(float(nm.get_string()))
		
		match func_name:
			"translate":
				if args.size() >= 1:
					translate.x += args[0]
				if args.size() >= 2:
					translate.y += args[1]
			"scale":
				if args.size() >= 1:
					scale.x *= args[0]
					scale.y *= (args[0] if args.size() < 2 else args[1])
			"rotate":
				if args.size() >= 1:
					rotation_deg += args[0]
					# rotate(angle, cx, cy) pivot form is not applied here;
					# only the plain rotation angle is honored.
			"matrix":
				# matrix(a,b,c,d,e,f) - approximate: use e,f as translation
				# and skip the shear/skew part (kept simple on purpose).
				if args.size() >= 6:
					translate.x += args[4]
					translate.y += args[5]

	control.position += translate
	control.scale = scale
	control.rotation_degrees += rotation_deg


func _parse_fill(attrs: Dictionary) -> Color:
	var fill_str: String = attrs.get("fill", "")
	if fill_str.is_empty() and attrs.has("style"):
		var style_regex := RegEx.new()
		style_regex.compile("fill:\\s*([^;]+)")
		var m := style_regex.search(attrs["style"])
		if m:
			fill_str = m.get_string(1).strip_edges()
	fill_str = fill_str.strip_edges()

	var color := Color.BLACK

	if fill_str.is_empty() or fill_str == "none":
		color = Color(1.0, 1.0, 1.0, 0.0)
	elif fill_str.begins_with("url("):
		color = Color(0.6, 0.6, 0.6, 1.0) # gradient/pattern fallback (ignored)
	elif fill_str.begins_with("rgb"):
		var nums := RegEx.new()
		nums.compile("[0-9.]+")
		var vals: Array[float] = []
		for nm in nums.search_all(fill_str):
			vals.append(float(nm.get_string()))
		if vals.size() >= 3:
			var a := 1.0 if vals.size() < 4 else vals[3]
			color = Color(vals[0] / 255.0, vals[1] / 255.0, vals[2] / 255.0, a)
	else:
		color = Color.from_string(fill_str, Color.BLACK)

	if attrs.has("fill-opacity"):
		color.a *= float(attrs["fill-opacity"])
	if attrs.has("opacity"):
		color.a *= float(attrs["opacity"])

	return color


func _parse_stroke(attrs: Dictionary) -> Color:
	var stroke_attrs := attrs.duplicate()
	stroke_attrs["fill"] = attrs.get("stroke", "#000000")
	stroke_attrs.erase("style") # avoid re-reading fill: from style for stroke
	return _parse_fill(stroke_attrs)
