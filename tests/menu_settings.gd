extends SceneTree
var failed := false
var checks := 0
func _initialize() -> void: call_deferred("run")
func check(condition: bool, message: String) -> void:
	checks+=1
	if not condition and not failed:
		failed = true
		push_error(message)
		quit(1)
func run() -> void:
	var app: Node = load("res://scenes/main.tscn").instantiate()
	app.settings_path = "/workspace/.runtime/settings-test-%s.cfg" % Time.get_ticks_usec()
	app.allow_window_changes = false
	app.persistence_enabled = false
	root.add_child(app)
	await process_frame
	check(app.menu.visible and not app.garage.customization_ui.visible,"Menu inicial aparece antes da garagem")
	app.open_garage()
	check(not app.menu.visible and app.garage.customization_ui.visible,"Garagem acessível no menu")
	app.garage.menu_requested.emit()
	check(app.menu.visible,"Retorna ao menu sem perder garagem")
	var settings: Node = app.settings
	var panel: CanvasLayer = app.options
	panel.open()
	panel.quality.select(0)
	panel.volume.value = 0.0
	panel.apply_values()
	check(settings.values.quality == 0 and AudioServer.is_bus_mute(0),"Leve e volume zero aplicados")
	check(FileAccess.file_exists(app.settings_path),"Configurações persistidas")
	var clone = load("res://scripts/settings/game_settings.gd").new()
	clone.file_path = app.settings_path
	clone.load_settings()
	check(clone.values.quality == 0 and clone.values.volume == 0,"Carrega preferências salvas")
	clone.free()
	panel.resolution.select(2)
	panel.fullscreen.button_pressed = true
	panel.quality.select(2)
	panel.volume.value = 0.8
	panel.apply_values()
	check(panel.confirmation.visible and settings.values.resolution == 2,"Mudança de tela pede confirmação")
	panel.remaining = 1
	panel.countdown()
	check(settings.values.resolution == 1 and not settings.values.fullscreen,"Timeout restaura tela anterior")
	check(settings.values.quality == 0 and settings.values.volume == 0,"Restaura conjunto de preferências anterior")
	panel.resolution.select(0)
	panel.quality.select(1)
	panel.volume.value = 0.75
	panel.apply_values()
	panel.keep()
	check(settings.values.resolution == 0 and settings.values.quality == 1,"Pode confirmar nova resolução")
	check(not AudioServer.is_bus_mute(0),"Volume restaurado")
	var normalized: Dictionary = settings.normalize({"quality":10,"resolution":"bad","volume":-2,"fullscreen":"true"})
	check(normalized == settings.DEFAULTS,"Valores inválidos usam padrões seguros")
	panel.close()
	app.play()
	await process_frame
	check(app.garage.track != null,"Jogar inicia pista")
	check(not app.menu.visible,"Menu não cobre a pista")
	app.garage.leave_track()
	await create_timer(0.05).timeout
	check(app.garage.customization_ui.visible,"Retorno da pista permite personalizar")
	app.show_menu()
	check(app.menu.visible,"Menu pode ser reaberto")
	await create_timer(0.12).timeout
	if not failed:
		print("PASS: %d verificações de menu configurações confirmação e retorno" % checks)
		quit()
