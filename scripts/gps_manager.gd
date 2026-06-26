extends Node

# Hold references to the callbacks so they are not garbage collected
var _success_callback_ref: JavaScriptObject
var _error_callback_ref: JavaScriptObject

@onready var latLabel = $"../userInterface/CanvasLayer/Container/Lat"
@onready var longLabel = $"../userInterface/CanvasLayer/Container/Long"

# We will use a dedicated timer instead of _process
var update_timer: Timer

func _ready() -> void:
	if OS.has_feature("web"):
		_success_callback_ref = JavaScriptBridge.create_callback(_on_gps_success)
		_error_callback_ref = JavaScriptBridge.create_callback(_on_gps_error)
		
		# Setup a safe loop using a real Timer node
		update_timer = Timer.new()
		update_timer.wait_time = 0.5
		update_timer.autostart = true
		update_timer.timeout.connect(request_gps_location)
		add_child(update_timer)
		
		# Fire once immediately
		request_gps_location()
	else:
		latLabel.text = "NOT ON BROWSER"
		longLabel.text = "NOT ON BROWSER"
		print("GPS retrieval via JavaScriptBridge is only supported on Web builds.")

func request_gps_location() -> void:
	print("Attempting to fetch GPS...") # This will let you know it's ticking
	
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
	
	navigator.geolocation.getCurrentPosition(_success_callback_ref, _error_callback_ref, options)

func _on_gps_success(args: Array) -> void:
	var position = args[0]
	var coords = position.coords
	
	var latitude = coords.latitude
	var longitude = coords.longitude
	var accuracy = coords.accuracy
	
	latLabel.text = str(latitude)
	longLabel.text = str(longitude)
	print("SUCCESS! Lat: ", latitude, " | Long: ", longitude, " | Accuracy: ", accuracy)

func _on_gps_error(args: Array) -> void:
	var error = args[0]
	latLabel.text = "GPS ERROR: " + str(error.code)
	print("GPS Error code: ", error.code, " | Message: ", error.message)
