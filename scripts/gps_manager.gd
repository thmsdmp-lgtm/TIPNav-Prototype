extends Node
class_name GpsManager

# Hold references to the callbacks so they are not garbage collected
var _success_callback_ref: JavaScriptObject
var _error_callback_ref: JavaScriptObject

# ID returned by watchPosition()
var _watch_id := -1

@onready var labelContainer = $"../userInterface/CanvasLayer/Container"
@onready var startButton = $"../userInterface/CanvasLayer/StartButton"

@onready var latLabel = $"../userInterface/CanvasLayer/Container/Lat"
@onready var longLabel = $"../userInterface/CanvasLayer/Container/Long"
@onready var altLabel = $"../userInterface/CanvasLayer/Container/Alt"

@onready var posAccLabel = $"../userInterface/CanvasLayer/Container/PosAcc"
@onready var altAccLabel = $"../userInterface/CanvasLayer/Container/AltAcc"

# local vars for window and nav
var window
var navigator

# error and success signal when fetching data
signal gps_signal(val)

func _ready() -> void:
	pass

func check_access():
	
	var options = JavaScriptBridge.create_object("Object")
	options.enableHighAccuracy = true
	options.timeout = 10000
	options.maximumAge = 0
	
	navigator.geolocation.getCurrentPosition(_success_callback_ref, _error_callback_ref, options)
	
	var result = await gps_signal
	var access = result[0]
	var err = result[1]
	
	return [access,err]

func start_gps():
	print("Starting GPS watch...")

	if window == null:
		startButton.text = "FAILED TO GET WINDOW"
		return

	if navigator == null:
		startButton.text = "NO NAVIGATOR"
		return

	if navigator.geolocation == null:
		startButton.text = "NO GEOLOCATION"
		return

	var options = JavaScriptBridge.create_object("Object")
	options.enableHighAccuracy = true
	options.timeout = 10000
	options.maximumAge = 0

	_watch_id = navigator.geolocation.watchPosition(
		_success_callback_ref,
		_error_callback_ref,
		options
	)

	print("GPS Watch Started:", _watch_id)


func stop_gps():
	if _watch_id == -1:
		return

	window = JavaScriptBridge.get_interface("window")
	if window:
		window.navigator.geolocation.clearWatch(_watch_id)

	print("GPS Watch Stopped")

	_watch_id = -1

func _on_gps_success(args: Array) -> void:
	gps_signal.emit(true,null)

	var position = args[0]
	var coords = position.coords

	latLabel.text = "LATITUDE: " + str(coords.latitude)
	longLabel.text = "LONGITUDE: " + str(coords.longitude)
	altLabel.text = "ALTITUDE: " + str(coords.altitude)

	posAccLabel.text = "POSITION ACCURACY: " + str(coords.accuracy)
	altAccLabel.text = "ALTITUDE ACCURACY: " + str(coords.altitudeAccuracy)

	print("GPS Updated")

func _on_gps_error(args: Array) -> void:
	var error = args[0]
	
	gps_signal.emit(false,error.code)
	print("GPS Error:", error.code, error.message)

	match int(error.code):
		1:
			startButton.visible = true
			startButton.text = "ALLOW LOCATION ACCESS"
			window = JavaScriptBridge.get_interface("window")
			if window:
				window.alert("Please enable GPS/Location Services on your device.")
		2:
			startButton.visible = true
			startButton.text = "TURN ON GPS"

			window = JavaScriptBridge.get_interface("window")
			if window:
				window.alert("Please enable GPS/Location Services on your device.")

		3:
			startButton.visible = true
			startButton.text = "GPS TIMED OUT"

		_:
			startButton.visible = true
			startButton.text = "GPS ERROR"

func _on_start_button_pressed() -> void:
	if !OS.has_feature("web"):
		startButton.text = "NOT ON WEB"
		return
	
	window = JavaScriptBridge.get_interface("window")
	navigator = window.navigator

	_success_callback_ref = JavaScriptBridge.create_callback(_on_gps_success)
	_error_callback_ref = JavaScriptBridge.create_callback(_on_gps_error)
	
	var access = await check_access()
	if not access[0]:
		return
	
	# Prevent creating multiple watches
	if _watch_id != -1:
		return
	
	startButton.visible = false
	labelContainer.visible = true

	start_gps()


func _exit_tree():
	stop_gps()
