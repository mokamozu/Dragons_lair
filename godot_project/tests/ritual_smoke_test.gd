extends SceneTree

const TEST_SCRIPT: Script = preload("res://src/systems/mage_personality_test.gd")
const DATA_SCRIPT: Script = preload("res://src/resources/dragon_data.gd")
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
	data.species = "Serpe das Nuvens"
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
	_check(loaded.species == "Serpe das Nuvens", "A raça do dragão deve persistir.")
	var absolute_path: String = ProjectSettings.globalize_path(save_path)
	_check(DirAccess.remove_absolute(absolute_path) == OK, "O arquivo de teste deve ser removido.")


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
	_check(course.has_method("_finish_course"), "A cena da trilha deve carregar seu controlador.")
	var player: CharacterBody3D = course.get("_player")
	player.global_position.x = 9.0
	player.global_position.z = -29.0
	course.call("_process", 0.01)
	_check(int(course.get("selected_route")) == 3, "A rota concluída deve corresponder ao setor da chegada.")
	_check(not bool(course.get("timed_out")), "Uma chegada antes do limite não pode marcar Exausto.")
	course.queue_free()
	await process_frame

	var expired_course: Node3D = COURSE_SCENE.instantiate()
	root.add_child(expired_course)
	await process_frame
	var expired_player: CharacterBody3D = expired_course.get("_player")
	expired_player.global_position.x = -9.0
	expired_course.set("time_remaining", 0.01)
	expired_course.call("_process", 0.02)
	_check(int(expired_course.get("selected_route")) == 0, "O timeout deve selecionar o setor mais próximo.")
	_check(bool(expired_course.get("timed_out")), "Esgotar o cronômetro deve marcar Exausto.")
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
	_check(data.species == "Wyvern da Montanha", "A rota terrestre deve definir a raça.")
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
	farm.queue_free()
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
