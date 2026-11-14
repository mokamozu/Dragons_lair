class_name MagePersonalityTest
extends RefCounted

const QUESTION_PATH: String = "res://data/mage_questions.json"
const AXIS_POLES: Dictionary = {
	"mind": ["E", "I"],
	"energy": ["N", "S"],
	"nature": ["T", "F"],
	"tactics": ["J", "P"],
	"identity": ["A", "T"],
}
var scores: Dictionary = {}


func _init() -> void:
	reset()


func reset() -> void:
	scores.clear()
	for axis: String in AXIS_POLES:
		scores[axis] = {AXIS_POLES[axis][0]: 0, AXIS_POLES[axis][1]: 0}


func get_questions(question_count_per_axis: int) -> Array[Dictionary]:
	assert(question_count_per_axis == 6 or question_count_per_axis == 12)
	var file: FileAccess = FileAccess.open(QUESTION_PATH, FileAccess.READ)
	if file == null:
		push_error("Não foi possível abrir o banco de perguntas: %s" % QUESTION_PATH)
		return []
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or not parsed.get("questions") is Array:
		push_error("Banco de perguntas inválido: %s" % QUESTION_PATH)
		return []

	var grouped: Dictionary = {}
	for axis: String in AXIS_POLES:
		grouped[axis] = []
	for question: Variant in parsed["questions"]:
		if question is Dictionary and grouped.has(str(question.get("axis"))):
			grouped[question["axis"]].append(question)

	var selected: Array[Dictionary] = []
	for axis: String in AXIS_POLES:
		var axis_questions: Array = grouped[axis]
		if axis_questions.size() < question_count_per_axis:
			push_error("Perguntas insuficientes para o eixo %s." % axis)
			return []
		var questions_by_pole: Dictionary = {}
		for pole: String in AXIS_POLES[axis]:
			questions_by_pole[pole] = []
		for question: Dictionary in axis_questions:
			questions_by_pole[question["agree_pole"]].append(question)
		var questions_per_pole: int = int(question_count_per_axis / 2.0)
		for pole: String in AXIS_POLES[axis]:
			var pole_questions: Array = questions_by_pole[pole]
			pole_questions.shuffle()
			if pole_questions.size() < questions_per_pole:
				push_error("Perguntas insuficientes para o polo %s do eixo %s." % [pole, axis])
				return []
			for index: int in range(questions_per_pole):
				selected.append(pole_questions[index])
	selected.shuffle()
	return selected


func record_answer(question: Dictionary, answer: int) -> void:
	assert(answer >= -3 and answer <= 3)
	var axis: String = str(question.get("axis"))
	var agree_pole: String = str(question.get("agree_pole"))
	if not scores.has(axis) or not scores[axis].has(agree_pole):
		push_error("Pergunta contém eixo ou polo inválido: %s" % question)
		return
	var contribution: int = answer
	scores[axis][agree_pole] += contribution
	var opposite: String = str(AXIS_POLES[axis][1] if agree_pole == AXIS_POLES[axis][0] else AXIS_POLES[axis][0])
	scores[axis][opposite] -= contribution


func get_player_mbti() -> String:
	var result: String = ""
	for axis: String in AXIS_POLES:
		var poles: Array = AXIS_POLES[axis]
		var axis_scores: Dictionary = scores[axis]
		result += str(poles[0] if axis_scores[poles[0]] >= axis_scores[poles[1]] else poles[1])
	return result


func get_complementary_mbti(player_mbti: String) -> String:
	if player_mbti.length() != 5:
		push_error("Código MBTI inválido: %s" % player_mbti)
		return ""
	var complement: String = ""
	var axes: Array[String] = ["mind", "energy", "nature", "tactics"]
	for index: int in range(axes.size()):
		var letter: String = player_mbti.substr(index, 1)
		var poles: Array = AXIS_POLES[axes[index]]
		var pair: String = str(poles[0]) + str(poles[1])
		if pair.length() != 2 or not pair.contains(letter):
			push_error("Código MBTI inválido: %s" % player_mbti)
			return ""
		if axes[index] == "energy":
			complement += letter
		else:
			complement += str(pair[1] if letter == pair[0] else pair[0])
	var identity: String = player_mbti.substr(4, 1)
	if identity != "A" and identity != "T":
		push_error("Identidade MBTI inválida: %s" % player_mbti)
		return ""
	complement += "T" if identity == "A" else "A"
	return complement


func get_axis_scores() -> Dictionary:
	return scores.duplicate(true)
