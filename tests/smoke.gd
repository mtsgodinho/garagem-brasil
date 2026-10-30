extends SceneTree

var failed := false

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition and not failed:
		failed = true
		push_error(message)
		quit(1)
		return

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
	# Testar o primeiro encontro do raio com cada para-lama externo. A malha
	# GLB tem espessura: suas faces internas apontam legitimamente para dentro.
	var shell: MeshInstance3D = car.get_node("Body/Shell")
	for side in [-1.0,1.0]:
		var origin := Vector3(side*2.0,0.92,-1.22)
		var closest := INF
		var normal_x := 0.0
		for surface in shell.mesh.get_surface_count():
			var arrays := shell.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			for i in range(0,indices.size(),3):
				var hit: Variant = Geometry3D.ray_intersects_triangle(origin,Vector3(-side,0,0),vertices[indices[i]],vertices[indices[i+1]],vertices[indices[i+2]])
				if hit != null and origin.distance_to(hit) < closest:
					closest = origin.distance_to(hit)
					normal_x = (normals[indices[i]].x+normals[indices[i+1]].x+normals[indices[i+2]].x)/3.0
		check(is_finite(closest),"Raio encontra a lateral do para-lama")
		check(side*normal_x > 0.5,"Face mais próxima do para-lama aponta para fora")
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
	if failed:
		return
	print("PASS: cena, peças, quatro rodas, órbita, arrasto, zoom e restauração")
	quit(1 if failed else 0)
