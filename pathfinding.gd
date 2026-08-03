#--PATH FINDER CLASS--
#------------------------
#-API-
#--------------------------------
#-GENERATE PATH
#> get a path from 2 vector3s
#---------------------------------
#-VISUALIZE PATH
#> visualize a path, should input an array of vector3s
#---------------------------------------------------------

extends Node3D
class_name  Pathfinding

var navigation_map:RID
var path3D: Path3D
var multi_mesh_instance: MultiMeshInstance3D
var visual_path_resolution:float = .1

func _ready() -> void:
	navigation_map = get_world_3d().get_navigation_map()
	
	path3D = Path3D.new()
	add_child(path3D)
	
	multi_mesh_instance = MultiMeshInstance3D.new()
	path3D.add_child(multi_mesh_instance)

func generate_path(from:Vector3,to:Vector3):
	var calculatedPath = NavigationServer3D.map_get_path(
		navigation_map,
		from,
		to,
		true
	)
	
	if calculatedPath:
		return calculatedPath

func visualize_path(paths: Array[Vector3],mesh:Mesh) -> void:
	var curve := Curve3D.new()
	for pos in paths:
		curve.add_point(pos)
	path3D.curve = curve
	
	var path_length := curve.get_baked_length()
	if path_length <= 0.0:
		return
	
	var transforms: Array[Transform3D] = []
	
	var distance := 0.0
	while distance < path_length:
		var pos := curve.sample_baked(distance, true)
		transforms.append(Transform3D(Basis(), pos))
		distance += visual_path_resolution
	
	# include the final point
	var end_pos := curve.sample_baked(path_length, true)
	transforms.append(Transform3D(Basis(), end_pos))
	
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = transforms.size()
	
	for i in transforms.size():
		mm.set_instance_transform(i, transforms[i])
	multi_mesh_instance.multimesh = mm
