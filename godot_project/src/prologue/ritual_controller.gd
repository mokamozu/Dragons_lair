extends Node3D

const MAGE_SCENE: PackedScene = preload("res://scenes/prologue/mage_sanctuary.tscn")
const COURSE_SCENE: PackedScene = preload("res://scenes/prologue/survival_course.tscn")
const ARENA_SCENE: PackedScene = preload("res://scenes/prologue/combat_arena.tscn")

const RACE_DATA: Array[Dictionary] = [
	{
		"species": "Serpe das Nuvens",
		"element": "Vento",
		"hp": 0.0,
		"stamina": 40.0,
		"elemental": 0.0,
		"carry": 0.0,
		"air_speed": 1.15,
		"critical": 0.0,
		"regen": 1.0,
		"agility": 1.0,
		"flight_cost": 0.8,
		"heat_resistance": false,
		"swim_speed": 1.0,
	},
	{
		"species": "Draco Vulcânico",
		"element": "Fogo",
		"hp": 0.0,
		"stamina": 0.0,
		"elemental": 15.0,
		"carry": 0.0,
		"air_speed": 1.0,
		"critical": 0.1,
		"regen": 1.0,
		"agility": 1.0,
		"flight_cost": 1.0,
		"heat_resistance": true,
		"swim_speed": 1.0,
	},
	{
		"species": "Wyvern da Montanha",
		"element": "Terra",
		"hp": 50.0,
		"stamina": 0.0,
		"elemental": 0.0,
		"carry": 40.0,
		"air_speed": 1.0,
		"critical": 0.0,
		"regen": 1.0,
		"agility": 1.0,
		"flight_cost": 1.0,
		"heat_resistance": false,
		"swim_speed": 1.0,
	},
	{
		"species": "Leviatã das Marés",
		"element": "Água / Gelo",
		"hp": 0.0,
		"stamina": 0.0,
		"elemental": 0.0,
		"carry": 0.0,
		"air_speed": 1.0,
		"critical": 0.0,
		"regen": 1.25,
		"agility": 1.2,
		"flight_cost": 1.0,
		"heat_resistance": false,
		"swim_speed": 1.5,
	},
]

var player_mbti: String = ""
var dragon_mbti: String = ""
var personality_scores: Dictionary = {}
var selected_route: int = -1
var timed_out: bool = false
var battle_result: String = ""
var behavioral_trait: String = ""
var selected_weapon: String = ""
var dragon_data: DragonData
var _active_phase: Node
var _summary_layer: CanvasLayer
var _player_name: LineEdit
var _dragon_name: LineEdit
var _save_status: Label
var _summary_text: Label
var _save_button: Button
var _start_button: Button


func _ready() -> void:
	_create_ritual_environment()
	_show_mage()


func _create_ritual_environment() -> void:
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky: Sky = Sky.new()
	var sky_material: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.12, 0.17, 0.27)
	sky_material.sky_horizon_color = Color(0.57, 0.43, 0.3)
	sky_material.ground_bottom_color = Color(0.08, 0.09, 0.1)
	sky_material.ground_horizon_color = Color(0.33, 0.3, 0.25)
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.62, 0.58, 0.53)
	environment.ambient_light_energy = 0.75
	world_environment.environment = environment
	add_child(world_environment)


func _show_mage() -> void:
	_active_phase = MAGE_SCENE.instantiate()
	add_child(_active_phase)
	_active_phase.personality_completed.connect(_on_personality_completed)


func _on_personality_completed(
	player_code: String,
	dragon_code: String,
	scores: Dictionary
) -> void:
	player_mbti = player_code
	dragon_mbti = dragon_code
	personality_scores = scores
	_remove_active_phase()
	_active_phase = COURSE_SCENE.instantiate()
	add_child(_active_phase)
	_active_phase.course_completed.connect(_on_course_completed)


func _on_course_completed(route_index: int, course_timed_out: bool) -> void:
	selected_route = clampi(route_index, 0, RACE_DATA.size() - 1)
	timed_out = course_timed_out
	_remove_active_phase()
	_active_phase = ARENA_SCENE.instantiate()
	_active_phase.set("race_data", RACE_DATA[selected_route])
	_active_phase.set("dragon_exhausted", timed_out)
	add_child(_active_phase)
	_active_phase.battle_completed.connect(_on_battle_completed)


