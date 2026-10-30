extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var garage: Node3D = load("res://scenes/garage.tscn").instantiate()
	root.add_child(garage)
	for i in 12:
		await process_frame
	await RenderingServer.frame_post_draw
	var path := "/workspace/.runtime/garage-%s.png" % str(Time.get_unix_time_from_system()).replace(".", "-")
	var result := root.get_texture().get_image().save_png(path)
	if result != OK:
		quit(1)
		return
	print("PASS: captura renderizada em " + path)
	quit(0)
