extends Node3D

const INTERACTABLE_SCRIPT: Script = preload("res://src/interaction/interactable.gd")

var _materials: Dictionary = {}


func _ready() -> void:
	_create_materials()
	_create_lighting()
	_create_ground()
	_create_path()
	_create_house()
	_create_farm()
	_create_fences()
	_create_trees()
	_create_rocks()
	_create_hillside()


func _create_materials() -> void:
	_materials = {
		"grass": _material(Color(0.24, 0.38, 0.22)),
		"grass_light": _material(Color(0.34, 0.48, 0.27)),
		"wood": _material(Color(0.33, 0.19, 0.1)),
		"wood_light": _material(Color(0.49, 0.31, 0.16)),
		"stone": _material(Color(0.4, 0.42, 0.4)),
		"stone_light": _material(Color(0.57, 0.56, 0.49)),
		"roof": _material(Color(0.42, 0.16, 0.12)),
		"wall": _material(Color(0.7, 0.61, 0.42)),
		"soil": _material(Color(0.24, 0.15, 0.08)),
		"crop": _material(Color(0.42, 0.58, 0.25)),
	}


func _create_lighting() -> void:
	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky: Sky = Sky.new()
	var sky_material: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.24, 0.44, 0.62)
	sky_material.sky_horizon_color = Color(0.78, 0.78, 0.68)
	sky_material.ground_bottom_color = Color(0.16, 0.2, 0.16)
	sky_material.ground_horizon_color = Color(0.45, 0.5, 0.38)
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.68, 0.72, 0.72)
	environment.ambient_light_energy = 0.55
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)

	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -32.0, 0.0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)


func _create_ground() -> void:
	var ground: StaticBody3D = StaticBody3D.new()
	ground.name = "Ground"
	add_child(ground)
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(120.0, 120.0)
	_add_mesh(ground, plane, _materials.grass, Vector3.ZERO)
	_add_box_collider(ground, Vector3(120.0, 0.5, 120.0), Vector3(0, -0.25, 0))


func _create_path() -> void:
	for index: int in range(10):
		var z: float = 8.0 - float(index) * 2.0
		var path_piece: MeshInstance3D = _add_mesh(
			self,
			_box(Vector3(2.2, 0.08, 1.8)),
			_materials.wood_light if index % 3 == 0 else _materials.stone_light,
			Vector3(0.0, 0.035, z)
		)
		path_piece.rotation.y = 0.08 if index % 2 == 0 else -0.05

	for index: int in range(6):
		_add_mesh(
			self,
			_box(Vector3(1.4, 0.06, 1.3)),
			_materials.stone_light,
			Vector3(-1.0 - float(index) * 1.1, 0.04, -9.0 - float(index) * 0.7)
		)


func _create_house() -> void:
	var house: Node3D = Node3D.new()
	house.name = "Farmhouse"
	house.position = Vector3(-8.0, 0.0, -7.0)
	add_child(house)
	_add_box_visual(house, Vector3(6.0, 3.2, 5.0), Vector3(0, 1.6, 0), _materials.wall)
	_add_box_visual(house, Vector3(6.8, 0.35, 3.2), Vector3(0, 3.25, -0.8), _materials.roof, Vector3(-0.45, 0, 0))
	_add_box_visual(house, Vector3(6.8, 0.35, 3.2), Vector3(0, 3.25, 0.8), _materials.roof, Vector3(0.45, 0, 0))
	_add_box_visual(house, Vector3(0.55, 1.8, 0.18), Vector3(0, 0.9, 2.58), _materials.wood_light)
	_add_box_collider(house, Vector3(6.0, 3.2, 5.0), Vector3(0, 1.6, 0))

	var door: StaticBody3D = StaticBody3D.new()
	door.name = "FarmhouseDoor"
	door.position = Vector3(-8.0, 0.9, -4.38)
	door.set_script(INTERACTABLE_SCRIPT)
	door.set("interaction_type", "door")
	door.set("display_name", "Porta da casa")
	add_child(door)
	_add_mesh(door, _box(Vector3(1.05, 1.8, 0.18)), _materials.wood_light, Vector3.ZERO)
	_add_box_collider(door, Vector3(1.05, 1.8, 0.18), Vector3.ZERO)

	_add_box_visual(house, Vector3(0.45, 2.0, 0.45), Vector3(-2.0, 4.0, -1.5), _materials.stone)


