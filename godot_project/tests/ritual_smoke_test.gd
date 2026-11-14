extends SceneTree

const TEST_SCRIPT: Script = preload("res://src/systems/mage_personality_test.gd")
const DATA_SCRIPT: Script = preload("res://src/resources/dragon_data.gd")
const FLIGHT_PHYSICS_SCRIPT: Script = preload("res://src/dragon/flight/dragon_flight_physics.gd")
const FLIGHT_CAMERA_SCRIPT: Script = preload("res://src/camera/flight_camera_effects.gd")
const COURSE_SCENE: PackedScene = preload("res://scenes/prologue/survival_course.tscn")
const ARENA_SCENE: PackedScene = preload("res://scenes/prologue/combat_arena.tscn")
const RITUAL_SCENE: PackedScene = preload("res://scenes/prologue/ritual.tscn")
const FARM_SCENE: PackedScene = preload("res://scenes/main/main.tscn")

var _battle_signal: Array[String] = []
var _personality_signal: Array[String] = []
var _failed: bool = false


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_test_personality_bank_and_scoring()
	_test_species_catalog()
	_test_flight_physics()
	_test_flight_camera_effects()
	await _test_mage_interface_flow()
	_test_race_bonuses_and_persistence()
	await _test_course_route_and_timeout()
	await _test_combat_traits_and_weapon()
	await _test_ritual_flow_and_generated_record()
	await _test_farm_scene_starts()
	if _failed:
		push_error("RITUAL SMOKE TEST FAILED")
		quit(1)
		return
	print("RITUAL SMOKE TEST PASSED")
	quit(0)


func _test_personality_bank_and_scoring() -> void:
	var test: MagePersonalityTest = TEST_SCRIPT.new()
	var standard_questions: Array[Dictionary] = test.get_questions(6)
	var full_questions: Array[Dictionary] = test.get_questions(12)
	_check(standard_questions.size() == 30, "O ritual padrão deve ter 30 perguntas.")
	_check(full_questions.size() == 60, "O ritual completo deve ter 60 perguntas.")

	var axes: Dictionary = {}
	var poles_by_axis: Dictionary = {}
	for question: Dictionary in full_questions:
		axes[question["axis"]] = int(axes.get(question["axis"], 0)) + 1
		if not poles_by_axis.has(question["axis"]):
			poles_by_axis[question["axis"]] = {}
		var axis_poles: Dictionary = poles_by_axis[question["axis"]]
		axis_poles[question["agree_pole"]] = int(axis_poles.get(question["agree_pole"], 0)) + 1
	for axis_count: Variant in axes.values():
		_check(axis_count == 12, "Cada eixo deve conter 12 perguntas.")
	for pole_counts: Dictionary in poles_by_axis.values():
		_check(_all_values_equal(pole_counts.values(), 6), "As perguntas completas devem equilibrar os dois polos.")
	var standard_poles: Dictionary = {}
	for question: Dictionary in standard_questions:
		if not standard_poles.has(question["axis"]):
			standard_poles[question["axis"]] = {}
		var axis_poles: Dictionary = standard_poles[question["axis"]]
		axis_poles[question["agree_pole"]] = int(axis_poles.get(question["agree_pole"], 0)) + 1
	for pole_counts: Dictionary in standard_poles.values():
		_check(_all_values_equal(pole_counts.values(), 3), "O ritual padrão deve equilibrar os dois polos por eixo.")

	test.reset()
	for question: Dictionary in full_questions:
		var preferred_pole: String = str(MagePersonalityTest.AXIS_POLES[question["axis"]][0])
		test.record_answer(question, 3 if question["agree_pole"] == preferred_pole else -3)
	var player_code: String = test.get_player_mbti()
	_check(player_code == "ENTJA", "As respostas devem calcular o perfil ENTJA.")
	_check(
		test.get_complementary_mbti(player_code) == "INFPT",
		"O MBTI do dragão deve inverter os quatro eixos definidos e a identidade."
	)


