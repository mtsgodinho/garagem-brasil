extends SceneTree
var output := "/workspace/.runtime/menu-workshop/run-%s" % str(Time.get_unix_time_from_system()).replace(".","-")
var app: Node
func _initialize() -> void: call_deferred("run")
func capture(name: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name+".png")) == OK)
	print("CAPTURE: "+output.path_join(name+".png"))
func run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	app = load("res://scenes/main.tscn").instantiate()
	app.persistence_enabled = false
	app.allow_window_changes = false
	app.settings_path = output+"/settings.cfg"
	root.add_child(app)
	await capture("096-menu-oficina")
	app.options.open()
	await capture("097-configuracoes")
	app.options.close()
	app.open_garage()
	app.garage.camera.yaw = 2.5
	app.garage.camera.pitch = 0.3
	app.garage.camera.distance = 8.0
	app.garage.camera.update_view()
	await capture("098-oficina-bancadas-e-ferramentas")
	app.garage.customization_ui.tabs.current_tab = 9
	app.garage.customization_ui.performance_option.select(3)
	app.garage.customization_ui.performance_option.item_selected.emit(3)
	app.garage.customization_ui.nitro_check.button_pressed = true
	await capture("099-preparacao-e-nitro")
	app.garage.enter_track()
	var driver: CharacterBody3D = app.garage.track.driver
	driver.manual_controls = true
	driver.test_accelerate = true
	await create_timer(2).timeout
	driver.test_nitro = true
	await create_timer(0.8).timeout
	await capture("100-nitro-na-pista")
	driver.test_nitro = false
	driver.test_accelerate = false
	driver.reset_vehicle()
	driver.apply_impact(24)
	app.garage.leave_track()
	await process_frame
	app.garage.camera.focus_detail("hood")
	await capture("101-danos-no-capo")
	app.garage.repair_vehicle()
	await capture("102-carro-reparado")
	app.show_menu()
	await capture("103-menu-retorno")
	await create_timer(0.1).timeout
	print("PASS: menu oficina configuracoes nitro dano e reparo renderizados")
	app.garage.request_exit()
