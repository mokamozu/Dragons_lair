extends Node3D

signal course_completed(route_index: int, timed_out: bool)

const ROUTES: Array[Dictionary] = [
	{
		"name": "Caminho das Correntes",
		"species": "Serpe das Nuvens",
		"element": "Vento",
		"color": Color(0.35, 0.76, 0.91),
		"description": "+40 Estamina · +15% Velocidade Aérea · planar eficiente",
	},
	{
		"name": "Caminho das Brasas",
		"species": "Draco Vulcânico",
		"element": "Fogo",
		"color": Color(0.94, 0.36, 0.16),
		"description": "+15 Poder Elemental · +10% Dano Crítico · resistência ao calor",
	},
	{
		"name": "Caminho das Raízes",
		"species": "Wyvern da Montanha",
		"element": "Terra",
		"color": Color(0.53, 0.66, 0.3),
		"description": "+50 Vitalidade · +40 Carga",
	},
	{
		"name": "Caminho das Marés",
		"species": "Leviatã das Marés",
		"element": "Água / Gelo",
		"color": Color(0.37, 0.53, 0.91),
		"description": "+25% Regeneração · +20% Agilidade em Curvas · nado rápido",
	},
]
const LANE_CENTERS: Array[float] = [-9.0, -3.0, 3.0, 9.0]
const TIME_LIMIT: float = 180.0
const FINISH_Z: float = -28.0

var time_remaining: float = TIME_LIMIT
var selected_route: int = -1
var timed_out: bool = false
var _course_active: bool = true
var _player: CharacterBody3D
var _camera: Camera3D
var _timer_label: Label
var _route_label: Label
var _result_panel: PanelContainer
var _result_text: Label


func _ready() -> void:
	_build_course()
	_build_player()
	_build_camera()
	_build_hud()


func _process(delta: float) -> void:
	if not _course_active:
		return
	time_remaining = maxf(0.0, time_remaining - delta)
	_timer_label.text = "CHAMA RITUALÍSTICA  ·  %02d:%02d" % [
		int(time_remaining) / 60,
		int(time_remaining) % 60,
	]
	selected_route = _get_route_index(_player.global_position.x)
	_route_label.text = "Rota atual: %s" % str(ROUTES[selected_route]["name"])
	if _player.global_position.z <= FINISH_Z:
		_finish_course(false)
	elif time_remaining <= 0.0:
		_finish_course(true)


func _physics_process(delta: float) -> void:
	if not _course_active:
		return
	var input_vector: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	var direction: Vector3 = Vector3(input_vector.x, 0.0, input_vector.y)
	var speed: float = 10.0 if Input.is_action_pressed("run") else 7.0
	_player.velocity.x = move_toward(_player.velocity.x, direction.x * speed, 24.0 * delta)
	_player.velocity.z = move_toward(_player.velocity.z, direction.z * speed, 24.0 * delta)
	if not _player.is_on_floor():
		_player.velocity += _player.get_gravity() * delta
	elif Input.is_action_just_pressed("jump"):
		_player.velocity.y = 7.5
	_player.move_and_slide()


func _build_course() -> void:
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -25, 0)
	sun.shadow_enabled = true
	add_child(sun)

	var ground: StaticBody3D = StaticBody3D.new()
	ground.name = "CanyonFloor"
	add_child(ground)
	_add_box_visual(ground, Vector3(34, 1, 70), Vector3(0, -0.5, -8), Color(0.31, 0.27, 0.21))
	_add_box_collision(ground, Vector3(34, 1, 70), Vector3(0, -0.5, -8))

	for route_index: int in range(ROUTES.size()):
		_build_route(route_index)
	_build_altar()