func _test_race_bonuses_and_persistence() -> void:
	var data: DragonData = DATA_SCRIPT.new()
	data.player_name = "Teste"
	data.dragon_name = "Nimbo"
	data.dragon_mbti = "ENFP-T"
	var species_profile: DragonSpeciesData = data.resolve_species_profile()
	_check(species_profile != null, "O MBTI deve resolver a espécie antes de salvar.")
	data.element = "Vento"
	data.stamina_bonus = 40.0
	data.air_speed_multiplier = 1.15
	data.flight_stamina_cost_multiplier = 0.8
	var stats: DragonStats = data.create_dragon_stats()
	_check(stats.max_stamina == 140.0, "A raça de vento deve somar 40 de estamina.")
	_check(is_equal_approx(stats.flight_speed_multiplier, 1.15), "A raça de vento deve aumentar velocidade aérea em 15%.")
	_check(is_equal_approx(stats.flight_stamina_cost_multiplier, 0.8), "A raça de vento deve reduzir o custo de voo.")
	data.critical_bonus = 0.1
	data.heat_resistance = true
	stats = data.create_dragon_stats()
	_check(is_equal_approx(stats.critical_damage_multiplier, 1.65), "A raça de fogo deve aumentar dano crítico em 10%.")
	_check(stats.heat_resistance, "A raça de fogo deve resistir ao calor.")

	var save_path: String = "user://ritual_smoke_test.tres"
	var save_error: Error = ResourceSaver.save(data, save_path)
	_check(save_error == OK, "DragonData deve ser salvo como Resource.")
	if save_error != OK:
		return
	var loaded: Resource = ResourceLoader.load(save_path, "DragonData")
	_check(loaded is DragonData, "DragonData deve ser carregado do arquivo salvo.")
	if not loaded is DragonData:
		return
	_check(loaded.dragon_name == "Nimbo", "O nome do dragão deve persistir.")
	_check(loaded.species == "Dragonete Etéreo", "A espécie deve corresponder ao MBTI do dragão.")
	_check(loaded.species_id == "enfp", "O identificador estável da espécie deve persistir.")
	_check(
		loaded.species_profile.tail_profile == "Fire",
		"A morfologia da espécie deve persistir junto com a ficha."
	)
	var absolute_path: String = ProjectSettings.globalize_path(save_path)
	_check(DirAccess.remove_absolute(absolute_path) == OK, "O arquivo de teste deve ser removido.")


func _test_species_catalog() -> void:
	var species_ids: Array[String] = DragonSpeciesCatalog.get_species_ids()
	_check(species_ids.size() == 16, "O catálogo deve conter exatamente 16 espécies MBTI.")
	var found_profiles: Dictionary = {}
	for mbti_code: String in DragonSpeciesCatalog.SPECIES:
		var profile: DragonSpeciesData = DragonSpeciesCatalog.get_profile(mbti_code)
		_check(profile != null, "Cada MBTI deve resolver para uma ficha de espécie.")
		if profile == null:
			continue
		found_profiles[profile.species_id] = true
		_check(profile.mbti_code == mbti_code, "A ficha deve preservar o código MBTI-base.")
		_check(not profile.species_name.is_empty(), "Cada espécie deve ter nome.")
		_check(not profile.anatomy.is_empty(), "Cada espécie deve descrever sua anatomia.")
		_check(not profile.head_profile.is_empty(), "Cada espécie deve definir um perfil de cabeça.")
		_check(not profile.wing_profile.is_empty(), "Cada espécie deve definir um perfil de asas.")
		_check(not profile.tail_profile.is_empty(), "Cada espécie deve definir um perfil de cauda.")
	var turbulent_profile: DragonSpeciesData = DragonSpeciesCatalog.get_profile("INFP-T")
	_check(
		turbulent_profile.species_id == "infp",
		"O sufixo de identidade não deve criar uma espécie separada."
	)
	_check(
		found_profiles.size() == 16,
		"Cada código MBTI deve mapear para uma espécie-base distinta."
	)


