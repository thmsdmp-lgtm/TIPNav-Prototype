extends Button

@onready var labelContainer = $"../Container"
@onready var startButton = $"."
@onready var latLabel = $"../Container/Lat"
@onready var longLabel = $"../Container/Long"
@onready var altLabel = $"../Container/Alt"
@onready var headingLabel = $"../Container/Heading"
@onready var posAccLabel = $"../Container/PosAcc"

func _ready():
	%gpsManager.gps_changed.connect(gps_changed)
	%headingManager.heading_changed.connect(heading_changed)

func heading_changed(heading):
	headingLabel.text = "HEADING: " + str(heading)

func gps_changed(position):
	latLabel.text = "LATITUDE: " + str(position.latitude)
	longLabel.text = "LONGITUDE: " + str(position.longitude)
	altLabel.text = "ALTITUDE: " + str(position.altitude)
	posAccLabel.text = "POSITION ACCURACY: " + str(position.accuracy)

func _on_pressed() -> void:
	# start tracking gps
	%gpsManager.start_watching_gps()
	
	var gps_result = await  %gpsManager.gps_signal
	
	# start tracking heading
	%headingManager.start_watching_heading()
	
	var heading_result = await %headingManager.error_occurred
	
	if heading_result and gps_result[0]:
		startButton.visible = false
		labelContainer.visible = true
	else:
		%headingManager.stop_watching_heading()
		%gpsManager.stop_watching_gps()