func _on_battle_completed(
	result: String,
	trait_name: String,
	weapon_name: String
) -> void:
	battle_result = result
	behavioral_trait = trait_name
	selected_weapon = weapon_name
	_remove_active_phase()
	_build_binding_scroll()


func _remove_active_phase() -> void:
	if is_instance_valid(_active_phase):
		_active_phase.queue_free()
		_active_phase = null


func _build_binding_scroll() -> void:
	dragon_data = DragonData.new()
	dragon_data.player_mbti = player_mbti
	dragon_data.dragon_mbti = dragon_mbti
	dragon_data.personality_scores = personality_scores
	dragon_data.behavioral_trait = behavioral_trait
	dragon_data.weapon = selected_weapon
	dragon_data.battle_result = battle_result
	dragon_data.exhausted_first_day = timed_out
	_apply_race_data(dragon_data, RACE_DATA[selected_route])
	_apply_trait_data(dragon_data)
	_apply_identity_data(dragon_data)

	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-38, -28, 0)
	light.light_energy = 1.1
	add_child(light)
	var floor: MeshInstance3D = MeshInstance3D.new()
	var floor_mesh: PlaneMesh = PlaneMesh.new()
	floor_mesh.size = Vector2(40, 40)
	floor.mesh = floor_mesh
	var floor_material: StandardMaterial3D = StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.22, 0.2, 0.16)
	floor.material_override = floor_material
	floor.position.y = -0.5
	add_child(floor)
	var camera: Camera3D = Camera3D.new()
	camera.position = Vector3(0, 5, 14)
	camera.rotation_degrees = Vector3(-16, 0, 0)
	camera.current = true
	add_child(camera)

	var canvas: CanvasLayer = CanvasLayer.new()
	add_child(canvas)
	_summary_layer = canvas
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.025, 0.04, 0.72)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(shade)

	var panel: PanelContainer = PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -500
	panel.offset_right = 500
	panel.offset_top = -320
	panel.offset_bottom = 320
	panel.add_theme_stylebox_override("panel", _parchment_style())
	canvas.add_child(panel)
	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	panel.add_child(layout)
	_add_label(layout, "PERGAMINHO DE VÍNCULO", 28, Color(0.31, 0.19, 0.1))
	_add_label(layout, "A chama, o caminho e a batalha gravaram sua história. Escolha um nome e confirme para salvar a ficha.", 15, Color(0.34, 0.28, 0.2))
	_add_label(layout, "Nome do cavaleiro", 13, Color(0.38, 0.3, 0.2))
	_player_name = LineEdit.new()
	_player_name.text = "Cavaleiro"
	_player_name.placeholder_text = "Seu nome"
	_player_name.text_changed.connect(_on_name_changed)
	layout.add_child(_player_name)
	_add_label(layout, "Nome do dragão", 13, Color(0.38, 0.3, 0.2))
	_dragon_name = LineEdit.new()
	_dragon_name.text = _default_dragon_name()
	_dragon_name.placeholder_text = "Nome do dragão"
	_dragon_name.text_changed.connect(_on_name_changed)
	layout.add_child(_dragon_name)
	_summary_text = _add_label(layout, "", 15, Color(0.2, 0.19, 0.16))
	_summary_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summary_text.custom_minimum_size = Vector2(930, 190)
	_save_status = _add_label(layout, "Confirme para gravar seus dados em user://dragon_data.tres.", 13, Color(0.4, 0.32, 0.2))
	_save_button = Button.new()
	_save_button.text = "Gravar o Pergaminho"
	_save_button.custom_minimum_size = Vector2(0, 44)
	_save_button.pressed.connect(_save_binding_scroll)
	layout.add_child(_save_button)
	_start_button = Button.new()
	_start_button.text = "Começar a aventura"
	_start_button.custom_minimum_size = Vector2(0, 44)
	_start_button.disabled = true
	_start_button.pressed.connect(_start_adventure)
	layout.add_child(_start_button)
	_refresh_summary()