func _test_flight_physics() -> void:
	var flight: DragonFlightPhysics = FLIGHT_PHYSICS_SCRIPT.new()
	var stats: DragonStats = DragonStats.new()
	var velocity: Vector3 = Vector3(0.0, 0.0, -14.0)
	var dive_result: Dictionary = {}
	for _step: int in range(20):
		dive_result = flight.update_velocity(
			velocity, Vector3.FORWARD, -0.5, 1.0, false, false, false,
			false, 0.1, stats, "Fogo", 14.0, 100.0
		)
		velocity = dive_result["velocity"]
	_check(velocity.length() > 14.0, "O mergulho deve acumular velocidade além do cruzeiro.")
	_check(velocity.length() <= 38.0, "A velocidade terminal deve limitar o mergulho.")
	_check(float(dive_result["kinetic_charge"]) > 0.0, "O mergulho deve acumular carga cinética.")

	var charge_before_climb: float = float(dive_result["kinetic_charge"])
	var climb_result: Dictionary = {}
	for _step: int in range(8):
		climb_result = flight.update_velocity(
			velocity, Vector3.FORWARD, 0.52, 0.0, false, false, false,
			false, 0.1, stats, "Fogo", 14.0, 100.0
		)
		velocity = climb_result["velocity"]
	_check(
		float(climb_result["kinetic_charge"]) < charge_before_climb,
		"Subir deve converter a carga cinética armazenada."
	)
	_check(
		velocity.y > float(dive_result["velocity"].y),
		"Converter velocidade deve aumentar a componente vertical de subida."
	)

	flight.reset()
	velocity = Vector3(0.0, 2.5, -14.0)
	for _step: int in range(60):
		var level_result: Dictionary = flight.update_velocity(
			velocity, Vector3.FORWARD, 0.0, 0.0, false, false, false,
			false, 1.0 / 60.0, stats, "Fogo", 14.0, 100.0
		)
		velocity = level_result["velocity"]
	_check(
		absf(velocity.y) < 0.1,
		"Voo nivelado deve dissipar a velocidade vertical residual."
	)

	var climb_control_result: Dictionary = flight.update_velocity(
		Vector3(0.0, 0.0, -14.0), Vector3.FORWARD, 0.35, 0.0, false, false, false,
		false, 1.0 / 60.0, stats, "Fogo", 14.0, 100.0
	)
	var dive_control_result: Dictionary = flight.update_velocity(
		Vector3(0.0, 0.0, -14.0), Vector3.FORWARD, -0.35, 0.0, false, false, false,
		false, 1.0 / 60.0, stats, "Fogo", 14.0, 100.0
	)
	_check(
		float(climb_control_result["velocity"].y) > 0.0
			and float(dive_control_result["velocity"].y) < 0.0,
		"A inclinação de voo deve comandar a subida e o mergulho de forma previsível."
	)

	flight.reset()
	var stall_result: Dictionary = flight.update_velocity(
		Vector3(0.0, 0.0, -2.0), Vector3.FORWARD, 0.52, 0.0, false, false, false,
		false, 0.25, stats, "Fogo", 14.0, 100.0
	)
	_check(bool(stall_result["stalled"]), "Tentar subir abaixo de 5 m/s deve causar estol.")
	_check(float(stall_result["velocity"].y) < 0.0, "O estol deve fazer o dragão perder altitude.")

	flight.reset()
	var flap_result: Dictionary = flight.update_velocity(
		Vector3(0.0, 0.0, -14.0), Vector3.FORWARD, 0.0, 0.0, true, false, false,
		false, 0.016, stats, "Fogo", 14.0, 100.0
	)
	_check(bool(flap_result["flapped"]), "O impulso de batida deve ser aplicado com estamina suficiente.")
	_check(float(flap_result["stamina_cost"]) >= 18.0, "O flap deve consumir estamina com o multiplicador.")
	_check(float(flap_result["velocity"].y) >= 4.0, "O flap deve impulsionar o dragão para cima.")

	stats.flight_speed_multiplier = 1.15
	var wind_result: Dictionary = flight.update_velocity(
		Vector3(0.0, 0.0, -14.0), Vector3.FORWARD, 0.0, 0.0, false, false, false,
		false, 0.016, stats, "Vento", 14.0, 100.0
	)
	_check(
		is_equal_approx(float(wind_result["terminal_speed"]), 42.0),
		"A Serpe do Vento deve alcançar 42 m/s com o bônus de velocidade."
	)

	stats.flight_stamina_cost_multiplier = 0.5
	var efficient_flap_result: Dictionary = flight.update_velocity(
		Vector3(0.0, 0.0, -14.0), Vector3.FORWARD, 0.0, 0.0, true, false, false,
		false, 0.016, stats, "Vento", 14.0, 100.0
	)
	_check(
		is_equal_approx(float(efficient_flap_result["stamina_cost"]), 9.0),
		"O custo de voo deve respeitar o multiplicador de estamina da espécie."
	)
	var rejected_flap_result: Dictionary = flight.update_velocity(
		Vector3(0.0, 0.0, -14.0), Vector3.FORWARD, 0.0, 0.0, true, false, false,
		false, 0.016, stats, "Vento", 14.0, 8.0
	)
	_check(
		not bool(rejected_flap_result["flapped"]),
		"O flap deve ser recusado se a estamina restante não cobre o custo modificado."
	)

	stats.flight_stamina_cost_multiplier = 1.0
	stats.flight_speed_multiplier = 1.0
	var water_effect_result: Dictionary = flight.update_velocity(
		Vector3(0.0, 0.0, -18.0), Vector3.FORWARD, 0.0, 0.0, false, false, false,
		true, 0.1, stats, "Água/Gelo", 14.0, 100.0
	)
	var water_air_result: Dictionary = flight.update_velocity(
		Vector3(0.0, 0.0, -18.0), Vector3.FORWARD, 0.0, 0.0, false, false, false,
		false, 0.1, stats, "Água/Gelo", 14.0, 100.0
	)
	_check(
		float(water_effect_result["velocity"].y) > float(water_air_result["velocity"].y),
		"O Leviatã deve receber sustentação adicional próximo ao solo."
	)

	flight.kinetic_charge = 20.0
	var brake_result: Dictionary = flight.update_velocity(
		Vector3(0.0, 0.0, -30.0), Vector3.FORWARD, 0.0, 0.0, false, false, true,
		false, 0.25, stats, "Fogo", 14.0, 100.0
	)
	_check(
		float(brake_result["speed"]) < 30.0,
		"O freio aerodinâmico deve reduzir rapidamente a velocidade."
	)
	_check(
		float(brake_result["kinetic_charge"]) < 20.0,
		"O freio aerodinâmico deve dissipar a carga cinética."
	)
	var turn_brake_result: Dictionary = flight.update_velocity(
		Vector3(0.0, 0.0, -30.0), Vector3.RIGHT, 0.0, 0.0, false, false, true,
		false, 0.25, stats, "Fogo", 14.0, 100.0
	)
	_check(
		float(turn_brake_result["velocity"].x) > 0.0,
		"A curva aérea deve direcionar o momentum para o lado escolhido."
	)


