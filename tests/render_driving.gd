extends SceneTree
var output := "/workspace/.runtime/driving/run-%s" % str(Time.get_unix_time_from_system()).replace(".","-")
var garage: Node3D
func _initialize() -> void: call_deferred("run")
func capture(name: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name+".png")) == OK)
	print("CAPTURE: "+output.path_join(name+".png"))
func run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	garage = load("res://scenes/garage.tscn").instantiate()
	garage.persistence_enabled = false
	root.add_child(garage)
	garage.customization.body_color = Color("a7273e")
	garage.customization.wheel_model = 9
	garage.customization.wheel_inches = 17
	garage.customization.body_kit = 2
	garage.apply_customization()
	await capture("077-garagem-testar-carro")
	garage.enter_track()
	var track: Node3D = garage.track
	track.driver.manual_controls = true
	await capture("078-pista-terceira-pessoa")
	track.driver.test_accelerate = true
	await create_timer(2.5).timeout
	await capture("079-dirigindo-velocimetro")
	track.camera_mode = 1
	track.update_camera(1)
	await capture("080-camera-de-capo")
	track.set_paused(true)
	await capture("081-menu-da-pista")
	track.set_paused(false)
	garage.enter_photo()
	garage.photo.output_dir = output
	await capture("082-modo-foto-pista")
	assert(await garage.photo.capture(),"PNG de foto deve ser salvo")
	var photo_path: String = garage.photo.last_photo
	var loaded := Image.load_from_file(photo_path)
	assert(loaded != null and loaded.get_width()>0 and loaded.get_height()>0,"Foto PNG válida")
	print("PHOTO: "+photo_path)
	garage.photo.close()
	await process_frame
	garage.leave_track()
	await process_frame
	await capture("083-retorno-garagem")
	garage.enter_photo()
	garage.photo.output_dir = output
	assert(await garage.photo.capture(),"Foto também funciona na garagem")
	print("PHOTO: "+garage.photo.last_photo)
	garage.photo.close()
	await process_frame
	assert(garage.customization_ui.visible,"Interface da garagem restaurada")
	print("PASS: capturas de pista e PNGs reais sem interface; retorno preservado")
	quit()
