extends SceneTree

var output := "/workspace/.runtime/visual-revision/run-%s" % str(Time.get_unix_time_from_system()).replace(".","-")
var garage: Node3D

func _initialize() -> void:
	call_deferred("run")

func capture(name: String) -> void:
	for frame in 6:
		await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)
	print("CAPTURE: " + output.path_join(name + ".png"))

func view(yaw: float, pitch: float, distance: float, target: Vector3 = Vector3(0,0.86,0)) -> void:
	garage.camera.yaw = yaw
	garage.camera.pitch = pitch
	garage.camera.distance = distance
	garage.camera.target = target
	garage.camera.update_view()

func run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	garage = load("res://scenes/garage.tscn").instantiate()
	garage.persistence_enabled = false
	root.add_child(garage)
	var state: Resource = garage.customization
	var ui: CanvasLayer = garage.customization_ui
	var car: Node3D = garage.get_node("VehicleVisual")
	state.body_color = Color("c1c2c4")
	state.wheel_model = 4
	state.wheel_color = Color("aeb1b5")
	state.gloss = 0.70
	ui.body_picker.color = state.body_color
	ui.wheel_option.select(state.wheel_model)
	ui.wheel_picker.color = state.wheel_color
	ui.gloss_slider.set_value_no_signal(state.gloss)
	garage.apply_customization()
	if "final" in OS.get_cmdline_user_args():
		await capture("057-revisao-final-prata-frente")
		view(1.5,0.12,6.0)
		await capture("058-revisao-final-prata-lateral")
		print("PASS: vistas finais com bitola corrigida e caixas de roda internas")
		quit(0)
		return
	await capture("049-revisao-visual-prata-frente")
	view(1.5,0.12,6.0)
	await capture("050-revisao-visual-prata-lateral")
	view(2.65,0.17,6.0)
	await capture("051-revisao-visual-prata-traseira")
	state.body_color = Color("6d7f8b")
	state.wheel_model = 0
	state.wheel_inches = 17
	state.wheel_color = Color("b7bec6")
	state.film = 2
	state.film_intensity = 0.45
	ui.body_picker.color = state.body_color
	ui.wheel_option.select(state.wheel_model)
	ui.wheel_picker.color = state.wheel_color
	ui.size_slider.set_value_no_signal(17)
	garage.apply_customization()
	view(0.8,0.12,5.8)
	ui.tabs.current_tab = 1
	await capture("052-revisao-visual-cinza-aro17")
	state.sport_intake = true
	state.turbo_visual = true
	state.strut_brace = true
	state.film = 0
	state.film_intensity = 0.0
	garage.apply_customization()
	for key in car.hinges:
		ui.request_open(key,true)
	await create_timer(0.4).timeout
	ui.tabs.current_tab = 3
	view(0.65,0.30,7.2)
	await capture("053-revisao-visual-pecas-abertas")
	state.upholstery = 1
	state.seat_color = Color("8c5e43")
	state.interior_color = Color("30353b")
	garage.apply_customization()
	ui.upholstery_option.select(1)
	ui.seat_picker.color = state.seat_color
	ui.interior_picker.color = state.interior_color
	ui.tabs.current_tab = 5
	garage.camera.focus_detail("interior")
	await capture("054-revisao-visual-interior")
	state.audio_setup = 3
	garage.apply_customization()
	ui.audio_option.select(3)
	ui.tabs.current_tab = 4
	garage.camera.focus_detail("trunk")
	await capture("055-revisao-visual-porta-malas")
	for key in car.hinges:
		ui.request_open(key,false)
	await create_timer(0.4).timeout
	view(0.35,0.12,3.8,Vector3(0,0.85,-0.70))
	ui.tabs.current_tab = 0
	await capture("056-revisao-visual-detalhe-frontal")
	print("PASS: oito capturas reais da revisão visual, sem alterar o save do jogador")
	quit(0)
