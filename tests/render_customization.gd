extends SceneTree

var garage: Node3D
var previous_body: Image
var clear_glass: Image
var samples := 0
var output := "/workspace/.runtime/customization/run-%s" % str(Time.get_unix_time_from_system()).replace(".", "-")

func _initialize() -> void:
	call_deferred("run")

func capture(filename: String) -> Image:
	for frame in 5:
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var result := image.save_png(output.path_join(filename + ".png"))
	assert(result == OK,"Salvar captura")
	print("CAPTURE: " + filename)
	samples += 1
	return image

func different_pixels(first: Image, second: Image, region: Rect2i) -> int:
	var count := 0
	for y in range(region.position.y,region.end.y):
		for x in range(region.position.x,region.end.x):
			var a := first.get_pixel(x,y)
			var b := second.get_pixel(x,y)
			if absf(a.r-b.r) + absf(a.g-b.g) + absf(a.b-b.b) > 0.08:
				count += 1
	return count

func run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	garage = load("res://scenes/garage.tscn").instantiate()
	garage.persistence_enabled = false
	root.add_child(garage)
	var state: Resource = garage.customization
	var ui: CanvasLayer = garage.customization_ui
	previous_body = await capture("002-personalizacao-padrao")
	ui.body_picker.color = Color("ac2535")
	ui.body_picker.color_changed.emit(ui.body_picker.color)
	ui.finish_option.select(1)
	ui.finish_option.item_selected.emit(1)
	var red := await capture("003-pintura-vermelha-metalica")
	assert(different_pixels(previous_body,red,Rect2i(290,300,520,230)) > 1000,"Pintura muda pixels da carroceria")
	ui.body_picker.color = Color("205d98")
	ui.body_picker.color_changed.emit(ui.body_picker.color)
	ui.finish_option.select(2)
	ui.finish_option.item_selected.emit(2)
	await capture("004-pintura-azul-fosca")
	ui.tabs.current_tab = 1
	garage.camera.yaw = 1.15
	garage.camera.update_view()
	for model in 5:
		ui.wheel_option.select(model)
		ui.wheel_option.item_selected.emit(model)
		ui.size_slider.value = 17
		ui.wheel_picker.color = Color("bfa365")
		ui.wheel_picker.color_changed.emit(ui.wheel_picker.color)
		await capture("%03d-rodas-modelo-%d" % [5+model,model+1])
	ui.tabs.current_tab = 2
	garage.camera.yaw = 0.65
	garage.camera.update_view()
	for film in 6:
		ui.film_option.select(film)
		ui.film_option.item_selected.emit(film)
		var image := await capture("%03d-pelicula-%d" % [10+film,film])
		if film == 0:
			clear_glass = image
		if film == 4:
			assert(different_pixels(clear_glass,image,Rect2i(380,270,310,105)) > 1000,"Transparência dos vidros muda na renderização")
	garage.camera.yaw = -1.05
	garage.camera.update_view()
	await capture("016-outro-lado-espelhada")
	print("PASS: %d capturas renderizadas; pintura e película alteram pixels do veículo" % samples)
	quit(0)
