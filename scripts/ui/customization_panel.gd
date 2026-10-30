extends CanvasLayer

const State = preload("res://scripts/customization/vehicle_customization.gd")

signal customization_changed
signal restore_camera
signal save_requested
signal exit_requested

var state: Resource
var tabs: TabContainer
var body_picker: ColorPickerButton
var wheel_picker: ColorPickerButton
var finish_option: OptionButton
var gloss_slider: HSlider
var wheel_option: OptionButton
var size_slider: HSlider
var film_option: OptionButton
var film_slider: HSlider
var film_value: Label
var finish_value: Label
var size_value: Label
var status: Label
var save_button: Button

func setup(customization: Resource) -> void:
	state = customization
	build()

func label(text: String, size: int = 16) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size",size)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node

func dropdown(options: Array, selected: int) -> OptionButton:
	var node := OptionButton.new()
	node.custom_minimum_size.y = 36
	for option in options:
		node.add_item(option)
	node.selected = selected
	return node

func slider(minimum: float, maximum: float, step_value: float, value: float) -> HSlider:
	var node := HSlider.new()
	node.min_value = minimum
	node.max_value = maximum
	node.step = step_value
	node.value = value
	node.custom_minimum_size.y = 28
	return node

func picker(color: Color) -> ColorPickerButton:
	var node := ColorPickerButton.new()
	node.color = color
	node.edit_alpha = false
	node.custom_minimum_size.y = 40
	return node

