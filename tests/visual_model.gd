extends SceneTree

var failed := false
var checks := 0
func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition and not failed:
		failed = true
		push_error(message)
		quit(1)

func run() -> void:
	var garage: Node3D = load("res://scenes/garage.tscn").instantiate()
	garage.persistence_enabled = false
	root.add_child(garage)
	await process_frame
	var car: Node3D = garage.get_node("VehicleVisual")
	check(FileAccess.file_exists("res://assets/vehicles/gol_study/gol_study.glb"),"GLB de execução presente")
	for role in ["Body/Shell","Body/Roof","Body/FrontBumper","Body/RearBumper","Glass/Windshield","LeftDoor/DoorPanel","RightDoor/DoorPanel","Hood/HoodPanel","Hatch/HatchPanel"]:
		check(car.has_node(role),"Peça substituível: " + role)
	var triangles := 0
	for node in car.find_children("*","MeshInstance3D",true,false):
		for surface in node.mesh.get_surface_count():
			var arrays: Array = node.mesh.surface_get_arrays(surface)
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			triangles += (indices.size() if not indices.is_empty() else vertices.size())/3
			for vertex in vertices:
				if not vertex.is_finite():
					check(false,"Sem coordenadas inválidas")
	check(triangles < 120000,"Orçamento de até 120 mil triângulos com rodas e acessórios")
	var shell: MeshInstance3D = car.get_node("Body/Shell")
	check(shell.get_aabb().size.x > 1.6 and shell.get_aabb().size.x < 1.75,"Largura de carroceria em metros")
	check(is_equal_approx(shell.get_aabb().size.z,3.92),"Comprimento da estrutura preservado")
	for wheel in car.wheels:
		var tire: MeshInstance3D = wheel.get_node("Tire")
		check(is_equal_approx(wheel.position.y-tire.get_aabb().size.y/2.0,0.105),"Pneus tocam o topo da plataforma")
	check(garage.get_node("WorldEnvironment").environment.sky.sky_material is ShaderMaterial,"Reflexos de estúdio ativos")
	if failed:
		return
	print("PASS: %d verificações da malha GLB, %d triângulos com rodas e acessórios" % [checks,triangles])
	quit(0)
