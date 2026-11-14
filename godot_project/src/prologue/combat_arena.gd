extends Node3D

signal battle_completed(result: String, trait_name: String, weapon: String)

const WEAPONS: Array[Dictionary] = [
	{"name":"Espada e Escudo","category":"Pesado","style":"Bloqueio e contra-ataque","synergy":"Segura a atenção enquanto o dragão ataca","damage":22.0,"range":3.0,"cooldown":0.65,"defense":0.55},
	{"name":"Machado de Batalha","category":"Pesado","style":"Golpes amplos e quebra de armadura","synergy":"Abre brechas para o sopro elemental","damage":34.0,"range":3.4,"cooldown":1.0,"defense":0.0},
	{"name":"Martelo de Guerra","category":"Pesado","style":"Impacto e atordoamento","synergy":"Derruba inimigos para ataques aéreos","damage":32.0,"range":3.1,"cooldown":1.05,"defense":0.0},
	{"name":"Lança","category":"Ágil","style":"Estocadas rápidas de médio alcance","synergy":"Avança em sincronia com o dragão","damage":23.0,"range":4.2,"cooldown":0.55,"defense":0.0},
	{"name":"Adagas Duplas","category":"Ágil","style":"Combos velozes e críticos","synergy":"Aproveita distrações para atacar pelas costas","damage":15.0,"range":2.5,"cooldown":0.3,"defense":0.0},
	{"name":"Grimório Elemental","category":"Magia","style":"Projéteis elementais à distância","synergy":"Combina elementos com o sopro do dragão","damage":23.0,"range":10.0,"cooldown":0.6,"defense":0.0},
	{"name":"Grimório Necrótico","category":"Magia","style":"Maldição, dano contínuo e dreno","synergy":"Enfraquece o inimigo e recupera vitalidade","damage":19.0,"range":9.0,"cooldown":0.7,"defense":0.0},
	{"name":"Grimório Sagrado","category":"Magia","style":"Barreira, cura e bênçãos","synergy":"Pode restaurar a vitalidade do dragão","damage":16.0,"range":8.0,"cooldown":0.7,"defense":0.0},
]

var selected_weapon: Dictionary = {}
var race_data: Dictionary = {}
var dragon_exhausted: bool = false
var player_hp: float = 100.0
var golem_hp: float = 240.0
var battle_time: float = 0.0
var _battle_started: bool = false
var _battle_finished: bool = false
var _attack_cooldown: float = 0.0
var _enemy_attack_cooldown: float = 0.0
var _stun_time: float = 0.0
var _attacks_landed: int = 0
var _dragon_attack_timer: float = 1.5
var _battle_result: String = ""
var _trait_name: String = ""
var _player: CharacterBody3D
var _golem: CharacterBody3D
var _baby_dragon: Node3D
var _weapon_panel: PanelContainer
var _result_panel: PanelContainer
var _result_text: Label
var _player_bar: ProgressBar
var _golem_bar: ProgressBar
var _battle_status: Label
var _battle_timer: Label


func _ready() -> void:
	_build_arena()
	_build_combatants()
	_build_ui()


func _process(delta: float) -> void:
	if not _battle_started or _battle_finished:
		return
	battle_time += delta
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_enemy_attack_cooldown = maxf(0.0, _enemy_attack_cooldown - delta)
	_stun_time = maxf(0.0, _stun_time - delta)
	_dragon_attack_timer = maxf(0.0, _dragon_attack_timer - delta)
	if _baby_dragon != null:
		var companion_target: Vector3 = _player.global_position + Vector3(-1.15, 0.3, 1.0)
		_baby_dragon.global_position = _baby_dragon.global_position.lerp(
			companion_target,
			minf(1.0, delta * 5.0)
		)
	_player_bar.value = player_hp
	_golem_bar.value = golem_hp
	_battle_timer.text = "Tempo: %02d:%02d" % [int(battle_time) / 60, int(battle_time) % 60]
	if Input.is_action_just_pressed("attack") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_try_player_attack()


