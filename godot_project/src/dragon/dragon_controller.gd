class_name DragonController
extends CharacterBody3D

enum CompanionState {
	FOLLOWING,
	STAYING,
	FLYING,
	MOUNTED,
	MOUNTED_FLYING,
}

@export var stats: DragonStats
@export var species_profile: DragonSpeciesData
@export_range(0.5, 10.0, 0.1) var follow_distance: float = 3.0
@export_range(1.0, 30.0, 0.5) var flight_speed: float = 11.0
@export_range(1.0, 30.0, 0.5) var boost_speed: float = 16.0
@export_range(4.0, 16.0, 0.5) var cruise_speed: float = 14.0

@onready var visual: Node3D = $Visual
@onready var seat: Marker3D = $Seat
@onready var flight_feedback: Node3D = $Visual/FlightFeedback

var state: CompanionState = CompanionState.FOLLOWING
var follow_target: Node3D
var rider: Node3D
var current_hp: float = 120.0
var current_stamina: float = 100.0
var kinetic_charge: float = 0.0
var is_stalled: bool = false
var _rider_direction: Vector3 = Vector3.ZERO
var _rider_ascending: bool = false
var _rider_descending: bool = false
var _rider_boosting: bool = false
var _rider_throttle: float = 0.0
var _rider_flap_requested: bool = false
var _rider_air_braking: bool = false
var _rider_pitch: float = 0.0
var _wing_phase: float = 0.0
var _left_wing: Node3D
var _right_wing: Node3D
var _flight_physics: DragonFlightPhysics = DragonFlightPhysics.new()
var _flight_speed: float = 0.0
var _flight_terminal_speed: float = 38.0
var _flight_active: bool = false
var _visual_target_pitch: float = 0.0
var _visual_target_roll: float = 0.0


func _ready() -> void:
	if stats == null:
		stats = DragonStats.new()
	flight_speed *= stats.flight_speed_multiplier
	boost_speed *= stats.flight_speed_multiplier
	current_hp = stats.max_hp
	current_stamina = stats.max_stamina
	_build_placeholder_dragon()


func _process(delta: float) -> void:
	if _left_wing != null:
		_wing_phase += delta * (11.0 if state == CompanionState.MOUNTED_FLYING or state == CompanionState.FLYING else 4.0)
		_left_wing.rotation.z = sin(_wing_phase) * 0.32
		_right_wing.rotation.z = -sin(_wing_phase) * 0.32
	visual.rotation.x = lerpf(visual.rotation.x, _visual_target_pitch, minf(delta * 4.0, 1.0))
	visual.rotation.z = lerpf(visual.rotation.z, _visual_target_roll, minf(delta * 4.0, 1.0))
	flight_feedback.call(
		"set_flight_feedback",
		_flight_speed / maxf(_flight_terminal_speed, 1.0),
		_flight_active,
		_rider_air_braking
	)
	if rider != null:
		var camera_pivot: Node3D = rider.get_node_or_null("CameraPivot")
		if camera_pivot != null:
			camera_pivot.call(
				"set_flight_feedback",
				_flight_speed,
				_flight_terminal_speed,
				_flight_active,
				_rider_air_braking
			)


func _physics_process(delta: float) -> void:
	match state:
		CompanionState.FOLLOWING:
			_update_following(delta)
		CompanionState.STAYING:
			_update_staying(delta)
		CompanionState.FLYING:
			_update_companion_flight(delta)
		CompanionState.MOUNTED, CompanionState.MOUNTED_FLYING:
			_update_mounted_movement(delta)


func set_follow_target(target: Node3D) -> void:
	follow_target = target


func toggle_follow_mode() -> void:
	if state == CompanionState.MOUNTED or state == CompanionState.MOUNTED_FLYING:
		return
	if state == CompanionState.FOLLOWING or state == CompanionState.FLYING:
		state = CompanionState.STAYING
	else:
		state = CompanionState.FOLLOWING


func request_mount(player: Node3D) -> void:
	if state != CompanionState.FOLLOWING and state != CompanionState.STAYING:
		return
	if global_position.distance_to(player.global_position) > 5.0:
		print("Chegue mais perto do dragão para montar.")
		return
	rider = player
	state = CompanionState.MOUNTED
	player.call("attach_to_dragon", self, seat)


