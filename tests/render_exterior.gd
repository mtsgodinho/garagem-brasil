extends SceneTree
var output := "/workspace/.runtime/exterior/run-%s" % str(Time.get_unix_time_from_system()).replace(".","-")
var garage: Node3D
func _initialize() -> void:
	call_deferred("run")
func capture(name: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name+".png")) == OK)
	print("CAPTURE: "+output.path_join(name+".png"))
func choose(option: OptionButton, index: int) -> void:
	option.select(index)
	option.item_selected.emit(index)
func run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	garage = load("res://scenes/garage.tscn").instantiate()
	garage.persistence_enabled = false
	root.add_child(garage)
	if "clearance" in OS.get_cmdline_user_args():
		garage.customization.body_kit = 2
		garage.customization.lowering_cm = 6
		garage.apply_customization()
		garage.customization_ui.request_open("trunk",true)
		garage.camera.focus_detail("trunk")
		await create_timer(0.4).timeout
		await capture("067-revestimento-interno-final")
		quit()
		return
	var ui: CanvasLayer = garage.customization_ui
	ui.body_picker.color = Color("49687b")
	ui.body_picker.color_changed.emit(ui.body_picker.color)
	ui.tabs.current_tab = 6
	choose(ui.bumper_option,1)
	choose(ui.fender_option,1)
	choose(ui.kit_option,1)
	await capture("059-exterior-esportivo")
	choose(ui.bumper_option,2)
	choose(ui.fender_option,2)
	choose(ui.kit_option,2)
	choose(ui.wheel_option,8)
	ui.lowering_slider.value = 6
	await capture("060-wide-body-rebaixado")
	ui.tabs.current_tab = 7
	choose(ui.sticker_option,1)
	ui.sticker_picker.color = Color("e2b243")
	ui.sticker_picker.color_changed.emit(ui.sticker_picker.color)
	garage.camera.yaw = 1.2
	garage.camera.update_view()
	await capture("061-faixa-lateral")
	choose(ui.sticker_option,2)
	garage.camera.yaw = 0.65
	garage.camera.pitch = 0.4
	garage.camera.update_view()
	await capture("062-listras-conformadas")
	ui.tabs.current_tab = 6
	choose(ui.tail_option,1)
	garage.camera.yaw = 2.65
	garage.camera.pitch = 0.15
	garage.camera.update_view()
	await capture("063-sinaleiras-fume-e-aero")
	ui.tabs.current_tab = 8
	garage.customization_ui.request_open("trunk",true)
	await create_timer(0.4).timeout
	await capture("064-aerofolio-na-tampa-aberta")
	print("PASS: seis capturas de exterior")
	quit()
