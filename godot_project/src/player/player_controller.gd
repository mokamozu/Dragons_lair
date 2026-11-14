class_name PlayerController
extends CharacterBody3D

@export_range(1.0, 20.0, 0.1) var walk_speed: float = 4.5
@export_range(1.0, 25.0, 0.1) var run_speed: float = 7.0
@export_range(1.0, 50.0, 0.5) var acceleration: float = 18.0
@export_range(1.0, 15.0, 0.1) var jump_velocity: float = 4.5

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var visual: Node3D = $Visual
@onready var camera_pivot: Node3D = $CameraPivot
@onready var interaction_ray: RayCast3D = $CameraPivot/InteractionRay

var companion: Node3D
var is_mounted: bool = false
var current_prompt: String = ""
var inventory: Dictionary = {}


func _ready() -> void:
	interaction_ray.add_exception(self)
	visual.visible = false
	camera_pivot.call("set_first_person", true)
	_build_placeholder_character()


func _process(_delta: float) -> void:
	_update_interaction_prompt()


func _physics_process(delta: float) -> void:
	if is_mounted:
		_drive_companion()
		return

	var input_vector: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	var move_direction: Vector3 = _camera_relative_direction(input_vector)
	var target_speed: float = run_speed if Input.is_action_pressed("run") else walk_speed
	var target_velocity: Vector3 = move_direction * target_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	if not is_on_floor():
		velocity += get_gravity() * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	if move_direction.length_squared() > 0.01:
		visual.rotation.y = lerp_angle(
			visual.rotation.y,
			atan2(-move_direction.x, -move_direction.z) - global_rotation.y,
			minf(1.0, delta * 12.0)
		)

	move_and_slide()

	if companion != null and Input.is_action_just_pressed("companion_mode"):
		companion.call("toggle_follow_mode")


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and not is_mounted:
		_interact_with_target()
	if Input.is_action_just_pressed("mount") and companion != null:
		if is_mounted:
			companion.call("request_dismount", self)
		else:
			companion.call("request_mount", self)


func set_companion(dragon: Node3D) -> void:
	companion = dragon


func attach_to_dragon(dragon: Node3D, seat: Node3D) -> void:
	if is_mounted:
		return
	is_mounted = true
	companion = dragon
	reparent(dragon, true)
	global_transform = seat.global_transform
	visual.visible = true
	camera_pivot.call("set_first_person", false)
	collision_shape.set_deferred("disabled", true)


func detach_from_dragon(world_position: Vector3) -> void:
	if not is_mounted:
		return
	var scene_root: Node = companion.get_parent() if companion != null else get_tree().current_scene
	if scene_root == null:
		push_error("Não foi possível encontrar a cena para desmontar o jogador.")
		return
	reparent(scene_root, true)
	global_position = world_position
	rotation.y = 0.0
	visual.rotation.y = 0.0
	velocity = Vector3.ZERO
	collision_shape.set_deferred("disabled", false)
	is_mounted = false
	visual.visible = false
	camera_pivot.call("set_first_person", true)


func _drive_companion() -> void:
	if companion == null:
		return
	var input_vector: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	var direction: Vector3 = _camera_relative_direction(input_vector)
	companion.call(
		"set_rider_input",
		direction,
		Input.is_action_pressed("jump"),
		Input.is_action_pressed("fly_down"),
		Input.is_action_pressed("run"),
		1.0 if Input.is_action_pressed("move_forward") else 0.0,
		Input.is_action_just_pressed("jump"),
		Input.is_action_pressed("move_back"),
		camera_pivot.rotation.x
	)


func _camera_relative_direction(input_vector: Vector2) -> Vector3:
	if input_vector.length_squared() < 0.001:
		return Vector3.ZERO
	var camera_basis: Basis = camera_pivot.global_basis
	var forward: Vector3 = -camera_basis.z
	var right: Vector3 = camera_basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()
	return (right * input_vector.x + forward * -input_vector.y).normalized()


func _update_interaction_prompt() -> void:
	current_prompt = ""
	if not is_mounted and interaction_ray.is_colliding():
		var target: Object = interaction_ray.get_collider()
		if target != null and target.has_method("interact"):
			current_prompt = "E  Interagir: %s" % target.get("display_name")


func _interact_with_target() -> void:
	if not interaction_ray.is_colliding():
		return
	var target: Object = interaction_ray.get_collider()
	if target == null or not target.has_method("interact"):
		return
	var result: String = str(target.call("interact", self))
	if target.get("interaction_type") == "resource":
		var resource_name: String = str(target.get("display_name"))
		inventory[resource_name] = int(inventory.get(resource_name, 0)) + int(
			target.get("resource_amount")
		)
	print(result)


func _build_placeholder_character() -> void:
	if not visual.get_children().is_empty():
		return
	var cloth: StandardMaterial3D = _material(Color(0.28, 0.36, 0.55))
	var leather: StandardMaterial3D = _material(Color(0.38, 0.22, 0.12))
	var skin: StandardMaterial3D = _material(Color(0.78, 0.56, 0.38))
	_add_mesh(visual, CapsuleMesh.new(), cloth, Vector3(0.0, 0.9, 0.0), Vector3.ZERO, Vector3(0.72, 0.9, 0.72))
	_add_mesh(visual, SphereMesh.new(), skin, Vector3(0.0, 1.65, 0.0), Vector3.ZERO, Vector3(0.48, 0.48, 0.48))
	_add_mesh(visual, BoxMesh.new(), leather, Vector3(0.0, 1.22, -0.02), Vector3.ZERO, Vector3(0.76, 0.13, 0.78))
	_add_mesh(visual, CapsuleMesh.new(), cloth, Vector3(-0.2, 0.35, 0.0), Vector3.ZERO, Vector3(0.45, 0.55, 0.45))
	_add_mesh(visual, CapsuleMesh.new(), cloth, Vector3(0.2, 0.35, 0.0), Vector3.ZERO, Vector3(0.45, 0.55, 0.45))


func _material(color: Color) -> StandardMaterial3D:
	var result: StandardMaterial3D = StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.9
	return result


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