func request_dismount(player: Node3D) -> void:
	if state != CompanionState.MOUNTED and state != CompanionState.MOUNTED_FLYING:
		return
	if not is_on_floor():
		print("Pouse o dragão antes de desmontar.")
		return
	var side_position: Vector3 = global_position + global_basis.x * 1.6
	side_position.y = global_position.y + 0.05
	state = CompanionState.FOLLOWING
	rider = null
	player.call("detach_from_dragon", side_position)


func set_rider_input(
	direction: Vector3,
	ascending: bool,
	descending: bool,
	boosting: bool,
	throttle: float = 0.0,
	flap_requested: bool = false,
	air_braking: bool = false,
	pitch: float = 0.0
) -> void:
	_rider_direction = direction
	if air_braking and state == CompanionState.MOUNTED_FLYING:
		var forward: Vector3 = -global_basis.z
		var right: Vector3 = global_basis.x
		forward.y = 0.0
		right.y = 0.0
		forward = forward.normalized()
		right = right.normalized()
		var forward_input: float = maxf(direction.dot(forward), 0.0)
		var side_input: float = direction.dot(right)
		_rider_direction = (
			forward * forward_input + right * side_input
		).normalized()
	_rider_ascending = ascending
	_rider_descending = descending
	_rider_boosting = boosting
	_rider_throttle = clampf(throttle, 0.0, 1.0)
	_rider_flap_requested = flap_requested
	_rider_air_braking = air_braking
	_rider_pitch = pitch


func get_flight_status_label() -> String:
	if state != CompanionState.MOUNTED_FLYING:
		return ""
	var status: String = "Voo: %d m/s · Carga: %d" % [
		roundi(_flight_speed),
		roundi(kinetic_charge),
	]
	if is_stalled:
		status += " · ESTOL"
	elif _rider_air_braking:
		status += " · FREIO"
	return status


func get_state_label() -> String:
	match state:
		CompanionState.FOLLOWING:
			return "Seguindo"
		CompanionState.STAYING:
			return "Parado"
		CompanionState.FLYING:
			return "Voando"
		CompanionState.MOUNTED:
			return "Montado"
		CompanionState.MOUNTED_FLYING:
			return "Voando (montado)"
	return "Disponível"


func _update_following(delta: float) -> void:
	if follow_target == null or bool(follow_target.get("is_mounted")):
		_apply_ground_gravity(delta)
		move_and_slide()
		return
	var distance: float = global_position.distance_to(follow_target.global_position)
	if distance > 12.0 and current_stamina > 10.0:
		state = CompanionState.FLYING
		return
	if distance > follow_distance:
		var direction: Vector3 = follow_target.global_position - global_position
		direction.y = 0.0
		direction = direction.normalized()
		velocity.x = move_toward(velocity.x, direction.x * stats.movement_speed, 12.0 * delta)
		velocity.z = move_toward(velocity.z, direction.z * stats.movement_speed, 12.0 * delta)
		_face_direction(direction, delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 15.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 15.0 * delta)
	_apply_ground_gravity(delta)
	move_and_slide()


func _update_staying(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 15.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 15.0 * delta)
	current_stamina = minf(
		stats.max_stamina,
		current_stamina + 10.0 * stats.stamina_regen_multiplier * delta
	)
	_apply_ground_gravity(delta)
	move_and_slide()


