extends Node3D

@export_range(0.001, 0.02, 0.001) var mouse_sensitivity: float = 0.003
@export_range(2.0, 12.0, 0.1) var follow_distance: float = 5.0
@export_range(60.0, 100.0, 1.0) var first_person_fov: float = 82.0
@export_range(50.0, 90.0, 1.0) var mounted_fov: float = 70.0
@export_range(1.0, 10.0, 0.1) var flight_camera_smoothing: float = 3.5
@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

var _mouse_captured: bool = true
var _first_person: bool = true
var _flight_speed_ratio: float = 0.0
var _air_braking: bool = false


func _ready() -> void:
	set_first_person(_first_person)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func set_first_person(enabled: bool) -> void:
	_first_person = enabled
	_flight_speed_ratio = 0.0
	_air_braking = false
	spring_arm.spring_length = 0.0 if enabled else follow_distance
	spring_arm.rotation.y = 0.0 if enabled else PI
	camera.rotation.y = 0.0 if enabled else PI
	camera.fov = first_person_fov if enabled else mounted_fov


func set_flight_feedback(
	speed: float,
	terminal_speed: float,
	is_flying: bool,
	air_braking: bool
) -> void:
	_flight_speed_ratio = speed / maxf(terminal_speed, 1.0) if is_flying else 0.0
	_air_braking = air_braking


func _process(delta: float) -> void:
	if _first_person:
		return
	var targets: Dictionary = FlightCameraEffects.get_targets(_flight_speed_ratio, _air_braking)
	var blend: float = minf(1.0, delta * flight_camera_smoothing)
	camera.fov = lerpf(camera.fov, float(targets["fov"]), blend)
	spring_arm.spring_length = lerpf(
		spring_arm.spring_length,
		float(targets["distance"]),
		blend
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _mouse_captured:
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.x = clampf(
			rotation.x - event.relative.y * mouse_sensitivity,
			deg_to_rad(-55.0),
			deg_to_rad(30.0)
		)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_mouse_captured = not _mouse_captured
		Input.mouse_mode = (
			Input.MOUSE_MODE_CAPTURED if _mouse_captured else Input.MOUSE_MODE_VISIBLE
		)
