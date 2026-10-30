extends CanvasLayer
signal closed
var settings: Node
var root: Control
var resolution: OptionButton
var quality: OptionButton
var fullscreen: CheckButton
var volume: HSlider
var status: Label
var confirmation: ConfirmationDialog
var timer: Timer
var previous: Dictionary = {}
var remaining := 15

func _ready() -> void:
	layer = 20
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var shade := ColorRect.new()
	shade.color = Color(0.02,0.03,0.04,0.95)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(460,0)
	center.add_child(panel)
	var margin := MarginContainer.new()
	for edge in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+edge,24)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",12)
	margin.add_child(column)
	add_label(column,"CONFIGURAÇÕES",26)
	add_label(column,"Resolução da janela")
	resolution = OptionButton.new()
	for size in settings.RESOLUTIONS: resolution.add_item("%d × %d" % [size.x,size.y])
	column.add_child(resolution)
	fullscreen = CheckButton.new()
	fullscreen.text = "Tela cheia"
	column.add_child(fullscreen)
	add_label(column,"Qualidade gráfica")
	quality = OptionButton.new()
	for name in ["Leve • sem sombras / sem MSAA","Equilibrada • sombras / MSAA 2x","Alta • sombras / MSAA 4x"]: quality.add_item(name)
	column.add_child(quality)
	add_label(column,"Volume geral")
	volume = HSlider.new()
	volume.max_value = 1
	volume.step = 0.05
	volume.custom_minimum_size.y = 30
	column.add_child(volume)
	status = Label.new()
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.text = "Resolução em tela cheia usa o tamanho do monitor."
	column.add_child(status)
	var row := HBoxContainer.new()
	column.add_child(row)
	for spec in [["Aplicar",apply_values],["Voltar",close]]:
		var button := Button.new()
		button.text = spec[0]
		button.custom_minimum_size.y = 38
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(spec[1])
		row.add_child(button)
	confirmation = ConfirmationDialog.new()
	confirmation.title = "Manter configurações de tela?"
	confirmation.ok_button_text = "Manter"
	confirmation.cancel_button_text = "Restaurar"
	confirmation.confirmed.connect(keep)
	confirmation.canceled.connect(revert)
	root.add_child(confirmation)
	timer = Timer.new()
	timer.wait_time = 1
	timer.timeout.connect(countdown)
	add_child(timer)
	refresh()
	hide()

func add_label(parent: Control, text: String, size: int = 16) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size",size)
	parent.add_child(label)

func refresh() -> void:
	resolution.select(settings.values.resolution)
	quality.select(settings.values.quality)
	fullscreen.set_pressed_no_signal(settings.values.fullscreen)
	volume.set_value_no_signal(settings.values.volume)

func open() -> void:
	refresh()
	show()

func apply_values() -> void:
	if not previous.is_empty(): return
	previous = settings.values.duplicate()
	var candidate := {"resolution":resolution.selected,"quality":quality.selected,"fullscreen":fullscreen.button_pressed,"volume":volume.value}
	settings.apply(candidate)
	if candidate.resolution != previous.resolution or candidate.fullscreen != previous.fullscreen:
		remaining = 15
		confirmation.dialog_text = "A imagem está visível? Restauração automática em 15 segundos."
		confirmation.popup_centered()
		timer.start()
	else: keep()

func keep() -> void:
	timer.stop()
	confirmation.hide()
	if settings.save_settings():
		status.text = "Configurações salvas."
		previous.clear()
	else:
		settings.apply(previous)
		previous.clear()
		refresh()
		status.text = settings.last_error

func revert() -> void:
	timer.stop()
	confirmation.hide()
	if not previous.is_empty(): settings.apply(previous)
	previous.clear()
	refresh()
	status.text = "Configurações anteriores restauradas."

func countdown() -> void:
	remaining -= 1
	if remaining <= 0: revert()
	else: confirmation.dialog_text = "A imagem está visível? Restauração automática em %d segundos." % remaining

func close() -> void:
	if not previous.is_empty(): revert()
	hide()
	closed.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if confirmation.visible: revert()
		else: close()
		get_viewport().set_input_as_handled()