func _update_companion_flight(delta: float) -> void:
	if follow_target == null or bool(follow_target.get("is_mounted")):
		state = CompanionState.STAYING
		return
	var target_position: Vector3 = follow_target.global_position
	var offset: Vector3 = target_position - global_position
	if offset.length() > 5.0:
		target_position.y += 2.2
		var direction: Vector3 = (target_position - global_position).normalized()
		velocity = direction * minf(flight_speed, offset.length())
		current_stamina = maxf(
			0.0,
			current_stamina - 6.0 * stats.flight_stamina_cost_multiplier * delta
		)
		_face_direction(Vector3(direction.x, 0.0, direction.z), delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
		velocity.y = move_toward(velocity.y, -2.0, 8.0 * delta)
	move_and_slide()
	if is_on_floor():
		state = CompanionState.FOLLOWING


func _update_mounted_movement(delta: float) -> void:
	var is_flying: bool = state == CompanionState.MOUNTED_FLYING
	var horizontal_direction: Vector3 = _rider_direction
	horizontal_direction.y = 0.0
	if horizontal_direction.length_squared() > 1.0:
		horizontal_direction = horizontal_direction.normalized()
	if not is_flying:
		var ground_speed: float = stats.movement_speed
		velocity.x = move_toward(velocity.x, horizontal_direction.x * ground_speed, 8.0 * delta)
		velocity.z = move_toward(velocity.z, horizontal_direction.z * ground_speed, 8.0 * delta)
		if horizontal_direction.length_squared() > 0.01:
			_face_direction(horizontal_direction, delta)
		if _rider_ascending and current_stamina > 0.0:
			_begin_mounted_flight(horizontal_direction)
			is_flying = true
		else:
			current_stamina = minf(
				stats.max_stamina,
				current_stamina + 8.0 * stats.stamina_regen_multiplier * delta
			)
			_apply_ground_gravity(delta)

	if is_flying:
		var heading: Vector3 = -global_basis.z
		if horizontal_direction.length_squared() > 0.01:
			heading = horizontal_direction.normalized()
		var flight_result: Dictionary = _flight_physics.update_velocity(
			velocity,
			heading,
			_rider_pitch - (0.45 if _rider_descending else 0.0),
			_rider_throttle,
			_rider_flap_requested,
			_rider_boosting,
			_rider_air_braking,
			stats.element == "Água/Gelo" and _is_near_ground(),
			delta,
			stats,
			stats.element,
			cruise_speed * stats.flight_speed_multiplier,
			current_stamina
		)
		velocity = flight_result["velocity"]
		_flight_speed = float(flight_result["speed"])
		_flight_terminal_speed = float(flight_result["terminal_speed"])
		kinetic_charge = float(flight_result["kinetic_charge"])
		is_stalled = bool(flight_result["stalled"])
		current_stamina = clampf(
			current_stamina
				- float(flight_result["stamina_cost"])
				+ float(flight_result["stamina_regen"]),
			0.0,
			stats.max_stamina
		)
		_flight_active = true
		_update_flight_attitude(delta)

	move_and_slide()
	if is_on_floor():
		velocity.y = 0.0
		if state == CompanionState.MOUNTED_FLYING:
			state = CompanionState.MOUNTED
			_flight_active = false
			_flight_speed = velocity.length()
			_flight_physics.reset()
			kinetic_charge = 0.0
			is_stalled = false
			_visual_target_pitch = 0.0
			_visual_target_roll = 0.0


func _begin_mounted_flight(heading: Vector3) -> void:
	state = CompanionState.MOUNTED_FLYING
	_flight_physics.reset()
	kinetic_charge = 0.0
	is_stalled = false
	var launch_heading: Vector3 = heading.normalized()
	if launch_heading.length_squared() < 0.01:
		launch_heading = -global_basis.z
	var launch_speed: float = maxf(
		Vector2(velocity.x, velocity.z).length(),
		cruise_speed * stats.flight_speed_multiplier
	)
	velocity.x = launch_heading.x * launch_speed
	velocity.z = launch_heading.z * launch_speed
	velocity.y = maxf(velocity.y, 2.5)


func _update_flight_attitude(delta: float) -> void:
	var horizontal_speed: float = Vector2(velocity.x, velocity.z).length()
	var travel_pitch: float = atan2(velocity.y, maxf(horizontal_speed, 0.1))
	_visual_target_pitch = clampf(travel_pitch, -0.65, 0.65)
	var heading: Vector3 = -global_basis.z
	var velocity_heading: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	if velocity_heading.length_squared() < 0.01:
		_visual_target_roll = 0.0
		return
	velocity_heading = velocity_heading.normalized()
	var heading_angle: float = atan2(-heading.x, -heading.z)
	var travel_angle: float = atan2(-velocity_heading.x, -velocity_heading.z)
	var turn_angle: float = wrapf(travel_angle - heading_angle, -PI, PI)
	var speed_ratio: float = clampf(_flight_speed / maxf(_flight_terminal_speed, 1.0), 0.0, 1.0)
	_visual_target_roll = clampf(-turn_angle * (0.65 + speed_ratio * 0.6), -PI / 3.0, PI / 3.0)
	_face_direction(velocity_heading, delta)


func _is_near_ground() -> bool:
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3.DOWN * 4.0
	)
	query.exclude = [get_rid()]
	return not get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _apply_ground_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0


func _face_direction(direction: Vector3, delta: float) -> void:
	if direction.length_squared() < 0.001:
		return
	rotation.y = lerp_angle(
		rotation.y,
		atan2(-direction.x, -direction.z),
		minf(1.0, delta * stats.agility)
	)


