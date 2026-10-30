extends SceneTree
var output := "/workspace/.runtime/workshop-details/run-%s" % str(Time.get_unix_time_from_system()).replace(".","-")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	var garage: Node3D = load("res://scenes/garage.tscn").instantiate()
	garage.persistence_enabled = false
	root.add_child(garage)
	garage.customization_ui.hide()
	garage.camera.h_offset = 0
	garage.camera.distance = 9.5
	garage.camera.pitch = 0.28
	for spec in [["104-oficina-bancada-e-estantes",0.15],["105-oficina-pneus-e-armarios",-0.85],["106-oficina-mesa-e-compressor",-2.3]]:
		garage.camera.yaw = spec[1]
		garage.camera.update_view()
		for i in 6: await process_frame
		await RenderingServer.frame_post_draw
		var path: String = output.path_join(spec[0]+".png")
		if root.get_texture().get_image().save_png(path) != OK:
			push_error("Falha na captura da oficina")
			quit(1)
			return
		print("CAPTURE: "+path)
	garage.request_exit()
