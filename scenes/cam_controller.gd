extends Node3D

@onready var camera = $Camera3D

var sensitivity := 0.0025

func _input(event):
	if event is InputEventScreenDrag:
		rotation.y -= event.relative.x * sensitivity
		#camera.rotation.x -= event.relative.y * sensitivity
