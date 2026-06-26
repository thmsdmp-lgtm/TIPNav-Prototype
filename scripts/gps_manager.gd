extends Node

# Hold references to the callbacks so they are not garbage collected
var _success_callback_ref: JavaScriptObject
var _error_callback_ref: JavaScriptObject

# Store the watch ID so we can stop tracking if needed
var _watch_id: int = -1

@onready var latLabel = $"../userInterface/CanvasLayer/Container/Lat"
@onready var longLabel = $"../userInterface/CanvasLayer/Container/Long"

func _ready() -> void:
	if OS.has_feature("web"):
		_success_callback_ref = JavaScriptBridge.create_callback(_on_gps_success)
		_error_callback_ref = JavaScriptBridge.create_callback(_on_gps_error)
		start_tracking()
	else:
		latLabel.text = "NOT ON BROWSER"
		longLabel.text = "NOT ON BROWSER"
		print("GPS retrieval via JavaScriptBridge is only supported on Web builds.")

func start_tracking() -> void:
	var window = JavaScriptBridge.get_interface("window")
	if not window: return
		
	var navigator = window.navigator
	if not navigator or not navigator.geolocation: return

	# Configure options for maximum sensitivity
	var options = JavaScriptBridge.create_object("Object")
	options.enableHighAccuracy = true
	options.timeout = INF # Don't timeout, keep listening
	options.maximumAge = 0        # Force fresh hardware readings, do not use cached positions

	# watchPosition automatically runs _on_gps_success whenever the phone moves
	_watch_id = navigator.watchPosition(_success_callback_ref, _error_callback_ref, options)
	print("Started campus tracking with Watch ID: ", _watch_id)

func _on_gps_success(args: Array) -> void:
	var position = args[0]
	var coords = position.coords
	
	var latitude = coords.latitude
	var longitude = coords.longitude
	var accuracy = coords.accuracy
	
	latLabel.text = str(latitude)
	longLabel.text = str(longitude)
	
	print("Movement Detected! Lat: ", latitude, " | Long: ", longitude, " | Accuracy: ", accuracy)

func _on_gps_error(args: Array) -> void:
	var error = args[0]
	print("GPS Error code: ", error.code, " | Message: ", error.message)

# Optional: Clean up the sensor listener when this node leaves the scene
func _exit_tree() -> void:
	if OS.has_feature("web") and _watch_id != -1:
		var window = JavaScriptBridge.get_interface("window")
		if window and window.navigator and window.navigator.geolocation:
			window.navigator.geolocation.clearWatch(_watch_id)
