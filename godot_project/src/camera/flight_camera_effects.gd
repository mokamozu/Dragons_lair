class_name FlightCameraEffects
extends RefCounted


static func get_targets(speed_ratio: float, air_braking: bool) -> Dictionary:
	var normalized_speed: float = clampf(speed_ratio, 0.0, 1.0)
	if air_braking:
		return {
			"fov": lerpf(70.0, 74.0, normalized_speed),
			"distance": lerpf(5.0, 4.2, normalized_speed),
		}
	return {
		"fov": lerpf(70.0, 96.0, normalized_speed),
		"distance": lerpf(5.0, 7.5, normalized_speed),
	}
