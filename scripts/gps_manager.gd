extends Node

# Hold references to the callbacks so they are not garbage collected
var _success_callback_ref: JavaScriptObject
var _error_callback_ref: JavaScriptObject

@onready var latLabel = $"../userInterface/CanvasLayer/Container/Lat"
@onready var longLabel = $"../userInterface/CanvasLayer/Container/Long"

func _ready() -> void:
	# Only execute if we are running in a web browser export
	if OS.has_feature("web"):
		_success_callback_ref = JavaScriptBridge.create_callback(_on_gps_success)
		_error_callback_ref = JavaScriptBridge.create_callback(_on_gps_error)
		request_gps_location()
	else:
		latLabel.text = "NOT ON BROWRSER"
		longLabel.text = "NOT ON BROWRSER"
		print("GPS retrieval via JavaScriptBridge is only supported on Web builds.")

func request_gps_location() -> void:
	var window = JavaScriptBridge.get_interface("window")
	if not window:
		print("Failed to get window interface.")
		latLabel.text = "FAILED TO GET WINDOW"
		return
		
	var navigator = window.navigator
	if not navigator or not navigator.geolocation:
		latLabel.text = "FAILED TO GET GPS OR NOT SUPPORTED"
		print("Geolocation is not supported by this browser.")
		return
	
	# Create JavaScript options: { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 }

	var options = JavaScriptBridge.create_object("Object")
	options.enableHighAccuracy = true
	options.timeout = 5000
	options.maximumAge = 0
	
	# Call navigator.geolocation.getCurrentPosition(success_callback, error_callback)
	navigator.geolocation.getCurrentPosition(_success_callback_ref, _error_callback_ref,options)

func _on_gps_success(args: Array) -> void:
	# args[0] contains the JavaScript 'position' object
	var position = args[0]
	var coords = position.coords
	
	var latitude = coords.latitude
	var longitude = coords.longitude
	var accuracy = coords.accuracy
	
	latLabel.text = str(latitude)
	longLabel.text = str(longitude)
	print("Latitude: ", latitude)
	print("Longitude: ", longitude)
	print("Accuracy (meters): ", accuracy)

func _on_gps_error(args: Array) -> void:
	# args[0] contains the JavaScript 'GeolocationPositionError' object
	var error = args[0]
	print("Error code: ", error.code, " | Message: ", error.message)

func _process(delta: float) -> void:
	await get_tree().create_timer(.5).timeout
	if OS.has_feature("web"):
		request_gps_location()
