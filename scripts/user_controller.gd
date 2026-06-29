extends Node3D

# instances
@onready var user_avatar = $"."

# constants
const EARTH_RADIUS = 6378137.0 # meters
const  movement_threshold = .25 # meters

# variables
var active = false
var lon0
var lat0

func _ready():
	var result = await  %gpsManager.gps_signal
	
	if result[0]:
		await %gpsManager.gps_changed
		
		lon0 = %gpsManager.position.longitude
		lat0 = %gpsManager.position.latitude
		
		active = true

func latlon_to_meters(lat: float, lon: float) -> Vector2:
	var d_lat = deg_to_rad(lat - lat0)
	var d_lon = deg_to_rad(lon - lon0)

	var x = d_lon * EARTH_RADIUS * cos(deg_to_rad(lat0))
	var y = d_lat * EARTH_RADIUS

	return Vector2(x, y)

func _physics_process(delta: float) -> void:
	if !active:
		return
	
	var gps_pos = %gpsManager.position
	var game_pos =  latlon_to_meters(gps_pos.latitude,gps_pos.longitude)
	
	if game_pos.length() < movement_threshold:
		return
	
	user_avatar.position = lerp(user_avatar.position,Vector3(game_pos.x,0,game_pos.y),delta*2.5)
	print(user_avatar.position)
	print(lat0,lon0)
