extends Node3D

signal personality_completed(player_mbti: String, dragon_mbti: String, scores: Dictionary)

const TEST_SCRIPT: Script = preload("res://src/systems/mage_personality_test.gd")

var personality_test: MagePersonalityTest
var questions: Array[Dictionary] = []
var question_index: int = 0
var player_mbti: String = ""
var dragon_mbti: String = ""

var _ui: CanvasLayer
var _content: VBoxContainer
var _progress: Label
var _question_text: Label
var _status: Label
var _answer_buttons: Array[Button] = []
var _mode_buttons: Array[Button] = []


func _ready() -> void:
	personality_test = TEST_SCRIPT.new()
	_create_sanctuary()
	_build_ui()


func _create_sanctuary() -> void:
	var camera: Camera3D = Camera3D.new()
	camera.position = Vector3(0, 5, 15)
	camera.rotation_degrees = Vector3(-15, 0, 0)
	camera.current = true
	add_child(camera)

	var moonlight: DirectionalLight3D = DirectionalLight3D.new()
	moonlight.rotation_degrees = Vector3(-42, -25, 0)
	moonlight.light_color = Color(0.62, 0.69, 1.0)
	moonlight.light_energy = 0.8
	add_child(moonlight)

	_add_box(self, Vector3(38, 0.6, 38), Vector3(0, -0.5, 0), Color(0.12, 0.12, 0.16))
	_add_box(self, Vector3(8, 0.9, 3), Vector3(0, 0.35, -1), Color(0.31, 0.26, 0.22))
	_add_box(self, Vector3(2.2, 2.8, 1.6), Vector3(0, 1.9, -5), Color(0.39, 0.32, 0.25))
	_add_box(self, Vector3(2.5, 0.25, 2.1), Vector3(0, 3.35, -5), Color(0.72, 0.52, 0.24))
	_add_sphere(self, Vector3(0, 4.25, -5), 0.48, Color(0.3, 0.78, 1.0), true)
	_add_box(self, Vector3(0.85, 1.6, 0.8), Vector3(-5, 0.8, -4), Color(0.28, 0.2, 0.36))
	_add_sphere(self, Vector3(-5, 1.9, -4), 0.42, Color(0.74, 0.64, 0.53))
	for index: int in range(5):
		var angle: float = TAU * float(index) / 5.0
		var position: Vector3 = Vector3(cos(angle) * 7.5, 0.85, sin(angle) * 5.5 - 1.0)
		_add_sphere(self, position, 0.25, Color(0.38, 0.78, 1.0), true)


func _build_ui() -> void:
	_ui = CanvasLayer.new()
	add_child(_ui)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.025, 0.025, 0.035, 0.76)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(shade)

	var panel: PanelContainer = PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -500
	panel.offset_right = 500
	panel.offset_top = -310
	panel.offset_bottom = 310
	panel.add_theme_stylebox_override("panel", _parchment_style())
	_ui.add_child(panel)
	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 13)
	panel.add_child(_content)

	_add_label(_content, "O ORÁCULO DO MAGO", 30, Color(0.29, 0.18, 0.1))
	_add_label(
		_content,
		"Responda com sinceridade. O orbe procura compreender seus cinco eixos; o ovo despertará com uma personalidade complementar.",
		16,
		Color(0.29, 0.25, 0.2)
	)
	_status = _add_label(_content, "Escolha a profundidade do ritual.", 15, Color(0.44, 0.31, 0.15))
	_progress = _add_label(_content, "", 14, Color(0.39, 0.31, 0.22))
	_question_text = _add_label(_content, "", 20, Color(0.15, 0.16, 0.18))
	_question_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_question_text.custom_minimum_size = Vector2(940, 95)

	var mode_row: HBoxContainer = HBoxContainer.new()
	mode_row.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_row.add_theme_constant_override("separation", 18)
	_content.add_child(mode_row)
	_mode_buttons.append(
		_add_button(mode_row, "Ritual Padrão  ·  30 perguntas", _start_test.bind(6))
	)
	_mode_buttons.append(
		_add_button(mode_row, "Ritual Completo  ·  60 perguntas", _start_test.bind(12))
	)

	var answer_row: HBoxContainer = HBoxContainer.new()
	answer_row.alignment = BoxContainer.ALIGNMENT_CENTER
	answer_row.add_theme_constant_override("separation", 7)
	_content.add_child(answer_row)
	var labels: Array[String] = [
		"-3\nDiscordo\nmuito",
		"-2\nDiscordo",
		"-1\nDiscordo\nparcialmente",
		"0\nNeutro",
		"+1\nConcordo\nparcialmente",
		"+2\nConcordo",
		"+3\nConcordo\nmuito",
	]
	for index: int in range(labels.size()):
		var answer_button: Button = Button.new()
		answer_button.text = labels[index]
		answer_button.custom_minimum_size = Vector2(125, 68)
		answer_button.add_theme_font_size_override("font_size", 12)
		answer_button.disabled = true
		answer_button.pressed.connect(_answer.bind(index - 3))
		answer_row.add_child(answer_button)
		_answer_buttons.append(answer_button)

	_add_label(
		_content,
		"Cada eixo começa em empate; somente suas respostas determinam a letra. A personalidade do dragão inverte Mente, Natureza, Tática e Identidade, mantendo Energia.",
		13,
		Color(0.39, 0.33, 0.25)
	)