func _test_flight_camera_effects() -> void:
	var cruise: Dictionary = FlightCameraEffects.get_targets(14.0 / 38.0, false)
	var terminal: Dictionary = FlightCameraEffects.get_targets(1.0, false)
	var braking: Dictionary = FlightCameraEffects.get_targets(1.0, true)
	_check(is_equal_approx(float(cruise["fov"]), 70.0 + 16.0 * 14.0 / 38.0), "O FOV deve responder suavemente à velocidade.")
	_check(is_equal_approx(float(terminal["fov"]), 86.0), "O FOV máximo de voo deve permanecer confortável.")
	_check(is_equal_approx(float(terminal["distance"]), 6.25), "A câmera deve afastar-se moderadamente em velocidade terminal.")
	_check(is_equal_approx(float(braking["distance"]), 4.5), "O freio aéreo deve aproximar a câmera para a manobra.")


func _test_mage_interface_flow() -> void:
	var mage_scene: PackedScene = load("res://scenes/prologue/mage_sanctuary.tscn")
	var mage: Node3D = mage_scene.instantiate()
	root.add_child(mage)
	await process_frame
	mage.personality_completed.connect(_on_personality_completed)
	mage.call("_start_test", 6)
	var questions: Array = mage.get("questions")
	_check(questions.size() == 30, "O Oráculo deve iniciar o ritual padrão com 30 perguntas.")
	for question: Dictionary in questions:
		var first_pole: String = str(MagePersonalityTest.AXIS_POLES[question["axis"]][0])
		mage.call("_answer", 3 if question["agree_pole"] == first_pole else -3)
	_check(mage.get("player_mbti") == "ENTJ-A", "A interface deve formatar o MBTI do jogador.")
	_check(mage.get("dragon_mbti") == "INFP-T", "A interface deve mostrar a afinidade complementar.")
	mage.call("_finish_test")
	_check(
		_personality_signal == ["ENTJ-A", "INFP-T"],
		"A fase deve transmitir MBTI e afinidades ao controlador do prólogo."
	)
	mage.queue_free()
	await process_frame


