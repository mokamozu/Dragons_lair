extends CanvasLayer

var player: Node3D
var _hp_bar: ProgressBar
var _stamina_bar: ProgressBar
var _dragon_label: Label
var _state_label: Label
var _speed_label: Label
var _prompt_label: Label
var _inventory_label: Label
var _mount_hint: Label


func _ready() -> void:
	_build_hud()


func _process(_delta: float) -> void:
	if player == null:
		return
	var dragon: Node3D = player.get("companion")
	if dragon == null:
		return
	var stats: Resource = dragon.get("stats")
	_hp_bar.max_value = stats.get("max_hp")
	_hp_bar.value = dragon.get("current_hp")
	_stamina_bar.max_value = stats.get("max_stamina")
	_stamina_bar.value = dragon.get("current_stamina")
	_dragon_label.text = "%s  ·  %s" % [stats.get("dragon_name"), stats.get("element")]
	_state_label.text = "Estado: %s" % dragon.call("get_state_label")
	var mounted: bool = bool(player.get("is_mounted"))
	if mounted and dragon.has_method("get_flight_status_label"):
		var flight_status: String = str(dragon.call("get_flight_status_label"))
		if not flight_status.is_empty():
			_state_label.text += "\n%s" % flight_status
	_speed_label.visible = mounted
	if mounted:
		var horizontal_speed: float = Vector2(dragon.get("velocity").x, dragon.get("velocity").z).length()
		_speed_label.text = "Velocidade: %d" % roundi(horizontal_speed)
	_mount_hint.text = (
		"F: desmontar (pouse primeiro)" if mounted else "F: montar  ·  G: ficar/seguir"
	)
	_prompt_label.text = str(player.get("current_prompt"))
	var inventory: Dictionary = player.get("inventory")
	_inventory_label.text = "Recursos: %s" % _format_inventory(inventory)


func bind_player(player_node: Node3D) -> void:
	player = player_node


func _build_hud() -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.position = Vector2(18, 18)
	panel.custom_minimum_size = Vector2(310, 0)
	panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(panel)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 6)
	panel.add_child(layout)

	_dragon_label = _label("BRASA  ·  FOGO", 20, Color(1.0, 0.82, 0.48))
	layout.add_child(_dragon_label)
	_state_label = _label("Estado: Seguindo", 15, Color(0.9, 0.88, 0.78))
	layout.add_child(_state_label)
	_hp_bar = _make_bar(Color(0.68, 0.17, 0.12))
	layout.add_child(_hp_bar)
	_stamina_bar = _make_bar(Color(0.2, 0.55, 0.72))
	layout.add_child(_stamina_bar)
	_speed_label = _label("", 15, Color(0.75, 0.88, 1.0))
	layout.add_child(_speed_label)
	_inventory_label = _label("Recursos: nenhum", 14, Color(0.82, 0.83, 0.73))
	layout.add_child(_inventory_label)
	_mount_hint = _label("F: montar  ·  G: ficar/seguir", 14, Color(1.0, 0.84, 0.55))
	layout.add_child(_mount_hint)

	_prompt_label = _label("", 20, Color(1.0, 0.94, 0.75))
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt_label.position = Vector2(-220, -90)
	_prompt_label.custom_minimum_size = Vector2(440, 42)
	add_child(_prompt_label)


func _make_bar(fill_color: Color) -> ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(280, 18)
	bar.max_value = 100.0
	bar.value = 100.0
	bar.show_percentage = false
	var background: StyleBoxFlat = StyleBoxFlat.new()
	background.bg_color = Color(0.12, 0.13, 0.13, 0.95)
	background.border_color = Color(0.49, 0.39, 0.24)
	background.set_border_width_all(1)
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = fill_color
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	return bar


func _label(text: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.09, 0.08, 0.9)
	style.border_color = Color(0.54, 0.42, 0.23, 0.95)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style


func _format_inventory(inventory: Dictionary) -> String:
	if inventory.is_empty():
		return "nenhum"
	var pieces: PackedStringArray = []
	for item_name: Variant in inventory:
		pieces.append("%s x%d" % [item_name, inventory[item_name]])
	return ", ".join(pieces)