func _physics_process(delta: float) -> void:
	if not _battle_started or _battle_finished:
		return
	var input_vector: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	var direction: Vector3 = Vector3(input_vector.x, 0.0, input_vector.y)
	var speed: float = 7.5 if Input.is_action_pressed("run") else 5.0
	_player.velocity.x = move_toward(_player.velocity.x, direction.x * speed, 24.0 * delta)
	_player.velocity.z = move_toward(_player.velocity.z, direction.z * speed, 24.0 * delta)
	if not _player.is_on_floor():
		_player.velocity += _player.get_gravity() * delta
	elif Input.is_action_just_pressed("jump"):
		_player.velocity.y = 5.0
	_player.move_and_slide()

	if _stun_time <= 0.0:
		var to_player: Vector3 = _player.global_position - _golem.global_position
		to_player.y = 0.0
		var distance: float = to_player.length()
		if distance > 2.0:
			var chase: Vector3 = to_player.normalized()
			_golem.velocity.x = move_toward(_golem.velocity.x, chase.x * 2.5, 6.0 * delta)
			_golem.velocity.z = move_toward(_golem.velocity.z, chase.z * 2.5, 6.0 * delta)
			_golem.rotation.y = lerp_angle(
				_golem.rotation.y,
				atan2(-chase.x, -chase.z),
				minf(1.0, delta * 5.0)
			)
		else:
			_golem.velocity.x = move_toward(_golem.velocity.x, 0.0, 10.0 * delta)
			_golem.velocity.z = move_toward(_golem.velocity.z, 0.0, 10.0 * delta)
			if _enemy_attack_cooldown <= 0.0:
				_enemy_attack_cooldown = 1.25
				var defense: float = float(selected_weapon.get("defense", 0.0))
				player_hp = maxf(0.0, player_hp - 12.0 * (1.0 - defense))
				_battle_status.text = "O Guardião ataca. HP: %d / 100" % roundi(player_hp)
				if player_hp <= 0.0:
					_finish_battle("defeat")
	_golem.move_and_slide()
	if not _battle_finished and _dragon_attack_timer <= 0.0:
		if _baby_dragon.global_position.distance_to(_golem.global_position) <= 11.0:
			_dragon_attack_timer = 2.5
			golem_hp = maxf(0.0, golem_hp - 9.0)
			_battle_status.text = "Seu filhote ataca em sincronia com você!"
			if golem_hp <= 0.0:
				_finish_battle("victory")


func _build_arena() -> void:
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)

	var floor: StaticBody3D = StaticBody3D.new()
	add_child(floor)
	_add_box_visual(floor, Vector3(34, 1, 34), Vector3(0, -0.5, 0), Color(0.29, 0.27, 0.25))
	_add_box_collision(floor, Vector3(34, 1, 34), Vector3(0, -0.5, 0))
	for index: int in range(12):
		var angle: float = TAU * float(index) / 12.0
		var position: Vector3 = Vector3(cos(angle) * 13.5, 2.0, sin(angle) * 13.5)
		_add_box_visual(self, Vector3(2.7, 4.0, 1.0), position, Color(0.32, 0.3, 0.29), Vector3(0, -angle, 0))
		var rune: MeshInstance3D = _add_sphere(
			self,
			position + Vector3(0, 1.1, 0),
			0.2,
			Color(0.2, 0.75, 0.88)
		)
		var rune_material: StandardMaterial3D = rune.material_override
		rune_material.emission_enabled = true
		rune_material.emission = rune_material.albedo_color
	_add_box_visual(self, Vector3(4.0, 0.45, 4.0), Vector3(0, 0.22, -9), Color(0.39, 0.31, 0.22))
	_add_sphere(self, Vector3(0, 0.85, -9), 0.42, Color(0.45, 0.75, 0.94))
	_build_weapon_pedestals()

	var camera: Camera3D = Camera3D.new()
	camera.position = Vector3(0, 15, 20)
	camera.rotation_degrees = Vector3(-33, 0, 0)
	camera.current = true
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 27.0
	add_child(camera)


