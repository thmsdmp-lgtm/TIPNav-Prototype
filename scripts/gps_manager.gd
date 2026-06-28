extends Node

class_name GpsManager

# Hold references to the callbacks so they are not garbage collected
var _success_callback_ref: JavaScriptObject
var _error_callback_ref: JavaScriptObject

@onready var labelContainer = $"../userInterface/CanvasLayer/Container"
@onready var startButton = $"../userInterface/CanvasLayer/StartButton"

@onready var latLabel = $"../userInterface/CanvasLayer/Container/Lat"
@onready var longLabel = $"../userInterface/CanvasLayer/Container/Long"
@onready var altLabel = $"../userInterface/CanvasLayer/Container/Alt"

@onready var posAccLabel = $"../userInterface/CanvasLayer/Container/PosAcc"
@onready var altAccLabel = $"../userInterface/CanvasLayer/Container/AltAcc"

# We will use a dedicated timer instead of _process
var update_timer: Timer

func _ready() -> void:
	pass

func request_gps_location() -> void:
	if !labelContainer.visible:
		return
	
	print("Attempting to fetch GPS...") 
	
	var window = JavaScriptBridge.get_interface("window")
	if not window:
		print("Failed to get window interface.")
		latLabel.text = "FAILED TO GET WINDOW"
		return
		
	var navigator = window.navigator
	if not navigator or not navigator.geolocation:
		latLabel.text = "FAILED TO GET GPS"
		print("Geolocation is not supported or blocked by browser security.")
		return
	
	var options = JavaScriptBridge.create_object("Object")
	options.enableHighAccuracy = true
	options.timeout = 5000
	options.maximumAge = 0
	
	# Using watchPosition is usually better for continuous tracking than looping getCurrentPosition
	navigator.geolocation.getCurrentPosition(_success_callback_ref, _error_callback_ref, options)

func _on_gps_success(args: Array) -> void:
	var position = args[0]
	var coords = position.coords
	
	var latitude = coords.latitude
	var longitude = coords.longitude
	var posAccuracy = coords.accuracy
	
	var altitude = coords.altitude
	var altAccuracy = coords.altitudeAccuracy
	
	latLabel.text = str("LATITUDE: ", latitude)
	longLabel.text = str("LONGITUDE: ", longitude)
	altLabel.text = str("ALTITUDE: ", altitude)
	
	posAccLabel.text = str("POSITION ACCURACY: ", posAccuracy)
	altAccLabel.text = str("ALTITUDE ACCURACY: ", altAccuracy)
	
func _on_gps_error(args: Array) -> void:
	var error = args[0]
	var error_code = error.code
	var error_message = error.message
	print("GPS Error code: ", error_code, " | Message: ", error_message)
	
	# Let the user know exactly WHY it's failing
	if error_code == 1: # PERMISSION_DENIED
		latLabel.text = "ERROR: Permission Denied. Please allow location access."
	elif error_code == 2: # POSITION_UNAVAILABLE
		latLabel.text = "ERROR: GPS Hardware is turned OFF or unavailable."
		# Optional: Prompt them via browser alert
		var window = JavaScriptBridge.get_interface("window")
		if window:
			window.alert("Please enable GPS/Location settings on your device.")
	elif error_code == 3: # TIMEOUT
		latLabel.text = "ERROR: Location request timed out."

func _on_start_button_pressed() -> void:
	startButton.visible = false
	labelContainer.visible = true
	
	if OS.has_feature("web"):
		_success_callback_ref = JavaScriptBridge.create_callback(_on_gps_success)
		_error_callback_ref = JavaScriptBridge.create_callback(_on_gps_error)
		
		# Setup a safe loop using a real Timer node
		update_timer = Timer.new()
		update_timer.wait_time = 2.0 # Increased wait time; 0.5s is too aggressive for hardware GPS locks
		update_timer.autostart = true
		update_timer.timeout.connect(request_gps_location)
		add_child(update_timer)
		
		# Fire once immediately
		request_gps_location()
	else:
		latLabel.text = "NOT ON BROWSER"
		longLabel.text = "NOT ON BROWSER"
		print("GPS retrieval via JavaScriptBridge is only supported on Web builds.")
