# script for testing categoryhandler class

extends Node

func _ready() -> void:
	await %DataHandler.assetUpdated
	var places = %CategoryHandler.get_random_p()
	print(places)
