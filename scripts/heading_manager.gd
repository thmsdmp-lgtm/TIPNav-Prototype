extends Node
class_name HeadingManager

# Signals to notify the rest of your app
signal heading_changed(heading_degrees: float)
signal permission_status_changed(status: String) # "granted", "denied", "prompt", "unsupported"
signal error_occurred(error_message: String)

var _js_callback: JavaScriptObject = null
var _is_watching: bool = false

func _ready() -> void:
	if OS.has_feature("web"):
		_js_callback = JavaScriptBridge.create_callback(_on_js_heading_update)

## Checks permission and returns the status string ("granted", "prompt", etc.)
func check_heading_permission() -> String:
	if not OS.has_feature("web"):
		_emit_error("Heading API is only available on Web exports.")
		permission_status_changed.emit("unsupported")
		return "unsupported"

	var window = JavaScriptBridge.get_interface("window")
	
	if not window or not ("DeviceOrientationEvent" in window):
		permission_status_changed.emit("unsupported")
		return "unsupported"
	
	# iOS 13+ specific permission check
	if window.DeviceOrientationEvent and window.DeviceOrientationEvent.requestPermission:
		permission_status_changed.emit("prompt")
		return "prompt"
	else:
		# Android / Desktop standard behavior (usually granted by default if sensor exists)
		permission_status_changed.emit("granted")
		return "granted"

func start_watching_heading() -> void:
	if _is_watching: return
	if not OS.has_feature("web"): return

	# --- PRE-FLIGHT PERMISSION CHECK ---
	var current_status = check_heading_permission()
	if current_status == "unsupported":
		error_occurred.emit(false)
		return
	
	error_occurred.emit(true)
	
	var window = JavaScriptBridge.get_interface("window")
	
	# iOS Handling (Requires explicit permission request triggered by a user gesture)
	if window.DeviceOrientationEvent and window.DeviceOrientationEvent.requestPermission:
		
		var promise = window.DeviceOrientationEvent.requestPermission()
		
		# Set up callbacks for the Promise
		var on_granted = JavaScriptBridge.create_callback(func(args):
			var response = args[0] # "granted" or "denied"
			permission_status_changed.emit(response)
			if response == "granted":
				_attach_listener(window)
			else:
				_emit_error("Permission denied by iOS user.")
		)
		
		var on_denied = JavaScriptBridge.create_callback(func(args):
			permission_status_changed.emit("denied")
			_emit_error("Permission promise rejected.")
		)
		
		promise.then(on_granted).catch(on_denied)
	else:
		# Android / Modern Browsers
		# We use absolute orientation events if available, falling back to standard
		_attach_listener(window)
		permission_status_changed.emit("granted")

func stop_watching_heading() -> void:
	if not _is_watching or not OS.has_feature("web"): return
	
	var window = JavaScriptBridge.get_interface("window")
	
	# Remove listeners for both iOS and Android variants
	if window:
		window.removeEventListener("deviceorientationabsolute", _js_callback)
		window.removeEventListener("deviceorientation", _js_callback)
	
	_is_watching = false

# Internal helper to handle the JS binding differences
func _attach_listener(window: JavaScriptObject) -> void:
	# Android chrome prefers deviceorientationabsolute for actual compass heading
	if "ondeviceorientationabsolute" in window:
		window.addEventListener("deviceorientationabsolute", _js_callback, true)
	else:
		window.addEventListener("deviceorientation", _js_callback, true)
	_is_watching = true

# The actual JS callback processor
func _on_js_heading_update(args: Array) -> void:
	var event = args[0]
	if event == null: return
	
	var heading: float = -1.0
	
	# iOS property (compass heading relative to magnetic north, 0 to 360)
	if "webkitCompassHeading" in event and event.webkitCompassHeading != null:
		heading = float(event.webkitCompassHeading)
	# Android / Web Standard (alpha is 0 to 360, absolute flag ensures it's earth-relative)
	elif "alpha" in event and event.alpha != null:
		# WebKit / iOS goes 0-360 clockwise. Alpha is 0-360 counter-clockwise, so we invert it.
		heading = 360.0 - float(event.alpha)
	
	if heading != -1.0:
		heading_changed.emit(heading)
	else:
		_emit_error("Sensor data received, but no valid heading coordinate found.")

func _emit_error(msg: String) -> void:
	error_occurred.emit(msg)
	push_warning("[HeadingManager] " + msg)