func _build_weapon_pedestals() -> void:
	for index: int in range(WEAPONS.size()):
		var angle: float = TAU * float(index) / float(WEAPONS.size())
		var stand_position: Vector3 = Vector3(cos(angle) * 9.0, 0.0, sin(angle) * 9.0)
		_add_cylinder_visual(0.78, 0.55, stand_position + Vector3(0, 0.27, 0), Color(0.48, 0.37, 0.23))
		var display_color: Color = Color(0.77, 0.69, 0.48)
		var weapon_name: String = str(WEAPONS[index]["name"])
		if weapon_name.begins_with("Grimório"):
			_add_box_visual(
				self,
				Vector3(0.45, 0.65, 0.18),
				stand_position + Vector3(0, 0.88, 0),
				Color(0.25, 0.2, 0.37)
			)
			_add_sphere(self, stand_position + Vector3(0, 1.1, -0.12), 0.09, Color(0.39, 0.8, 0.97))
		else:
			_add_box_visual(
				self,
				Vector3(0.12, 0.95, 0.12),
				stand_position + Vector3(0, 1.0, 0),
				display_color,
				Vector3(0, 0, 0.1 * float(index % 2))
			)
			if weapon_name == "Espada e Escudo":
				_add_box_visual(
					self,
					Vector3(0.42, 0.55, 0.14),
					stand_position + Vector3(0.3, 0.78, 0.08),
					Color(0.38, 0.48, 0.56)
				)
		var marker: Label3D = Label3D.new()
		marker.text = "%d  ·  %s" % [index + 1, weapon_name]
		marker.position = stand_position + Vector3(0, 1.65, 0)
		marker.font_size = 24
		marker.pixel_size = 0.009
		marker.modulate = Color(0.94, 0.84, 0.63)
		marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(marker)


func _build_combatants() -> void:
	_player = _make_character("Aprendiz", Vector3(-4, 0.05, 0), Color(0.34, 0.43, 0.62), 0.42, 1.8)
	_golem = _make_character("Guardião Rúnico", Vector3(0, 0.05, -7), Color(0.38, 0.42, 0.46), 0.85, 2.8)
	_add_sphere(_golem, Vector3(0, 1.9, -0.22), 0.24, Color(0.26, 0.84, 1.0))
	_add_sphere(_golem, Vector3(-0.3, 2.05, -0.18), 0.12, Color(1.0, 0.37, 0.16))
	_add_sphere(_golem, Vector3(0.3, 2.05, -0.18), 0.12, Color(1.0, 0.37, 0.16))
	_baby_dragon = _build_baby_dragon()


func _build_baby_dragon() -> Node3D:
	var dragon: Node3D = Node3D.new()
	dragon.name = "Filhote"
	dragon.position = Vector3(-5.3, 0.25, 1.0)
	add_child(dragon)
	var element_color: Color = Color(0.58, 0.2, 0.12)
	if not race_data.is_empty():
		match str(race_data.get("element", "")):
			"Vento":
				element_color = Color(0.35, 0.72, 0.82)
			"Terra":
				element_color = Color(0.4, 0.48, 0.27)
			"Água / Gelo":
				element_color = Color(0.3, 0.51, 0.82)
	if dragon_exhausted:
		element_color = element_color.darkened(0.32)
	var wing_color: Color = element_color.darkened(0.35)
	_add_sphere(dragon, Vector3(0, 0.7, 0), 0.72, element_color)
	_add_sphere(dragon, Vector3(0, 1.02, -0.72), 0.44, element_color)
	_add_sphere(dragon, Vector3(0, 0.3, 0.65), 0.42, element_color)
	for side: float in [-1.0, 1.0]:
		_add_sphere(dragon, Vector3(side * 0.45, 0.32, -0.1), 0.3, element_color)
		_add_box_visual(
			dragon,
			Vector3(0.9, 0.08, 0.65),
			Vector3(side * 0.63, 1.0, 0.05),
			wing_color,
			Vector3(0, 0, side * -0.2)
		)
	_add_sphere(dragon, Vector3(-0.16, 1.1, -1.03), 0.08, Color(1.0, 0.72, 0.25))
	_add_sphere(dragon, Vector3(0.16, 1.1, -1.03), 0.08, Color(1.0, 0.72, 0.25))
	return dragon


