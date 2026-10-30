extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func mouse_button(at: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = at
	event.global_position = at
	root.push_input(event)

func motion(at: Vector2, delta: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = at
	event.global_position = at
	event.relative = delta
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(event)

func run() -> void:
	var garage: Node3D = load("res://scenes/garage.tscn").instantiate()
	root.add_child(garage)
	for i in 5:
		await process_frame
	var ui: CanvasLayer = garage.customization_ui
	var camera: Camera3D = garage.camera
	var yaw: float = camera.yaw
	var start: Vector2 = ui.gloss_slider.get_global_rect().get_center()
	mouse_button(start,true)
	motion(start+Vector2(35,0),Vector2(35,0))
	mouse_button(start+Vector2(35,0),false)
	await process_frame
	assert(is_equal_approx(camera.yaw,yaw),"Arrastar slider não gira câmera")
	assert(not camera.dragging,"Slider não inicia órbita")
	assert(not is_equal_approx(garage.customization.gloss,0.65),"Mouse altera slider real")
	start = Vector2(500,220)
	mouse_button(start,true)
	motion(start+Vector2(60,0),Vector2(60,0))
	mouse_button(ui.gloss_slider.get_global_rect().get_center(),false)
	await process_frame
	assert(not is_equal_approx(camera.yaw,yaw),"Mouse na cena gira câmera")
	assert(not camera.dragging,"Soltar sobre interface encerra órbita")
	start = ui.body_picker.get_global_rect().get_center()
	mouse_button(start,true)
	mouse_button(start,false)
	await process_frame
	assert(ui.body_picker.get_popup().visible,"Clique abre seletor de qualquer cor")
	ui.body_picker.get_popup().hide()
	print("PASS: mouse na interface, slider real, órbita sem conflito e popup de cores")
	quit(0)