func _test_course_route_and_timeout() -> void:
	var course: Node3D = COURSE_SCENE.instantiate()
	root.add_child(course)
	await process_frame
	course.set("dragon_species", DragonSpeciesCatalog.get_profile("INFJ-T"))
	_check(course.has_method("_finish_course"), "A cena da trilha deve carregar seu controlador.")
	var player: CharacterBody3D = course.get("_player")
	player.global_position.x = 9.0
	player.global_position.z = -29.0
	course.call("_process", 0.01)
	_check(int(course.get("selected_route")) == 3, "A rota concluída deve corresponder ao setor da chegada.")
	_check(not bool(course.get("timed_out")), "Uma chegada antes do limite não pode marcar Exausto.")
	_check(
		str(course.get("_result_text").text).contains("Coatyl Místico (INFJ)"),
		"A espécie exibida na eclosão deve vir do MBTI, não da rota."
	)
	_check(
		str(course.get("_result_text").text).contains("Água / Gelo"),
		"O elemento exibido na eclosão deve vir da rota escolhida."
	)
	course.queue_free()
	await process_frame

	var expired_course: Node3D = COURSE_SCENE.instantiate()
	root.add_child(expired_course)
	await process_frame
	expired_course.set("dragon_species", DragonSpeciesCatalog.get_profile("INFJ-A"))
	var expired_player: CharacterBody3D = expired_course.get("_player")
	expired_player.global_position.x = -9.0
	expired_course.set("time_remaining", 0.01)
	expired_course.call("_process", 0.02)
	_check(int(expired_course.get("selected_route")) == 0, "O timeout deve selecionar o setor mais próximo.")
	_check(bool(expired_course.get("timed_out")), "Esgotar o cronômetro deve marcar Exausto.")
	_check(
		str(expired_course.get("_result_text").text).contains("Coatyl Místico (INFJ)"),
		"O timeout deve manter a espécie definida pelo MBTI."
	)
	expired_course.queue_free()
	await process_frame


func _test_combat_traits_and_weapon() -> void:
	var arena: Node3D = ARENA_SCENE.instantiate()
	root.add_child(arena)
	await process_frame
	_check(arena.has_signal("battle_completed"), "A arena deve carregar seu controlador de combate.")
	if not arena.has_signal("battle_completed"):
		return
	var selection_layout: VBoxContainer = arena.get("_weapon_panel").get_child(0)
	var first_weapon_row: HBoxContainer = selection_layout.get_child(2)
	var second_weapon_row: HBoxContainer = selection_layout.get_child(3)
	_check(
		first_weapon_row.get_child_count() + second_weapon_row.get_child_count() == 8,
		"A arena deve apresentar as oito armas para escolha."
	)
	arena.battle_completed.connect(_on_battle_completed)
	arena.call("_select_weapon", 7)
	_check(
		arena.get("selected_weapon")["name"] == "Grimório Sagrado",
		"A arma escolhida deve ser mantida na batalha."
	)
	arena.set("battle_time", 20.0)
	arena.set("player_hp", 85.0)
	arena.call("_finish_battle", "victory")
	_check(arena.get("_trait_name") == "Audacioso / Brigão", "Vitória rápida deve gerar o traço Audacioso.")
	arena.call("_continue_from_battle")
	_check(
		_battle_signal == ["victory", "Audacioso / Brigão", "Grimório Sagrado"],
		"O resultado deve retornar arma e traço ao controlador."
	)
	arena.queue_free()
	await process_frame

	var resilient_arena: Node3D = ARENA_SCENE.instantiate()
	root.add_child(resilient_arena)
	await process_frame
	resilient_arena.call("_select_weapon", 2)
	resilient_arena.set("battle_time", 100.0)
	resilient_arena.set("player_hp", 80.0)
	resilient_arena.call("_finish_battle", "victory")
	_check(resilient_arena.get("_trait_name") == "Protetor / Leal", "Vitória longa deve gerar o traço Protetor.")
	resilient_arena.queue_free()
	await process_frame

	var defeat_arena: Node3D = ARENA_SCENE.instantiate()
	root.add_child(defeat_arena)
	await process_frame
	defeat_arena.call("_select_weapon", 0)
	defeat_arena.call("_finish_battle", "defeat")
	_check(defeat_arena.get("_trait_name") == "Medroso / Inseguro", "Derrota deve gerar o traço Medroso sem Game Over.")
	defeat_arena.queue_free()
	await process_frame