func page(title: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = title
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for edge in ["left","right","top","bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 14)
	scroll.add_child(margin)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation",10)
	margin.add_child(column)
	return column

func note(column: VBoxContainer, text: String) -> void:
	var node := label(text,14)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.modulate = Color("aabacb")
	column.add_child(node)

func build() -> void:
	var root := Control.new()
	root.name = "CustomizationUI"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var heading := label("GARAGEM BRASIL\nESTÚDIO 03 / SALVAMENTO",22)
	heading.position = Vector2(28,22)
	root.add_child(heading)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	panel.offset_left = -336
	panel.offset_right = -16
	panel.offset_top = 20
	panel.offset_bottom = -112
	var style := StyleBoxFlat.new()
	style.bg_color = Color("101b27")
	style.border_color = Color("3c5266")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12)
	panel.add_theme_stylebox_override("panel",style)
	root.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",12)
	panel.add_child(column)
	column.add_child(label("PERSONALIZAR",20))
	tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(tabs)
	build_paint(page("Pintura"))
	build_wheels(page("Rodas"))
	build_film(page("Vidros"))
	save_button = Button.new()
	save_button.text = "Salvar modificações"
	save_button.custom_minimum_size.y = 36
	save_button.pressed.connect(func() -> void: save_requested.emit())
	column.add_child(save_button)
	var bottom := PanelContainer.new()
	bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -96
	var bottom_style := StyleBoxFlat.new()
	bottom_style.bg_color = Color(0.035,0.05,0.07,0.97)
	bottom_style.content_margin_left = 24
	bottom_style.content_margin_right = 24
	bottom_style.content_margin_top = 12
	bottom_style.content_margin_bottom = 12
	bottom.add_theme_stylebox_override("panel",bottom_style)
	root.add_child(bottom)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",14)
	bottom.add_child(row)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	info.add_child(label("GOL G3 • MODELO PROVISÓRIO / geometria aproximada",15))
	info.add_child(label("Arraste na cena: girar • Roda do mouse: zoom • R: restaurar câmera",14))
	status = label("Personalize seu carro • salvamento automático ativo",14)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.modulate = Color("e3b36c")
	info.add_child(status)
	var reset := Button.new()
	reset.text = "Restaurar câmera"
	reset.pressed.connect(func() -> void: restore_camera.emit())
	row.add_child(reset)
	var quit := Button.new()
	quit.text = "Sair"
	quit.pressed.connect(func() -> void: exit_requested.emit())
	row.add_child(quit)

func changed() -> void:
	customization_changed.emit()

func build_paint(column: VBoxContainer) -> void:
	column.add_child(label("Cor da carroceria"))
	body_picker = picker(state.body_color)
	body_picker.name = "BodyColor"
	column.add_child(body_picker)
	body_picker.color_changed.connect(func(color: Color) -> void:
		state.body_color = color
		changed())
	var palette := HBoxContainer.new()
	palette.add_theme_constant_override("separation",6)
	column.add_child(palette)
	for hex in ["b8cbd5","c43c42","2469ad","183f36","e2bd57","171d26"]:
		var swatch := Button.new()
		swatch.custom_minimum_size = Vector2(30,28)
		var style := StyleBoxFlat.new()
		var color := Color(hex)
		style.bg_color = color
		style.set_corner_radius_all(4)
		for mode in ["normal","hover","pressed","focus"]:
			swatch.add_theme_stylebox_override(mode, style)
		swatch.tooltip_text = "#" + hex
		swatch.pressed.connect(func() -> void:
			state.body_color = color
			body_picker.color = color
			changed())
		palette.add_child(swatch)
	column.add_child(label("Acabamento"))
	finish_option = dropdown(State.FINISHES,state.finish)
	column.add_child(finish_option)
	finish_option.item_selected.connect(func(index: int) -> void:
		state.finish = index
		changed())
	finish_value = label("Brilho: %d%%" % roundi(state.gloss * 100))
	column.add_child(finish_value)
	gloss_slider = slider(0,1,0.01,state.gloss)
	column.add_child(gloss_slider)
	gloss_slider.value_changed.connect(func(value: float) -> void:
		state.gloss = value
		finish_value.text = "Brilho: %d%%" % roundi(value * 100)
		changed())
	note(column,"Clique na amostra grande para escolher qualquer cor. O acabamento fosco mantém os reflexos suaves, mesmo com brilho alto.")

func build_wheels(column: VBoxContainer) -> void:
	column.add_child(label("Desenho"))
	wheel_option = dropdown(State.WHEEL_NAMES,state.wheel_model)
	column.add_child(wheel_option)
	wheel_option.item_selected.connect(func(index: int) -> void:
		state.wheel_model = index
		changed())
	column.add_child(label("Cor das rodas"))
	wheel_picker = picker(state.wheel_color)
	column.add_child(wheel_picker)
	wheel_picker.color_changed.connect(func(color: Color) -> void:
		state.wheel_color = color
		changed())
	size_value = label("Aro: %d polegadas" % state.wheel_inches)
	column.add_child(size_value)
	size_slider = slider(13,17,1,state.wheel_inches)
	column.add_child(size_slider)
	size_slider.value_changed.connect(func(value: float) -> void:
		state.wheel_inches = roundi(value)
		size_value.text = "Aro: %d polegadas" % state.wheel_inches
		changed())
	note(column,"Cinco desenhos procedurais próprios. O aro muda e o perfil do pneu compensa, mantendo o diâmetro externo e a altura do carro.")

func build_film(column: VBoxContainer) -> void:
	column.add_child(label("Tipo de película"))
	film_option = dropdown(State.FILMS,state.film)
	column.add_child(film_option)
	film_value = label("Intensidade: %d%%" % roundi(state.film_intensity * 100))
	column.add_child(film_value)
	film_slider = slider(0,1,0.01,state.film_intensity)
	film_slider.editable = state.film != 0
	column.add_child(film_slider)
	film_option.item_selected.connect(func(index: int) -> void:
		state.select_film(index)
		film_slider.set_value_no_signal(state.film_intensity)
		film_slider.editable = index != 0
		film_value.text = "Intensidade: %d%%" % roundi(state.film_intensity * 100)
		changed())
	film_slider.value_changed.connect(func(value: float) -> void:
		state.film_intensity = value
		film_value.text = "Intensidade: %d%%" % roundi(value * 100)
		changed())
	note(column,"Intensidade visual, sem equivalência com transmissão luminosa legal. A espelhada usa reflexos leves do céu; não reflete todos os objetos da garagem.")

func set_save_status(text: String, warning: bool = false) -> void:
	status.text = text
	status.modulate = Color("e3b36c") if warning else Color("98d7b0")
