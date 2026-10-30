extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var garage: Node3D = load("res://scenes/garage.tscn").instantiate()
	root.add_child(garage)
	for i in 12:
		await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png("/workspace/.runtime/garage.png")
	if result != OK:
		quit(1)
		return
	print("PASS: captura renderizada em /workspace/.runtime/garage.png")
	quit(0)