func _build_placeholder_dragon() -> void:
	for child: Node in visual.get_children():
		if child != flight_feedback:
			return
	var hide_color: Color = Color(0.58, 0.18, 0.11)
	var wing_color: Color = Color(0.35, 0.08, 0.08)
	if stats.element == "Terra":
		hide_color = Color(0.36, 0.39, 0.25)
		wing_color = Color(0.24, 0.27, 0.17)
	elif stats.element == "Vento":
		hide_color = Color(0.32, 0.55, 0.52)
		wing_color = Color(0.2, 0.39, 0.42)
	elif stats.element == "Água/Gelo" or stats.element == "Água / Gelo":
		hide_color = Color(0.28, 0.48, 0.72)
		wing_color = Color(0.17, 0.33, 0.57)

	var hide: StandardMaterial3D = _material(hide_color)
	var wings: StandardMaterial3D = _material(wing_color)
	var belly: StandardMaterial3D = _material(hide_color.lightened(0.28))
	var horn: StandardMaterial3D = _material(Color(0.88, 0.67, 0.34))
	_add_mesh(visual, _capsule(0.56, 1.8), hide, Vector3(0, 0.86, 0.0), Vector3(PI / 2.0, 0, 0), Vector3(1.0, 1.0, 1.35))
	_add_mesh(visual, _sphere(), belly, Vector3(0, 0.62, -0.1), Vector3.ZERO, Vector3(0.8, 0.65, 1.05))
	_add_mesh(visual, _sphere(), hide, Vector3(0, 1.05, -1.08), Vector3.ZERO, Vector3(0.62, 0.52, 0.62))
	_add_mesh(visual, _sphere(), hide, Vector3(0, 0.95, -1.48), Vector3.ZERO, Vector3(0.38, 0.28, 0.48))
	_add_mesh(visual, _capsule(0.2, 1.5), hide, Vector3(0, 0.8, 1.12), Vector3(-PI / 2.5, 0, 0), Vector3(0.75, 0.7, 0.9))
	_add_mesh(visual, _cylinder(0.08, 0.42), horn, Vector3(-0.25, 1.55, -1.05), Vector3(0, 0, -0.4), Vector3.ONE)
	_add_mesh(visual, _cylinder(0.08, 0.42), horn, Vector3(0.25, 1.55, -1.05), Vector3(0, 0, 0.4), Vector3.ONE)
	for side: float in [-1.0, 1.0]:
		_add_mesh(visual, _sphere(), horn, Vector3(side * 0.24, 1.13, -1.52), Vector3.ZERO, Vector3(0.095, 0.095, 0.07))
		_add_mesh(visual, _capsule(0.15, 0.75), hide, Vector3(side * 0.38, 0.42, -0.3), Vector3(0, 0, side * -0.2), Vector3.ONE)
		_add_mesh(visual, _capsule(0.16, 0.8), hide, Vector3(side * 0.4, 0.42, 0.58), Vector3(0, 0, side * -0.2), Vector3.ONE)
		var wing: MeshInstance3D = _add_mesh(
			visual,
			_box(Vector3(1.55, 0.075, 1.05)),
			wings,
			Vector3(side * 0.88, 1.12, -0.12),
			Vector3(0, 0, side * -0.12),
			Vector3.ONE
		)
		if side < 0.0:
			_left_wing = wing
		else:
			_right_wing = wing


func _material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	return material


func _sphere() -> SphereMesh:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radial_segments = 12
	mesh.rings = 8
	return mesh


func _capsule(radius: float, height: float) -> CapsuleMesh:
	var mesh: CapsuleMesh = CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 10
	mesh.rings = 4
	return mesh


func _cylinder(radius: float, height: float) -> CylinderMesh:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 0.015
	mesh.bottom_radius = radius
	mesh.height = height
	return mesh


func _box(size: Vector3) -> BoxMesh:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	return mesh


func _add_mesh(
	parent: Node3D,
	mesh_resource: Mesh,
	material: Material,
	mesh_position: Vector3,
	mesh_rotation: Vector3,
	mesh_scale: Vector3
) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh_resource
	instance.material_override = material
	instance.position = mesh_position
	instance.rotation = mesh_rotation
	instance.scale = mesh_scale
	parent.add_child(instance)
	return instance