func _test_ritual_flow_and_generated_record() -> void:
	var ritual: Node3D = RITUAL_SCENE.instantiate()
	root.add_child(ritual)
	await process_frame
	_check(ritual.has_method("_on_personality_completed"), "A cena principal do prólogo deve carregar o controlador.")
	if not ritual.has_method("_on_personality_completed"):
		return
	ritual.call("_on_personality_completed", "ENFP-A", "INFP-T", {"mind": {"E": 10, "I": -10}})
	ritual.call("_on_course_completed", 2, true)
	ritual.call("_on_battle_completed", "victory", "Protetor / Leal", "Machado de Batalha")
	var data: DragonData = ritual.get("dragon_data")
	_check(data.player_mbti == "ENFP-A", "O perfil do jogador deve seguir para o pergaminho.")
	_check(data.dragon_mbti == "INFP-T", "O perfil complementar deve seguir para o pergaminho.")
	_check(data.species == "Dragão Feérico", "O MBTI complementar deve definir a espécie.")
	_check(data.species_id == "infp", "A espécie deve manter um ID baseado no MBTI.")
	_check(
		data.species_profile.mbti_group == "Diplomatas",
		"A ficha deve incluir os dados morfológicos do arquétipo MBTI."
	)
	_check(data.element == "Terra", "A rota terrestre deve definir o elemento.")
	_check(data.exhausted_first_day, "O timeout da trilha deve marcar o primeiro dia como Exausto.")
	_check(data.weapon == "Machado de Batalha", "A arma escolhida deve chegar ao pergaminho.")
	_check(data.create_dragon_stats().max_hp == 170.0, "A ficha final deve incluir os bônus da rota.")
	_check(ritual.get("_save_button") != null, "O fluxo deve apresentar a confirmação do pergaminho.")
	_check(data.create_dragon_stats().trait_defense_bonus == 0.2, "O traço Protetor deve registrar seu bônus defensivo.")
	_check(data.create_dragon_stats().trait_defense_range == 10.0, "O traço Protetor deve registrar seu raio de proteção.")
	_check(is_equal_approx(data.bond_affection_multiplier, 1.15), "A identidade turbulenta deve aumentar o ganho de vínculo.")
	ritual.queue_free()
	await process_frame