func _create_farm() -> void:
	for row: int in range(3):
		for column: int in range(3):
			var plot: StaticBody3D = StaticBody3D.new()
			plot.name = "FarmPlot_%d_%d" % [row, column]
			plot.position = Vector3(5.5 + float(column) * 2.0, 0.13, -5.0 - float(row) * 1.7)
			plot.set_script(INTERACTABLE_SCRIPT)
			plot.set("interaction_type", "farm_plot")
			plot.set("display_name", "Canteiro")
			add_child(plot)
			_add_mesh(plot, _box(Vector3(1.65, 0.22, 1.35)), _materials.soil, Vector3.ZERO)
			_add_box_collider(plot, Vector3(1.65, 0.22, 1.35), Vector3.ZERO)
			for plant_index: int in range(3):
				var plant_position: Vector3 = Vector3(-0.48 + float(plant_index) * 0.48, 0.23, 0.0)
				_add_mesh(
					plot,
					_cylinder(0.06, 0.45),
					_materials.crop,
					plant_position,
					Vector3(0.08 * float(plant_index - 1), 0, 0)
				)
				_add_mesh(
					plot,
					_sphere(0.17),
					_materials.grass_light,
					plant_position + Vector3(0.0, 0.22, 0.0)
				)


func _create_fences() -> void:
	_fence_line(Vector3(3.0, 0.0, -3.2), 8, Vector3(1.0, 0.0, 0.0))
	_fence_line(Vector3(3.0, 0.0, -10.6), 8, Vector3(1.0, 0.0, 0.0))
	_fence_line(Vector3(3.0, 0.0, -3.2), 8, Vector3(0.0, 0.0, -1.0))
	_fence_line(Vector3(10.0, 0.0, -3.2), 8, Vector3(0.0, 0.0, -1.0))


func _fence_line(start: Vector3, post_count: int, direction: Vector3) -> void:
	for index: int in range(post_count):
		var position: Vector3 = start + direction * float(index)
		_add_box_visual(self, Vector3(0.16, 1.0, 0.16), position + Vector3(0, 0.5, 0), _materials.wood)
		if index < post_count - 1:
			for rail_height: float in [0.36, 0.74]:
				var rail_position: Vector3 = position + direction * 0.5 + Vector3(0, rail_height, 0)
				var rail_size: Vector3 = Vector3(1.05, 0.1, 0.12) if direction.x != 0.0 else Vector3(0.12, 0.1, 1.05)
				_add_box_visual(self, rail_size, rail_position, _materials.wood_light)


func _create_trees() -> void:
	var tree_positions: Array[Vector3] = [
		Vector3(15, 0, -6), Vector3(18, 0, -12), Vector3(13, 0, -19),
		Vector3(-17, 0, -9), Vector3(-22, 0, -16), Vector3(17, 0, 12),
		Vector3(-17, 0, 13), Vector3(-11, 0, 18), Vector3(24, 0, 3),
	]
	for index: int in range(tree_positions.size()):
		_create_tree(tree_positions[index], 1.0 + float(index % 3) * 0.12)