func _build_ui() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	add_child(canvas)
	var hud: PanelContainer = PanelContainer.new()
	hud.position = Vector2(18, 18)
	hud.custom_minimum_size = Vector2(350, 0)
	hud.add_theme_stylebox_override("panel", _panel_style())
	canvas.add_child(hud)
	var hud_layout: VBoxContainer = VBoxContainer.new()
	hud_layout.add_theme_constant_override("separation", 6)
	hud.add_child(hud_layout)
	_add_label(hud_layout, "A PROVA DE AÇO E MAGIA", 19, Color(1.0, 0.84, 0.56))
	_player_bar = _make_bar(hud_layout, Color(0.72, 0.19, 0.16), "Cavaleiro")
	_golem_bar = _make_bar(hud_layout, Color(0.19, 0.62, 0.76), "Guardião Rúnico")
	_battle_timer = _add_label(hud_layout, "Tempo: 00:00", 14, Color(0.93, 0.9, 0.81))
	_battle_status = _add_label(hud_layout, "Escolha sua arma inicial.", 14, Color(0.9, 0.82, 0.66))

	_weapon_panel = PanelContainer.new()
	_weapon_panel.anchor_left = 0.5
	_weapon_panel.anchor_right = 0.5
	_weapon_panel.anchor_top = 0.5
	_weapon_panel.anchor_bottom = 0.5
	_weapon_panel.offset_left = -500
	_weapon_panel.offset_right = 500
	_weapon_panel.offset_top = -300
	_weapon_panel.offset_bottom = 300
	_weapon_panel.add_theme_stylebox_override("panel", _panel_style())
	canvas.add_child(_weapon_panel)
	var selection_layout: VBoxContainer = VBoxContainer.new()
	selection_layout.add_theme_constant_override("separation", 10)
	_weapon_panel.add_child(selection_layout)
	_add_label(selection_layout, "ESCOLHA SUA ARMA INICIAL", 25, Color(1.0, 0.84, 0.56))
	_add_label(selection_layout, "A escolha será registrada no Pergaminho de Vínculo e acompanhará você na jornada.", 15, Color(0.9, 0.86, 0.75))
	for row_index: int in range(2):
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 9)
		selection_layout.add_child(row)
		for column: int in range(4):
			var weapon_index: int = row_index * 4 + column
			row.add_child(_make_weapon_button(weapon_index))
	_add_label(selection_layout, "WASD: mover · Espaço: esquivar/saltar · J ou clique esquerdo: atacar · Shift: correr", 13, Color(0.82, 0.81, 0.76))

	_result_panel = PanelContainer.new()
	_result_panel.anchor_left = 0.5
	_result_panel.anchor_right = 0.5
	_result_panel.anchor_top = 0.5
	_result_panel.anchor_bottom = 0.5
	_result_panel.offset_left = -370
	_result_panel.offset_right = 370
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
	continue_button.text = "Receber o Pergaminho de Vínculo"
	continue_button.custom_minimum_size = Vector2(0, 48)
	continue_button.pressed.connect(_continue_from_battle)
	result_layout.add_child(continue_button)


func _make_weapon_button(index: int) -> Button:
	var weapon: Dictionary = WEAPONS[index]
	var button: Button = Button.new()
	button.custom_minimum_size = Vector2(225, 125)
	button.text = "%s\n%s\n%s\n%s" % [
		weapon["name"],
		weapon["category"],
		weapon["style"],
		weapon["synergy"],
	]
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", 13)
	button.pressed.connect(_select_weapon.bind(index))
	return button


func _select_weapon(index: int) -> void:
	if _battle_started:
		return
	selected_weapon = WEAPONS[index]
	_weapon_panel.visible = false
	_battle_started = true
	_battle_status.text = "%s selecionada. Derrote o Guardião Rúnico!" % selected_weapon["name"]
	if dragon_exhausted:
		_battle_status.text += " O filhote está exausto e precisa de cuidado."


func _try_player_attack() -> void:
	if _attack_cooldown > 0.0:
		return
	_attack_cooldown = float(selected_weapon["cooldown"])
	var distance: float = _player.global_position.distance_to(_golem.global_position)
	if distance > float(selected_weapon["range"]):
		_battle_status.text = "Aproxime-se do Guardião para atingir o alvo."
		return
	var damage: float = float(selected_weapon["damage"])
	var is_critical: bool = randf() < 0.08
	if is_critical:
		damage *= 1.5
	golem_hp = maxf(0.0, golem_hp - damage)
	_attacks_landed += 1
	_battle_status.text = "%s causa %d de dano%s." % [
		selected_weapon["name"],
		roundi(damage),
		" crítico" if is_critical else "",
	]
	match str(selected_weapon["name"]):
		"Martelo de Guerra":
			_stun_time = 0.45
		"Grimório Necrótico":
			player_hp = minf(100.0, player_hp + damage * 0.2)
		"Grimório Sagrado":
			if _attacks_landed % 5 == 0:
				player_hp = minf(100.0, player_hp + 16.0)
				_battle_status.text += " A bênção restaura vitalidade."
	if golem_hp <= 0.0:
		_finish_battle("victory")


