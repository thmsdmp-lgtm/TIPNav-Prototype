extends Node
class_name HeadingManager

signal heading_changed(heading)

var _heading := 0.0
var _watching := false

var _js_heading
var _js_start
var _js_stop
var _js_get

func _ready():

	if OS.get_name() != "Web":
		push_warning("HeadingManager only works in Web exports.")
		return

	var bridge = JavaScriptBridge

	bridge.eval("""
		window.godotHeading = {
			heading: null,
			listener: null,

			start: async function () {

				if (this.listener)
					return;

				// iOS permission
				if (
					typeof DeviceOrientationEvent !== 'undefined' &&
					typeof DeviceOrientationEvent.requestPermission === 'function'
				){
					try{
						const result = await DeviceOrientationEvent.requestPermission();
						if(result !== 'granted'){
							console.log("Orientation permission denied");
							return;
						}
					}catch(e){
						console.error(e);
						return;
					}
				}

				this.listener = function(event){

					let heading = null;

					// iOS
					if(event.webkitCompassHeading != null){
						heading = event.webkitCompassHeading;
					}
					// Android
					else if(event.alpha != null){
						heading = 360 - event.alpha;
					}

					if(heading != null){
						heading = ((heading % 360) + 360) % 360;
						window.godotHeading.heading = heading;
					}
				};

				window.addEventListener(
					'deviceorientation',
					this.listener,
					true
				);
			},

			stop: function(){

				if(this.listener){
					window.removeEventListener(
						'deviceorientation',
						this.listener,
						true
					);
					this.listener = null;
				}
			},

			getHeading: function(){
				return this.heading;
			}
		};
	""", true)

	_js_start = bridge.get_interface("godotHeading").get("start")
	_js_stop = bridge.get_interface("godotHeading").get("stop")
	_js_get = bridge.get_interface("godotHeading").get("getHeading")


func start_watching():

	if _watching:
		return

	_watching = true

	_js_start.call()

	set_process(true)


func stop_watching():

	if !_watching:
		return

	_watching = false

	_js_stop.call()

	set_process(false)

func _process(_delta):

	if !_watching:
		return

	var value = _js_get.call()

	if value != null:
		_heading = float(value)
		heading_changed.emit(_heading)