func _build_route(route_index: int) -> void:
	var center_x: float = LANE_CENTERS[route_index]
	var route: Dictionary = ROUTES[route_index]
	var lane_color: Color = route["color"]
	_add_box_visual(self, Vector3(5.3, 0.1, 37), Vector3(center_x, 0.08, -10), lane_color.darkened(0.55))
	_add_box_visual(self, Vector3(5.0, 0.06, 37), Vector3(center_x, 0.15, -10), lane_color.darkened(0.72))
	_add_route_sign(route_index, Vector3(center_x, 2.2, 4))

	for barrier_x: float in [center_x - 2.8, center_x + 2.8]:
		_add_box_visual(self, Vector3(0.28, 2.8, 34), Vector3(barrier_x, 1.4, -12), Color(0.36, 0.31, 0.24))
		_add_box_collision(self, Vector3(0.28, 2.8, 34), Vector3(barrier_x, 1.4, -12))

	for obstacle_index: int in range(4):
		var z: float = -2.0 - float(obstacle_index) * 6.0
		var obstacle_height: float = 0.45
		var obstacle_size: Vector3 = Vector3(4.5, obstacle_height, 1.0)
		var obstacle_color: Color = lane_color.lightened(0.05)
		match route_index:
			0:
				obstacle_height = 0.75 if obstacle_index % 2 == 0 else 0.45
				obstacle_size = Vector3(2.2, obstacle_height, 1.4)
				obstacle_color = Color(0.58, 0.69, 0.74)
			1:
				obstacle_height = 0.35
				obstacle_size = Vector3(4.6, obstacle_height, 1.2)
				obstacle_color = Color(0.83, 0.29, 0.13)
			2:
				obstacle_height = 0.95
				obstacle_size = Vector3(4.2, obstacle_height, 1.1)
				obstacle_color = Color(0.43, 0.48, 0.31)
			3:
				obstacle_height = 0.55
				obstacle_size = Vector3(4.4, obstacle_height, 1.25)
				obstacle_color = Color(0.39, 0.53, 0.79)
		var offset_x: float = 0.0
		if route_index == 0:
			offset_x = -0.5 if obstacle_index % 2 == 0 else 0.5
		_add_box_visual(
			self,
			obstacle_size,
			Vector3(center_x + offset_x, 0.22 + obstacle_size.y * 0.5, z),
			obstacle_color,
			Vector3(0, 0, 0.05 * float(obstacle_index % 2))
		)
		var collision: StaticBody3D = StaticBody3D.new()
		add_child(collision)
		_add_box_collision(collision, obstacle_size, Vector3(center_x + offset_x, 0.22 + obstacle_size.y * 0.5, z))

	for pillar_index: int in range(4):
		var side: float = -1.0 if pillar_index % 2 == 0 else 1.0
		_add_box_visual(
			self,
			Vector3(0.35, 2.6, 0.35),
			Vector3(center_x + side * 2.3, 1.3, -float(pillar_index) * 7.0 - 4.0),
			lane_color.darkened(0.2)
		)


func _add_route_sign(route_index: int, position: Vector3) -> void:
	var post: MeshInstance3D = _add_box_visual(
		self,
		Vector3(0.2, 2.0, 0.2),
		position + Vector3(0, -0.8, 0),
		Color(0.3, 0.2, 0.12)
	)
	post.name = "RouteSignPost"
	var sign: Label3D = Label3D.new()
	sign.text = "%s\n%s" % [str(route_index + 1), str(ROUTES[route_index]["name"])]
	sign.position = position
	sign.font_size = 34
	sign.pixel_size = 0.012
	sign.modulate = ROUTES[route_index]["color"]
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(sign)


func _build_altar() -> void:
	_add_box_visual(self, Vector3(27, 0.5, 2), Vector3(0, 0.4, FINISH_Z), Color(0.73, 0.58, 0.31))
	var marker: Label3D = Label3D.new()
	marker.text = "ALTAR DA ECLOSÃO"
	marker.position = Vector3(0, 2.8, FINISH_Z - 1.0)
	marker.font_size = 48
	marker.pixel_size = 0.015
	marker.modulate = Color(1.0, 0.79, 0.39)
	marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(marker)


func _build_player() -> void:
	_player = CharacterBody3D.new()
	_player.name = "AprendizComOvo"
	_player.position = Vector3(0, 0.05, 12)
	add_child(_player)
	var collision: CollisionShape3D = CollisionShape3D.new()
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.38
	capsule.height = 1.7
	collision.shape = capsule
	collision.position.y = 0.85
	_player.add_child(collision)
	var body: MeshInstance3D = MeshInstance3D.new()
	var body_mesh: CapsuleMesh = CapsuleMesh.new()
	body_mesh.radius = 0.36
	body_mesh.height = 1.7
	body.mesh = body_mesh
	body.position.y = 0.85
	body.material_override = _material(Color(0.31, 0.35, 0.51))
	_player.add_child(body)
	var egg: MeshInstance3D = MeshInstance3D.new()
	var egg_mesh: SphereMesh = SphereMesh.new()
	egg_mesh.radius = 0.27
	egg_mesh.height = 0.58
	egg.mesh = egg_mesh
	egg.position = Vector3(0.47, 1.15, -0.15)
	egg.material_override = _material(Color(0.85, 0.69, 0.39))
	_player.add_child(egg)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.position = Vector3(0, 29, 31)
	_camera.rotation_degrees = Vector3(-39, 0, 0)
	_camera.current = true
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = 50
	add_child(_camera)


