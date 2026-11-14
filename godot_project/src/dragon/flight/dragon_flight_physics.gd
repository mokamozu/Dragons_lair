class_name DragonFlightPhysics
extends RefCounted

const GRAVITY: float = 4.8
const STALL_SPEED: float = 5.0
const MAX_KINETIC_CHARGE: float = 28.0
const FLAP_STAMINA_COST: float = 18.0

var kinetic_charge: float = 0.0
var is_stalled: bool = false


func reset() -> void:
	kinetic_charge = 0.0
	is_stalled = false


func update_velocity(
	current_velocity: Vector3,
	desired_heading: Vector3,
	pitch: float,
	throttle: float,
	flap_requested: bool,
	boosting: bool,
	air_braking: bool,
	is_near_ground: bool,
	delta: float,
	stats: DragonStats,
	element: String,
	cruise_speed: float,
	available_stamina: float
) -> Dictionary:
	var horizontal_heading: Vector3 = Vector3(desired_heading.x, 0.0, desired_heading.z)
	if horizontal_heading.length_squared() < 0.001:
		horizontal_heading = Vector3.FORWARD
	else:
		horizontal_heading = horizontal_heading.normalized()

	var cruise: float = maxf(cruise_speed, 1.0)
	var terminal: float = 38.0 * stats.flight_speed_multiplier
	if element == "Vento":
		terminal = minf(terminal, 42.0)
	var dive_acceleration: float = 16.0 if element == "Fogo" else 12.0
	var stall_speed: float = 4.0 if element == "Terra" else STALL_SPEED
	var flight_velocity: Vector3 = current_velocity
	var stamina_cost: float = 0.0
	var stamina_regen: float = 0.0
	var flapped: bool = false
	var flight_pitch: float = clampf(pitch, -0.85, 0.7)
	var speed: float = flight_velocity.length()

	if air_braking:
		flight_velocity = flight_velocity.move_toward(Vector3.ZERO, 18.0 * delta)
		flight_velocity.y = move_toward(flight_velocity.y, -0.8, 4.0 * delta)
		kinetic_charge = move_toward(kinetic_charge, 0.0, 4.0 * delta)
		is_stalled = false
		stamina_cost += 0.35 * delta
		flight_velocity = _steer_horizontal_velocity(
			flight_velocity,
			horizontal_heading,
			stats.agility,
			speed,
			terminal,
			delta
		)
	else:
		flight_velocity = _steer_horizontal_velocity(
			flight_velocity,
			horizontal_heading,
			stats.agility,
			speed,
			terminal,
			delta
		)

		if throttle > 0.0:
			var thrust_pitch: float = flight_pitch
			var thrust_direction: Vector3 = (
				horizontal_heading * cos(thrust_pitch)
				+ Vector3.UP * sin(thrust_pitch)
			).normalized()
			var acceleration: float = dive_acceleration
			if element == "Terra":
				acceleration *= 1.1
			flight_velocity += thrust_direction * acceleration * throttle * delta
			stamina_cost += (1.2 + maxf(thrust_pitch, 0.0) * 2.0) * throttle * delta

		if boosting and available_stamina > 0.0:
			flight_velocity += horizontal_heading * 11.0 * delta
			stamina_cost += 6.0 * delta

		speed = flight_velocity.length()
		var flap_cost: float = FLAP_STAMINA_COST * stats.flight_stamina_cost_multiplier
		if flap_requested and available_stamina >= flap_cost:
			flight_velocity += horizontal_heading * 7.0 + Vector3.UP * 4.5
			stamina_cost += FLAP_STAMINA_COST
			flapped = true

		speed = flight_velocity.length()
		is_stalled = flight_pitch > 0.2 and speed < stall_speed
		if is_stalled:
			flight_velocity.y -= 8.0 * delta
			flight_velocity.x = move_toward(flight_velocity.x, 0.0, 2.0 * delta)
			flight_velocity.z = move_toward(flight_velocity.z, 0.0, 2.0 * delta)
			kinetic_charge = move_toward(kinetic_charge, 0.0, 3.0 * delta)
		else:
			var lift_multiplier: float = 1.0
			if element == "Terra":
				lift_multiplier = 1.28
			elif element == "Água/Gelo" and is_near_ground:
				lift_multiplier = 1.55
			var lift: float = GRAVITY * pow(speed / cruise, 2.0) * lift_multiplier
			flight_velocity.y += (minf(lift, 12.0) - GRAVITY) * delta

			if flight_pitch > 0.12 and speed >= stall_speed and kinetic_charge > 0.0:
				var converted_energy: float = minf(kinetic_charge, flight_pitch * 10.0 * delta)
				flight_velocity.y += converted_energy * 0.8
				kinetic_charge -= converted_energy
				stamina_cost += flight_pitch * 1.5 * delta
			elif flight_pitch < -0.12 and throttle > 0.0:
				flight_velocity += Vector3.DOWN * absf(flight_pitch) * dive_acceleration * 0.45 * delta

			var descending_speed: float = maxf(0.0, -flight_velocity.y)
			var speed_charge: float = maxf(0.0, flight_velocity.length() - cruise)
			if descending_speed > 0.5 or flight_pitch < -0.2:
				kinetic_charge = minf(
					MAX_KINETIC_CHARGE,
					kinetic_charge + (descending_speed + speed_charge * 0.35) * 0.3 * delta
				)

			var drag: float = 0.025
			if element == "Água/Gelo" and is_near_ground:
				drag *= 0.45
			flight_velocity *= maxf(0.0, 1.0 - drag * delta)
			stamina_regen = 2.0 * stats.stamina_regen_multiplier * delta

	speed = flight_velocity.length()
	if speed > terminal:
		flight_velocity = flight_velocity.normalized() * terminal

	return {
		"velocity": flight_velocity,
		"speed": flight_velocity.length(),
		"terminal_speed": terminal,
		"kinetic_charge": kinetic_charge,
		"stalled": is_stalled,
		"flapped": flapped,
		"stamina_cost": stamina_cost * stats.flight_stamina_cost_multiplier,
		"stamina_regen": stamina_regen,
		"air_braking": air_braking,
	}


func _steer_horizontal_velocity(
	current_velocity: Vector3,
	target_heading: Vector3,
	agility: float,
	speed: float,
	terminal_speed: float,
	delta: float
) -> Vector3:
	var horizontal_velocity: Vector3 = Vector3(current_velocity.x, 0.0, current_velocity.z)
	if horizontal_velocity.length_squared() < 0.01:
		return current_velocity

	var current_heading: Vector3 = horizontal_velocity.normalized()
	var current_yaw: float = atan2(-current_heading.x, -current_heading.z)
	var target_yaw: float = atan2(-target_heading.x, -target_heading.z)
	var heading_delta: float = wrapf(target_yaw - current_yaw, -PI, PI)
	var speed_ratio: float = clampf(speed / maxf(terminal_speed, 1.0), 0.0, 1.0)
	var turn_rate: float = deg_to_rad(90.0) * clampf(agility / 8.0, 0.25, 2.0)
	turn_rate *= 0.25 + speed_ratio * 0.75
	var turn_step: float = clampf(heading_delta, -turn_rate * delta, turn_rate * delta)
	var rotated_velocity: Vector3 = horizontal_velocity.rotated(Vector3.UP, turn_step)
	return Vector3(rotated_velocity.x, current_velocity.y, rotated_velocity.z)
