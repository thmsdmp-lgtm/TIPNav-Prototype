# script for testing categoryhandler class

extends Node

func _ready() -> void:
	await %DataHandler.assetUpdated
	var place = %CategoryHandler.get_all_p_from_cat("buildings")
	print(place)