func _test_farm_scene_starts() -> void:
	var farm: Node3D = FARM_SCENE.instantiate()
	root.add_child(farm)
	await process_frame
	_check(farm.has_node("Dragon") and farm.has_node("Player"), "A cena da fazenda deve criar o jogador e o dragão.")
	if not farm.has_node("Dragon") or not farm.has_node("Player"):
		return
	var dragon: Node = farm.get_node("Dragon")
	var player: Node = farm.get_node("Player")
	_check(dragon.get("stats") is DragonStats, "A cena da fazenda deve inicializar os atributos do dragão.")
	_check(player.get("companion") == dragon, "O jogador deve receber o dragão carregado como companheiro.")
	var camera_pivot: Node3D = player.get_node("CameraPivot")
	var spring_arm: SpringArm3D = camera_pivot.get_node("SpringArm3D")
	var camera: Camera3D = spring_arm.get_node("Camera3D")
	var visual: Node3D = player.get_node("Visual")
	_check(is_zero_approx(spring_arm.spring_length), "A câmera a pé deve estar na posição de primeira pessoa.")
	_check(not visual.visible, "O modelo placeholder do jogador não deve obstruir a câmera em primeira pessoa.")
	_check(is_equal_approx(camera.fov, 82.0), "A câmera a pé deve usar o campo de visão de primeira pessoa.")
	var forward: Vector3 = player.call("_camera_relative_direction", Vector2(0.0, -1.0))
	_check(forward.is_equal_approx(Vector3.FORWARD), "W deve mover o jogador na direção para a qual a câmera olha.")
	camera_pivot.rotation.y = PI / 2.0
	forward = player.call("_camera_relative_direction", Vector2(0.0, -1.0))
	_check(
		forward.is_equal_approx(Vector3.LEFT),
		"A direção de movimento deve acompanhar a rotação do olhar em primeira pessoa."
	)
	camera_pivot.rotation.y = 0.0

	player.call("attach_to_dragon", dragon, dragon.get_node("Seat"))
	_check(bool(player.get("is_mounted")), "O jogador deve montar no dragão.")
	_check(visual.visible, "O modelo do cavaleiro deve aparecer durante a montaria.")
	_check(
		is_equal_approx(spring_arm.spring_length, 5.0),
		"A montaria deve alternar para a câmera de acompanhamento."
	)
	_check(
		absf(wrapf(camera.rotation.y + spring_arm.rotation.y, -PI, PI)) < 0.001,
		"A câmera montada deve olhar para a frente mesmo com o braço atrás do dragão."
	)
	var camera_yaw_before_turn: float = atan2(
		-camera_pivot.global_basis.z.x,
		-camera_pivot.global_basis.z.z
	)
	dragon.set("rider", player)
	dragon.call("_face_flight_direction", Vector3.RIGHT, 0.1, 1.0)
	var camera_yaw_after_turn: float = atan2(
		-camera_pivot.global_basis.z.x,
		-camera_pivot.global_basis.z.z
	)
	_check(
		absf(wrapf(camera_yaw_after_turn - camera_yaw_before_turn, -PI, PI)) < 0.001,
		"A câmera deve manter o rumo de mira enquanto o dragão acompanha a curva."
	)
	camera_pivot.call("set_flight_feedback", 42.0, 42.0, true, false)
	camera_pivot.call("_process", 1.0)
	_check(is_equal_approx(camera.fov, 86.0), "A câmera montada deve expandir moderadamente o FOV em velocidade terminal.")
	_check(is_equal_approx(spring_arm.spring_length, 6.25), "O SpringArm deve afastar-se moderadamente em velocidade terminal.")
	camera_pivot.call("set_flight_feedback", 42.0, 42.0, true, true)
	camera_pivot.call("_process", 1.0)
	_check(is_equal_approx(camera.fov, 74.0), "O freio deve suavizar o FOV para a manobra.")
	_check(is_equal_approx(spring_arm.spring_length, 4.5), "O freio deve aproximar o SpringArm.")
	camera_pivot.call("set_flight_feedback", 0.0, 42.0, false, false)
	camera_pivot.call("_process", 1.0)
	dragon.call(
		"set_rider_input",
		Vector3.FORWARD,
		true,
		false,
		false,
		0.0,
		false,
		false,
		0.0
	)
	dragon.call("_update_mounted_movement", 0.1)
	_check(
		int(dragon.get("state")) == DragonController.CompanionState.MOUNTED_FLYING,
		"Pressionar Espaço no chão deve iniciar a decolagem."
	)
	_check(
		float(dragon.get("_flight_speed")) >= 14.0,
		"A decolagem deve iniciar na velocidade de cruzeiro."
	)
	_check(
		float(dragon.get("kinetic_charge")) >= 0.0,
		"O controlador montado deve expor a carga cinética do voo."
	)
	player.call("detach_from_dragon", Vector3(1.0, 0.05, 1.0))
	_check(not bool(player.get("is_mounted")), "O jogador deve voltar ao estado a pé ao desmontar.")
	_check(not visual.visible, "O modelo do jogador deve voltar a ser ocultado em primeira pessoa.")
	_check(is_zero_approx(spring_arm.spring_length), "Desmontar deve restaurar a câmera de primeira pessoa.")
	farm.queue_free()
	await process_frame
	await process_frame


func _on_battle_completed(result: String, trait_name: String, weapon: String) -> void:
	_battle_signal = [result, trait_name, weapon]


func _on_personality_completed(player_code: String, dragon_code: String, _scores: Dictionary) -> void:
	_personality_signal = [player_code, dragon_code]


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)


func _all_values_equal(values: Array, expected: int) -> bool:
	for value: Variant in values:
		if int(value) != expected:
			return false
	return true
