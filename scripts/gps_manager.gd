extends Node
class_name GpsManager

# ID returned by watchPosition()
var _watch_id := -1

@onready var labelContainer = $"../UI/CanvasLayer/Container"
@onready var startButton = $"../UI/CanvasLayer/StartButton"
@onready var latLabel = $"../UI/CanvasLayer/Container/Lat"
@onready var longLabel = $"../UI/CanvasLayer/Container/Long"
@onready var altLabel = $"../UI/CanvasLayer/Container/Alt"
@onready var posAccLabel = $"../UI/CanvasLayer/Container/PosAcc"

# local vars for window and nav
var window
var navigator

# class variables
var direction = 0
var position = {
	"latitude":0,
	"longitude":0,
	"altitude":0,
	"accuracy":0
}

# Hold references to the callbacks so they are not garbage collected
var _success_callback_ref: JavaScriptObject
var _error_callback_ref: JavaScriptObject

# signals
# error and success signal when fetching data
signal gps_signal(val)
signal gps_changed(args)

func _ready() -> void:
	_success_callback_ref = JavaScriptBridge.create_callback(_on_gps_success)
	_error_callback_ref = JavaScriptBridge.create_callback(_on_gps_error)

func check_gps_access():
	
	var options = JavaScriptBridge.create_object("Object")
	options.enableHighAccuracy = true
	options.timeout = 10000
	options.maximumAge = 0
	
	navigator.geolocation.getCurrentPosition(_success_callback_ref, _error_callback_ref, options)
	
	var result = await gps_signal
	var access = result[0]
	var err = result[1]
	
	return [access,err]

func start_watching_gps():
	if !OS.has_feature("web"):
		startButton.text = "NOT ON WEB"
		return
	
	window = JavaScriptBridge.get_interface("window")
	navigator = window.navigator
	
	var access = await check_gps_access()
	if not access[0]:
		window = JavaScriptBridge.get_interface("window")
		if window:
			window.alert("Please enable GPS/Location Services on your device.")
		return
	
	# Prevent creating multiple watches
	if _watch_id != -1:
		return
	
	startButton.visible = false
	labelContainer.visible = true
		
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


func stop_watching_gps():
	if _watch_id == -1:
		return
	
	window = JavaScriptBridge.get_interface("window")
	if window:
		window.navigator.geolocation.clearWatch(_watch_id)

	print("GPS Watch Stopped")

	_watch_id = -1

func _on_gps_success(args: Array) -> void:
	gps_signal.emit(true,null)
	
	var posdata = args[0]
	var coords = posdata.coords
	
	position.latitude = coords.latitude
	position.longitude = coords.longitude
	position.altitude = coords.altitude
	position.accuracy = coords.accuracy
	
	gps_changed.emit(position)
	
	latLabel.text = "LATITUDE: " + str(position.latitude)
	longLabel.text = "LONGITUDE: " + str(position.longitude)
	altLabel.text = "ALTITUDE: " + str(position.altitude)

	posAccLabel.text = "POSITION ACCURACY: " + str(position.accuracy)

	print("GPS Updated")

func _on_gps_error(args: Array) -> void:
	var error = args[0]
	
	gps_signal.emit(false,error.code)
	print("GPS Error:", error.code, error.message)
	
	latLabel.text = "LATITUDE: --"
	longLabel.text = "LONGITUDE: --"
	altLabel.text = "ALTITUDE: --"
	
	posAccLabel.text = "POSITION ACCURACY: --"
	
	match int(error.code):
		1:
			print("ALLOW LOCATION ACCESS")
			window = JavaScriptBridge.get_interface("window")
			if window:
				window.alert("Please enable GPS/Location Services on your device.")
		2:
			print("TURN ON GPS")
			window = JavaScriptBridge.get_interface("window")
			if window:
				window.alert("Please enable GPS/Location Services on your device.")
		3:
			print("GPS TIMED OUT")
		_:
			print("GPS ERROR")

func _exit_tree():
	stop_watching_gps()