func _finish_battle(result: String) -> void:
	if _battle_finished:
		return
	_battle_finished = true
	_battle_started = false
	var trait_name: String
	if result == "defeat":
		trait_name = "Medroso / Inseguro"
		_result_text.text = "O Guardião vence o confronto, mas não há Game Over. O filhote aprende a temer o mundo e recebe o traço Medroso / Inseguro.\n\nEfeito: -10% Ataque e +25% Velocidade de Voo/Fuga. A redenção é possível com cuidado e cinco vitórias menores."
	elif battle_time < 90.0 and player_hp > 60.0:
		trait_name = "Audacioso / Brigão"
		_result_text.text = "Vitória rápida! O filhote se inspira na coragem da dupla e recebe o traço Audacioso / Brigão.\n\nEfeito: +15% Ataque acima de 70% de HP. Pode evoluir para Lenda Destemida."
	else:
		trait_name = "Protetor / Leal"
		_result_text.text = "Vitória resistente! O filhote reconhece a dedicação e recebe o traço Protetor / Leal.\n\nEfeito: +20% Defesa a menos de 10 m do cavaleiro. Pode evoluir para Guardião Inabalável."
	_result_panel.visible = true
	_battle_result = result
	_trait_name = trait_name
	_battle_status.text = "Prova concluída: %s." % trait_name


func _continue_from_battle() -> void:
	battle_completed.emit(
		_battle_result,
		_trait_name,
		str(selected_weapon.get("name", ""))
	)


func _make_character(
	character_name: String,
	position: Vector3,
	color: Color,
	radius: float,
	height: float
) -> CharacterBody3D:
	var character: CharacterBody3D = CharacterBody3D.new()
	character.name = character_name
	character.position = position
	add_child(character)
	var collision: CollisionShape3D = CollisionShape3D.new()
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = radius
	capsule.height = height
	collision.shape = capsule
	collision.position.y = height * 0.5
	character.add_child(collision)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: CapsuleMesh = CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh_instance.mesh = mesh
	mesh_instance.position.y = height * 0.5
	mesh_instance.material_override = _material(color)
	character.add_child(mesh_instance)
	return character


func _make_bar(parent: Node, fill_color: Color, title: String) -> ProgressBar:
	var label: Label = _add_label(parent, title, 13, Color(0.89, 0.86, 0.78))
	label.add_theme_font_size_override("font_size", 13)
	var bar: ProgressBar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(310, 18)
	bar.max_value = 100.0 if title == "Cavaleiro" else 240.0
	bar.value = bar.max_value
	bar.show_percentage = false
	var background: StyleBoxFlat = StyleBoxFlat.new()
	background.bg_color = Color(0.12, 0.13, 0.13, 0.95)
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = fill_color
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	parent.add_child(bar)
	return bar


func _add_label(parent: Node, text: String, size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.075, 0.08, 0.94)
	style.border_color = Color(0.59, 0.44, 0.24)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	return style


func _material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.78
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


func _add_cylinder_visual(
	radius: float,
	height: float,
	position: Vector3,
	color: Color
) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius * 1.1
	mesh.height = height
	instance.mesh = mesh
	instance.position = position
	instance.material_override = _material(color)
	add_child(instance)
	return instance


func _add_box_collision(parent: Node3D, size: Vector3, position: Vector3) -> void:
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	collision.position = position
	parent.add_child(collision)


func _add_sphere(
	parent: Node3D,
	position: Vector3,
	radius: float,
	color: Color
) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	instance.mesh = mesh
	instance.position = position
	instance.material_override = _material(color)
	parent.add_child(instance)
	return instance
