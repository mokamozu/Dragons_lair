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
@export_range(0.5, 10.0, 0.1) var follow_distance: float = 3.0
@export_range(1.0, 30.0, 0.5) var flight_speed: float = 11.0
@export_range(1.0, 30.0, 0.5) var boost_speed: float = 16.0

@onready var visual: Node3D = $Visual
@onready var seat: Marker3D = $Seat

var state: CompanionState = CompanionState.FOLLOWING
var follow_target: Node3D
var rider: Node3D
var current_hp: float = 120.0
var current_stamina: float = 100.0
var _rider_direction: Vector3 = Vector3.ZERO
var _rider_ascending: bool = false
var _rider_descending: bool = false
var _rider_boosting: bool = false
var _wing_phase: float = 0.0
var _left_wing: Node3D
var _right_wing: Node3D


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
	visual.rotation.z = lerpf(visual.rotation.z, -_rider_direction.x * 0.08, minf(delta * 4.0, 1.0))


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
	boosting: bool
) -> void:
	_rider_direction = direction
	_rider_ascending = ascending
	_rider_descending = descending
	_rider_boosting = boosting


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
	if not is_flying and _rider_ascending and current_stamina > 0.0:
		state = CompanionState.MOUNTED_FLYING
		is_flying = true

	var horizontal_direction: Vector3 = _rider_direction
	horizontal_direction.y = 0.0
	if horizontal_direction.length_squared() > 1.0:
		horizontal_direction = horizontal_direction.normalized()
	var speed: float = stats.movement_speed if not is_flying else flight_speed
	if _rider_boosting and current_stamina > 0.0:
		speed = boost_speed
		current_stamina = maxf(
			0.0,
			current_stamina - 18.0 * stats.flight_stamina_cost_multiplier * delta
		)
	elif is_flying and _rider_ascending and current_stamina > 0.0:
		current_stamina = maxf(
			0.0,
			current_stamina - 12.0 * stats.flight_stamina_cost_multiplier * delta
		)
	else:
		current_stamina = minf(
			stats.max_stamina,
			current_stamina + 8.0 * stats.stamina_regen_multiplier * delta
		)

	velocity.x = move_toward(velocity.x, horizontal_direction.x * speed, 8.0 * delta)
	velocity.z = move_toward(velocity.z, horizontal_direction.z * speed, 8.0 * delta)
	if horizontal_direction.length_squared() > 0.01:
		_face_direction(horizontal_direction, delta)

	if is_flying:
		if _rider_ascending and current_stamina > 0.0:
			velocity.y = move_toward(velocity.y, 4.0, 8.0 * delta)
		elif _rider_descending:
			velocity.y = move_toward(velocity.y, -4.5, 8.0 * delta)
		else:
			velocity.y = move_toward(velocity.y, -0.7, 1.5 * delta)
	else:
		_apply_ground_gravity(delta)

	move_and_slide()
	if is_on_floor():
		velocity.y = 0.0
		if state == CompanionState.MOUNTED_FLYING:
			state = CompanionState.MOUNTED


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
	if not visual.get_children().is_empty():
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