func _save_binding_scroll() -> void:
	var player_name: String = _player_name.text.strip_edges()
	var dragon_name: String = _dragon_name.text.strip_edges()
	if player_name.is_empty() or dragon_name.is_empty():
		_save_status.text = "Informe os nomes do cavaleiro e do dragão."
		return
	dragon_data.player_name = player_name
	dragon_data.dragon_name = dragon_name
	var save_error: Error = dragon_data.save_to_disk()
	if save_error != OK:
		_save_status.text = "Não foi possível salvar a ficha (erro %d). Verifique a pasta de dados do usuário." % save_error
		push_error("Falha ao salvar DragonData: %s" % error_string(save_error))
		return
	_save_status.text = "Pergaminho salvo com sucesso em %s." % DragonData.SAVE_PATH
	_save_button.disabled = true
	_player_name.editable = false
	_dragon_name.editable = false
	_start_button.disabled = false
	_refresh_summary()


func _on_name_changed(_value: String) -> void:
	_refresh_summary()


func _refresh_summary() -> void:
	if _summary_text == null:
		return
	var stats: DragonStats = dragon_data.create_dragon_stats()
	var exhaustion: String = "\nEstado inicial: Exausto (tempo esgotado na trilha)." if timed_out else ""
	_summary_text.text = (
		"IDENTIDADE  %s  ·  Dragão: %s\n"
		+ "MBTI  Cavaleiro: %s  ·  Dragão complementar: %s\n"
		+ "BIOLOGIA  %s — %s\n"
		+ "TEMPERAMENTO  %s\n"
		+ "ARMA INICIAL  %s\n"
		+ "ATRIBUTOS  HP %.0f  ·  Estamina %.0f  ·  Poder Elemental %.0f  ·  Força %.0f  ·  Carga %.0f\n"
		+ "Resultado do Guardião: %s.%s"
	) % [
		_player_name.text.strip_edges(),
		_dragon_name.text.strip_edges(),
		player_mbti,
		dragon_mbti,
		dragon_data.species,
		dragon_data.element,
		dragon_data.behavioral_trait,
		dragon_data.weapon,
		stats.max_hp,
		stats.max_stamina,
		stats.elemental_power,
		stats.physical_strength,
		stats.carry_capacity,
		"Vitória" if battle_result == "victory" else "Derrota sem Game Over",
		exhaustion,
	]


func _apply_race_data(data: DragonData, race: Dictionary) -> void:
	data.species = str(race["species"])
	data.element = str(race["element"])
	data.hp_bonus = float(race["hp"])
	data.stamina_bonus = float(race["stamina"])
	data.elemental_power_bonus = float(race["elemental"])
	data.carry_bonus = float(race["carry"])
	data.air_speed_multiplier = float(race["air_speed"])
	data.critical_bonus = float(race["critical"])
	data.stamina_regen_multiplier = float(race["regen"])
	data.turn_agility_multiplier = float(race["agility"])
	data.flight_stamina_cost_multiplier = float(race["flight_cost"])
	data.heat_resistance = bool(race["heat_resistance"])
	data.swim_speed_multiplier = float(race["swim_speed"])


func _apply_trait_data(data: DragonData) -> void:
	match data.behavioral_trait:
		"Audacioso / Brigão":
			data.trait_attack_multiplier = 1.15
			data.trait_attack_hp_threshold = 0.7
		"Protetor / Leal":
			data.trait_defense_bonus = 0.2
			data.trait_defense_range = 10.0
		"Medroso / Inseguro":
			data.trait_attack_multiplier = 0.9
			data.trait_flight_speed_multiplier = 1.25
			data.trait_redemption_progress = 0


func _apply_identity_data(data: DragonData) -> void:
	if data.dragon_mbti.ends_with("-A"):
		data.resists_fear = true
	else:
		data.bond_affection_multiplier = 1.15


func _default_dragon_name() -> String:
	var names: Dictionary = {
		"Vento": "Nimbo",
		"Fogo": "Brasa",
		"Terra": "Pedra",
		"Água / Gelo": "Maré",
	}
	return str(names.get(str(RACE_DATA[selected_route]["element"]), "Brasa"))


func _start_adventure() -> void:
	var error: Error = get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	if error != OK:
		_save_status.text = "A ficha foi salva, mas a cena da fazenda não pôde abrir (%d)." % error
		push_error("Falha ao iniciar a fazenda: %s" % error_string(error))


func _add_label(parent: Node, text: String, size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


func _parchment_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.85, 0.78, 0.63, 0.98)
	style.border_color = Color(0.48, 0.31, 0.15)
	style.set_border_width_all(4)
	style.set_corner_radius_all(14)
	style.content_margin_left = 25.0
	style.content_margin_right = 25.0
	style.content_margin_top = 18.0
	style.content_margin_bottom = 18.0
	return style