func _start_test(questions_per_axis: int) -> void:
	personality_test.reset()
	questions = personality_test.get_questions(questions_per_axis)
	question_index = 0
	if questions.is_empty():
		_status.text = "Não foi possível carregar as afirmações do oráculo."
		return
	for answer_button: Button in _answer_buttons:
		answer_button.disabled = false
	for mode_button: Button in _mode_buttons:
		mode_button.disabled = true
	_show_question()


func _show_question() -> void:
	if question_index >= questions.size():
		var player_code: String = personality_test.get_player_mbti()
		var dragon_code: String = personality_test.get_complementary_mbti(player_code)
		player_mbti = "%s-%s" % [player_code.substr(0, 4), player_code.substr(4, 1)]
		dragon_mbti = "%s-%s" % [dragon_code.substr(0, 4), dragon_code.substr(4, 1)]
		_progress.text = "Avaliação concluída"
		_question_text.text = "O orbe revela seu perfil: %s. O ovo responde com uma personalidade complementar: %s." % [player_mbti, dragon_mbti]
		_status.text = "O primeiro vínculo foi reconhecido."
		for answer_button: Button in _answer_buttons:
			answer_button.disabled = true
		var continue_button: Button = _add_button(_content, "Seguir para a Trilha da Sobrevivência", _finish_test)
		continue_button.custom_minimum_size = Vector2(0, 48)
		return

	_progress.text = "Pergunta %d de %d  ·  %s" % [
		question_index + 1,
		questions.size(),
		_axis_name(str(questions[question_index]["axis"])),
	]
	_question_text.text = str(questions[question_index]["text"])
	_status.text = "O orbe aguarda sua resposta."


func _answer(value: int) -> void:
	if question_index >= questions.size():
		return
	personality_test.record_answer(questions[question_index], value)
	question_index += 1
	_show_question()


func _finish_test() -> void:
	personality_completed.emit(
		player_mbti,
		dragon_mbti,
		personality_test.get_axis_scores()
	)


func _axis_name(axis: String) -> String:
	var names: Dictionary = {
		"mind": "Mente",
		"energy": "Energia",
		"nature": "Natureza",
		"tactics": "Tática",
		"identity": "Identidade",
	}
	return str(names.get(axis, axis))


func _add_label(parent: Node, text: String, size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


func _add_button(parent: Node, text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(260, 46)
	button.add_theme_font_size_override("font_size", 15)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _parchment_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.84, 0.77, 0.61, 0.98)
	style.border_color = Color(0.46, 0.3, 0.15)
	style.set_border_width_all(4)
	style.set_corner_radius_all(14)
	style.content_margin_left = 28.0
	style.content_margin_right = 28.0
	style.content_margin_top = 20.0
	style.content_margin_bottom = 20.0
	return style


func _add_box(
	parent: Node3D,
	size: Vector3,
	position: Vector3,
	color: Color
) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = position
	instance.material_override = _material(color)
	parent.add_child(instance)
	return instance


func _add_sphere(
	parent: Node3D,
	position: Vector3,
	radius: float,
	color: Color,
	emission: bool = false
) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	instance.mesh = mesh
	instance.position = position
	var material: StandardMaterial3D = _material(color)
	if emission:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 1.5
	instance.material_override = material
	parent.add_child(instance)
	return instance


func _material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.8
	return material
