extends Node3D

@export_range(0.001, 0.02, 0.001) var mouse_sensitivity: float = 0.003
@export_range(2.0, 12.0, 0.1) var follow_distance: float = 5.0
@onready var spring_arm: SpringArm3D = $SpringArm3D

var _mouse_captured: bool = true


func _ready() -> void:
	spring_arm.spring_length = follow_distance
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


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
