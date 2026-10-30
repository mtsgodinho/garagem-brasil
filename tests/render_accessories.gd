extends SceneTree

var output := "/workspace/.runtime/accessories/run-%s" % str(Time.get_unix_time_from_system()).replace(".","-")
var garage: Node3D

func _initialize() -> void:
	call_deferred("run")

func capture(name: String) -> void:
	for frame in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)
	print("CAPTURE: " + output.path_join(name + ".png"))

func view(yaw: float, pitch: float, distance: float, target: Vector3 = Vector3(0,1,0)) -> void:
	garage.camera.yaw = yaw
	garage.camera.pitch = pitch
	garage.camera.distance = distance
	garage.camera.target = target
	garage.camera.update_view()

func run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	garage = load("res://scenes/garage.tscn").instantiate()
	garage.save_path = output + "/test-save.json"
	root.add_child(garage)
	var ui: CanvasLayer = garage.customization_ui
	var car: Node3D = garage.get_node("VehicleVisual")
	ui.tabs.current_tab = 3
	view(0.65,0.28,7.2)
	await capture("029-garagem-articulada-fechada")
	for part in car.hinges:
		ui.request_open(part,true)
	await create_timer(0.4).timeout
	await capture("030-portas-capo-porta-malas-abertos")
	ui.tabs.current_tab = 4
	ui.sport_intake_check.button_pressed = true
	ui.turbo_check.button_pressed = true
	ui.brace_check.button_pressed = true
	view(0.65,0.60,4.8,Vector3(0,1.0,-0.6))
	await capture("031-pecas-do-motor")
	view(2.65,0.35,5.4,Vector3(0,1,0.5))
	for setup in range(1,4):
		ui.audio_option.select(setup)
		ui.audio_option.item_selected.emit(setup)
		await capture("%03d-caixa-som-%d" % [31+setup,setup])
	ui.tabs.current_tab = 5
	ui.interior_picker.color = Color("bfb195")
	ui.interior_picker.color_changed.emit(ui.interior_picker.color)
	ui.seat_picker.color = Color("914835")
	ui.seat_picker.color_changed.emit(ui.seat_picker.color)
	view(1.25,0.40,4.6,Vector3(0,1.0,0.12))
	for upholstery in 3:
		ui.upholstery_option.select(upholstery)
		ui.upholstery_option.item_selected.emit(upholstery)
		await capture("%03d-estofado-%d" % [35+upholstery,upholstery])
	assert(garage.save_now())
	print("PASS: nove capturas de aberturas, motor, caixas e estofados")
	quit(0)
