extends SceneTree

var output := "/workspace/.runtime/persistence/run-%s" % str(Time.get_unix_time_from_system()).replace(".","-")
var garage: Node3D

func _initialize() -> void:
	call_deferred("run")

func open_garage(path: String) -> void:
	garage = load("res://scenes/garage.tscn").instantiate()
	garage.save_path = path
	root.add_child(garage)

func capture(name: String) -> void:
	for frame in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)
	print("CAPTURE: " + output.path_join(name + ".png"))

func run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	var path := output + "/test-save.json"
	open_garage(path)
	var ui: CanvasLayer = garage.customization_ui
	ui.body_picker.color = Color("286a4c")
	ui.body_picker.color_changed.emit(ui.body_picker.color)
	ui.wheel_picker.color = Color("cab065")
	ui.wheel_picker.color_changed.emit(ui.wheel_picker.color)
	ui.wheel_option.select(1)
	ui.wheel_option.item_selected.emit(1)
	ui.size_slider.value = 17
	ui.film_option.select(2)
	ui.film_option.item_selected.emit(2)
	ui.save_button.pressed.emit()
	assert(not garage.dirty and FileAccess.file_exists(path))
	await capture("017-modificacoes-salvas")
	ui.save_button.pressed.emit()
	garage.queue_free()
	await process_frame
	open_garage(path)
	assert(garage.customization_ui.status.text == "Modificações carregadas.")
	assert(garage.customization.body_color.is_equal_approx(Color("286a4c")))
	await capture("018-modificacoes-carregadas")
	garage.queue_free()
	await process_frame
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string("JSON inválido de teste")
	file.close()
	open_garage(path)
	assert(garage.store.load_result == "recovered")
	await capture("019-recuperacao-de-backup")
	print("PASS: interface de gravação, carregamento e recuperação renderizada")
	quit(0)
