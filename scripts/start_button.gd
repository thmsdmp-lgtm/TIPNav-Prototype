extends Button

@onready var labelContainer = $"../Container"
@onready var startButton = $"."
@onready var latLabel = $"../Container/Lat"
@onready var longLabel = $"../Container/Long"
@onready var altLabel = $"../Container/Alt"
@onready var posAccLabel = $"../Container/PosAcc"

func _ready():
	%gpsManager.gps_changed.connect(gps_changed)

func gps_changed(position):
	latLabel.text = "LATITUDE: " + str(position.latitude)
	longLabel.text = "LONGITUDE: " + str(position.longitude)
	altLabel.text = "ALTITUDE: " + str(position.altitude)
	posAccLabel.text = "POSITION ACCURACY: " + str(position.accuracy)

func _on_pressed() -> void:
	# start tracking gps
	%gpsManager.start_watching_gps()
	
	var gps_result = await  %gpsManager.gps_signal
	
	if !gps_result[0]:
		return
	
	startButton.visible = false
	labelContainer.visible = true
