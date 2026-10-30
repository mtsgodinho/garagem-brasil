extends Node
const Settings = preload("res://scripts/settings/game_settings.gd")
const SettingsPanel = preload("res://scripts/menu/settings_panel.gd")
var garage: Node3D
var settings: Node
var options: CanvasLayer
var menu: CanvasLayer
var state := "menu"
var settings_path := "user://settings.cfg"
var save_path := "user://garagem/customization.json"
var allow_window_changes := true
var persistence_enabled := true

func _ready() -> void:
	settings = Settings.new()
	settings.file_path = settings_path
	settings.allow_window_changes = allow_window_changes
	add_child(settings)
	garage = load("res://scenes/garage.tscn").instantiate()
	garage.save_path = save_path
	garage.persistence_enabled = persistence_enabled
	add_child(garage)
	garage.menu_requested.connect(show_menu)
	options = SettingsPanel.new()
	options.settings = settings
	add_child(options)
	build_menu()
	show_menu()
	if "--self-test" in OS.get_cmdline_user_args(): call_deferred("export_smoke_test")

func build_menu() -> void:
	menu = CanvasLayer.new()
	menu.layer = 5
	add_child(menu)
	var panel := PanelContainer.new()
	panel.position = Vector2(36,72)
	panel.custom_minimum_size = Vector2(360,510)
	menu.add_child(panel)
	var margin := MarginContainer.new()
	for edge in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+edge,24)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",14)
	margin.add_child(column)
	var title := Label.new()
	title.text = "GARAGEM\nBRASIL"
	title.add_theme_font_size_override("font_size",42)
	column.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "PROTÓTIPO 0.10.0 • GOL G3\nMonte seu carro. Teste na pista."
	column.add_child(subtitle)
	for spec in [["Jogar • testar carro",play],["Garagem • personalizar",open_garage],["Configurações",func() -> void: options.open()],["Sair",func() -> void: garage.request_exit()]]:
		var button := Button.new()
		button.text = spec[0]
		button.custom_minimum_size.y = 46
		button.pressed.connect(spec[1])
		column.add_child(button)

func show_menu() -> void:
	state = "menu"
	garage.preview_engine = false
	garage.engine_audio.stop_sound()
	garage.customization_ui.hide()
	garage.camera.dragging = false
	garage.camera.set_process_input(false)
	garage.camera.set_process_unhandled_input(false)
	menu.show()

func open_garage() -> void:
	state = "game"
	menu.hide()
	garage.customization_ui.show()
	garage.camera.set_process_input(true)
	garage.camera.set_process_unhandled_input(true)

func play() -> void:
	garage.enter_track()
	if garage.track != null:
		state = "game"
		menu.hide()
	else: open_garage()

func _process(delta: float) -> void:
	if state == "menu" and not options.visible:
		garage.camera.yaw += delta*0.06
		garage.camera.update_view()

func export_smoke_test() -> void:
	# Internal QA entry point, also run in the exported release binary.
	open_garage()
	garage.customization.body_color = Color("a72d43")
	garage.customization.wheel_model = 9
	garage.apply_customization()
	play()
	if garage.track == null:
		push_error("EXPORT_SMOKE: track missing")
		get_tree().quit(1)
		return
	garage.track.driver.manual_controls = true
	garage.track.driver.test_accelerate = true
	for i in 90: await get_tree().physics_frame
	if garage.track.driver.speed < 2 or not garage.track.driver.visual.body_material.albedo_color.is_equal_approx(Color("a72d43")):
		push_error("EXPORT_SMOKE: driving/customization failed")
		get_tree().quit(1)
		return
	garage.leave_track()
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		garage.enter_photo()
		for i in 4: await get_tree().process_frame
		if not await garage.photo.capture():
			push_error("EXPORT_SMOKE: photo failed")
			get_tree().quit(1)
			return
		garage.photo.close()
		await get_tree().process_frame
	show_menu()
	print("PASS: EXPORTED_GAME menu, track, movement, customization and return")
	garage.request_exit()
