extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		quit(1)
		assert(condition, message)

func run() -> void:
	var scene := load("res://scenes/garage.tscn") as PackedScene
	check(scene != null, "Cena principal deve carregar")
	var garage := scene.instantiate()
	garage.persistence_enabled = false
	root.add_child(garage)
	await process_frame
	var car := garage.get_node("VehicleVisual")
	check(car.wheels.size() == 4, "Quatro rodas independentes")
	for group in ["Body","Glass","Interior","Wheels"]:
		check(car.has_node(group), "Grupo substituível: " + group)
	check(car.get_node("Body").get_child_count() > 10, "Carroceria e detalhes presentes")
	# Faces das laterais precisam apontar para fora; evita carroceria invisível.
	var shell: MeshInstance3D = car.get_node("Body/Shell")
	var arrays: Array = shell.mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var side_vertices := 0
	for i in vertices.size():
		if absf(normals[i].x) > 0.99:
			side_vertices += 1
			check(vertices[i].x * normals[i].x > 0.0, "Normal lateral aponta para fora")
	check(side_vertices > 6, "As duas laterais possuem faces")
	var camera := garage.get_node("OrbitCamera")
	var start: Vector3 = camera.position
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	camera._unhandled_input(down)
	var motion := InputEventMouseMotion.new()
	motion.relative = Vector2(80,25)
	camera._unhandled_input(motion)
	check(camera.position.distance_to(start) > 0.5, "Arrastar gira câmera")
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	camera._input(up)
	check(not camera.dragging, "Soltar fora da área termina arrasto")
	var scroll := InputEventMouseButton.new()
	scroll.button_index = MOUSE_BUTTON_WHEEL_UP
	scroll.pressed = true
	for i in 100:
		camera._unhandled_input(scroll)
	check(is_equal_approx(camera.distance,3.2), "Zoom limitado")
	camera.yaw += TAU
	camera.update_view()
	check(camera.position.is_finite(), "Órbita completa válida")
	camera.reset_view()
	check(camera.position.distance_to(start) < 0.001, "Restaurar câmera")
	print("PASS: cena, peças, quatro rodas, órbita, arrasto, zoom e restauração")
	quit(0)