func _build_hud() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	add_child(canvas)
	var panel: PanelContainer = PanelContainer.new()
	panel.position = Vector2(18, 18)
	panel.custom_minimum_size = Vector2(490, 0)
	panel.add_theme_stylebox_override("panel", _panel_style())
	canvas.add_child(panel)
	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 6)
	panel.add_child(layout)
	_add_label(layout, "A TRILHA DA SOBREVIVÊNCIA", 22, Color(0.98, 0.83, 0.55))
	_timer_label = _add_label(layout, "CHAMA RITUALÍSTICA  ·  03:00", 18, Color(1.0, 0.52, 0.32))
	_route_label = _add_label(layout, "Escolha uma das quatro rotas.", 15, Color(0.91, 0.9, 0.83))
	_add_label(layout, "WASD: correr · Shift: correr rápido · Espaço: saltar · alcance o altar.", 13, Color(0.83, 0.83, 0.78))

	_result_panel = PanelContainer.new()
	_result_panel.anchor_left = 0.5
	_result_panel.anchor_right = 0.5
	_result_panel.anchor_top = 0.5
	_result_panel.anchor_bottom = 0.5
	_result_panel.offset_left = -360
	_result_panel.offset_right = 360
	_result_panel.offset_top = -170
	_result_panel.offset_bottom = 170
	_result_panel.add_theme_stylebox_override("panel", _panel_style())
	_result_panel.visible = false
	canvas.add_child(_result_panel)
	var result_layout: VBoxContainer = VBoxContainer.new()
	result_layout.alignment = BoxContainer.ALIGNMENT_CENTER
	result_layout.add_theme_constant_override("separation", 16)
	_result_panel.add_child(result_layout)
	_result_text = _add_label(result_layout, "", 21, Color(0.97, 0.89, 0.72))
	_result_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var continue_button: Button = Button.new()
	continue_button.text = "Levar o ovo ao Altar da Eclosão"
	continue_button.custom_minimum_size = Vector2(0, 48)
	continue_button.pressed.connect(_continue_to_battle)
	result_layout.add_child(continue_button)


func _finish_course(expired: bool) -> void:
	if not _course_active:
		return
	_course_active = false
	timed_out = expired
	selected_route = _get_route_index(_player.global_position.x)
	var route: Dictionary = ROUTES[selected_route]
	if expired:
		_result_text.text = "A chama se apagou antes da chegada. O ovo eclode no setor mais próximo: %s (%s). O filhote começa o primeiro dia exausto." % [
			route["species"],
			route["element"],
		]
	else:
		_result_text.text = "Você concluiu a trilha pela rota escolhida. O ovo desperta como %s, afinado ao elemento %s.\n\n%s" % [
			route["species"],
			route["element"],
			route["description"],
		]
	_result_panel.visible = true


func _continue_to_battle() -> void:
	course_completed.emit(selected_route, timed_out)


func _get_route_index(position_x: float) -> int:
	var nearest: int = 0
	var distance: float = absf(position_x - LANE_CENTERS[0])
	for index: int in range(1, LANE_CENTERS.size()):
		var candidate_distance: float = absf(position_x - LANE_CENTERS[index])
		if candidate_distance < distance:
			distance = candidate_distance
			nearest = index
	return nearest


func _add_label(parent: Node, text: String, size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.075, 0.08, 0.91)
	style.border_color = Color(0.59, 0.44, 0.24)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style


func _material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.86
	return material


func _add_box_visual(
	parent: Node3D,
	size: Vector3,
	position: Vector3,
	color: Color,
	rotation: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = position
	instance.rotation = rotation
	instance.material_override = _material(color)
	parent.add_child(instance)
	return instance


func _add_box_collision(parent: Node3D, size: Vector3, position: Vector3) -> StaticBody3D:
	var body: StaticBody3D = parent as StaticBody3D
	if body == null:
		body = StaticBody3D.new()
		parent.add_child(body)
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	collision.position = position
	body.add_child(collision)
	return body
