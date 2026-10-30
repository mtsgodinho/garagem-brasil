extends SceneTree
var output := "/workspace/.runtime/sound-low/run-%s" % str(Time.get_unix_time_from_system()).replace(".","-")
var garage: Node3D
func _initialize() -> void: call_deferred("run")
func capture(name: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name+".png")) == OK)
	print("CAPTURE: "+output.path_join(name+".png"))
func choose(option: OptionButton, value: int) -> void:
	option.select(value)
	option.item_selected.emit(value)
func run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	garage = load("res://scenes/garage.tscn").instantiate()
	garage.persistence_enabled = false
	root.add_child(garage)
	var ui: CanvasLayer = garage.customization_ui
	choose(ui.front_option,4)
	choose(ui.rear_option,4)
	choose(ui.skirt_option,3)
	ui.lowering_slider.value = 6
	ui.tabs.current_tab = 6
	if "final" in OS.get_cmdline_user_args():
		await capture("092-kit-baixo-com-volume-final")
		garage.camera.yaw = 1.5
		garage.camera.pitch = 0.1
		garage.camera.update_view()
		await capture("093-saia-baixa-final")
		garage.camera.yaw = 2.65
		garage.camera.update_view()
		await capture("094-traseiro-baixo-final")
		ui.tabs.current_tab = 4
		choose(ui.intake_option,2)
		garage.camera.focus_detail("hood")
		ui.tabs.get_child(4).ensure_control_visible(ui.intake_option)
		await create_timer(0.4).timeout
		await capture("095-duplo-fluxo-final")
		quit()
		return
	await capture("086-parachoques-e-saia-arrastando")
	garage.camera.yaw = 1.5
	garage.camera.pitch = 0.1
	garage.camera.update_view()
	await capture("087-saia-lateral-no-piso")
	garage.camera.yaw = 2.65
	garage.camera.update_view()
	await capture("088-parachoque-traseiro-baixo")
	ui.tabs.current_tab = 4
	choose(ui.intake_option,2)
	choose(ui.sound_option,0)
	garage.camera.focus_detail("hood")
	ui.tabs.get_child(4).ensure_control_visible(ui.intake_option)
	await create_timer(0.4).timeout
	await capture("089-filtro-duplo-e-ronco-automatico")
	choose(ui.intake_option,3)
	await capture("090-admissao-fria")
	garage.enter_track()
	garage.track.driver.manual_controls = true
	garage.track.driver.test_accelerate = true
	await create_timer(1.5).timeout
	await capture("091-pista-com-kit-baixo-e-ronco")
	garage.leave_track()
	await create_timer(0.1).timeout
	print("PASS: capturas de filtros e peças no piso")
	quit()
