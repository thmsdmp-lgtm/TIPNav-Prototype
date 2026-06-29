extends Node

var device_heading = 0.0

func start():
	if OS.has_feature("web"):
		setup_compass_listeners()

func setup_compass_listeners():
	# 1. Check if JavaScriptBridge is available and inject our listener
	var js_code = """
		if ('DeviceOrientationEvent' in window) {
			// Request permission on supported browsers (e.g., iOS 13+)
			if (typeof DeviceOrientationEvent.requestPermission === 'function') {
				DeviceOrientationEvent.requestPermission()
					.then(permissionState => {
						if (permissionState === 'granted') {
							window.addEventListener('deviceorientation', handleOrientation);
						}
					})
					.catch(console.error);
			} else {
				// Non-iOS devices
				window.addEventListener('deviceorientation', handleOrientation);
			}
			
			window.my_device_heading = 0.0;
			function handleOrientation(event) {
				// event.alpha gives the compass heading in degrees (0-360)
				window.my_device_heading = event.alpha;
			}
		} else {
			console.log("Device orientation not supported");
		}
	"""
	JavaScriptBridge.eval(js_code)

func _process(delta):
	if OS.has_feature("web"):
		# 2. Fetch the variable from JavaScript every frame
		device_heading = JavaScriptBridge.eval("window.my_device_heading")
		
		# device_heading is now the absolute compass bearing in degrees
		# For example, 0 is North, 90 is East, 180 is South, 270 is West
		print("Current Heading: ", device_heading)