func _create_tree(tree_position: Vector3, size: float) -> void:
	var trunk: StaticBody3D = StaticBody3D.new()
	trunk.name = "OakTrunk"
	trunk.position = tree_position
	trunk.set_script(INTERACTABLE_SCRIPT)
	trunk.set("interaction_type", "resource")
	trunk.set("display_name", "Madeira")
	trunk.set("resource_amount", 2)
	add_child(trunk)
	_add_mesh(trunk, _cylinder(0.28, 2.2), _materials.wood, Vector3(0, 1.1, 0))
	_add_cylinder_collider(trunk, 0.28, 2.2, Vector3(0, 1.1, 0))
	_add_mesh(self, _sphere(1.1), _materials.grass_light, tree_position + Vector3(0, 2.7 * size, 0), Vector3.ZERO, Vector3(1.2 * size, 1.25 * size, 1.2 * size))
	_add_mesh(self, _sphere(0.83), _materials.grass, tree_position + Vector3(-0.6, 2.3 * size, 0.2), Vector3.ZERO, Vector3.ONE * size)
	_add_mesh(self, _sphere(0.85), _materials.grass, tree_position + Vector3(0.55, 2.35 * size, -0.15), Vector3.ZERO, Vector3.ONE * size)


func _create_rocks() -> void:
	for index: int in range(9):
		var x: float = -18.0 + float((index * 7) % 38)
		var z: float = -22.0 + float((index * 11) % 42)
		var rock_position: Vector3 = Vector3(x, 0.0, z)
		var rock: StaticBody3D = StaticBody3D.new()
		rock.name = "ResourceRock_%d" % index
		rock.position = rock_position
		rock.set_script(INTERACTABLE_SCRIPT)
		rock.set("interaction_type", "resource")
		rock.set("display_name", "Pedra")
		rock.set("resource_amount", 1)
		add_child(rock)
		var rock_size: Vector3 = Vector3(0.8 + float(index % 3) * 0.15, 0.65, 0.7)
		_add_mesh(rock, _sphere(0.65), _materials.stone, Vector3(0, 0.42, 0), Vector3(0, float(index), 0), rock_size)
		_add_sphere_collider(rock, 0.55, Vector3(0, 0.45, 0))


func _create_hillside() -> void:
	_add_mesh(
		self,
		_sphere(1.0),
		_materials.grass,
		Vector3(-31.0, 0.0, -18.0),
		Vector3.ZERO,
		Vector3(15.0, 7.0, 13.0)
	)
	for index: int in range(6):
		var ledge_position: Vector3 = Vector3(-30.0 + float(index) * 2.4, 0.8 + float(index) * 0.55, -9.0)
		_add_box_visual(self, Vector3(3.0, 0.35, 5.0), ledge_position, _materials.stone)


func _material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.92
	return material


func _box(size: Vector3) -> BoxMesh:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	return mesh


func _sphere(radius: float) -> SphereMesh:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 12
	mesh.rings = 8
	return mesh


func _cylinder(radius: float, height: float) -> CylinderMesh:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius * 0.82
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 10
	return mesh


func _add_box_visual(
	parent: Node3D,
	size: Vector3,
	position: Vector3,
	material: Material,
	rotation: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var instance: MeshInstance3D = _add_mesh(parent, _box(size), material, position)
	instance.rotation = rotation
	return instance


func _add_mesh(
	parent: Node3D,
	mesh_resource: Mesh,
	material: Material,
	position: Vector3,
	rotation: Vector3 = Vector3.ZERO,
	mesh_scale: Vector3 = Vector3.ONE
) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh_resource
	instance.material_override = material
	instance.position = position
	instance.rotation = rotation
	instance.scale = mesh_scale
	parent.add_child(instance)
	return instance


func _add_box_collider(parent: Node3D, size: Vector3, position: Vector3) -> void:
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	collision.position = position
	parent.add_child(collision)


func _add_cylinder_collider(parent: Node3D, radius: float, height: float, position: Vector3) -> void:
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: CylinderShape3D = CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	collision.shape = shape
	collision.position = position
	parent.add_child(collision)


func _add_sphere_collider(parent: Node3D, radius: float, position: Vector3) -> void:
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: SphereShape3D = SphereShape3D.new()
	shape.radius = radius
	collision.shape = shape
	collision.position = position
	parent.add_child(collision)
