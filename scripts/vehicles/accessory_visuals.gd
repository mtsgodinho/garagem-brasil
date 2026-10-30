extends RefCounted
## Acessórios procedurais próprios; motor e caixas de som são visuais.

static func cylinder(parent: Node3D, label: String, at: Vector3, radius: float, depth: float, mat: Material, rotation: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = depth
	mesh.radial_segments = 24
	var part := MeshInstance3D.new()
	part.name = label
	part.mesh = mesh
	part.material_override = mat
	part.position = at
	part.rotation = rotation
	parent.add_child(part)
	return part

static func engine(car: Node3D, parent: Node3D) -> void:
	var metal: Material = car.material(Color("858e98"),0.65,0.35)
	var dark: Material = car.material(Color("1b232a"),0.0,0.8)
	var red: Material = car.material(Color("a72b36"),0.15,0.45)
	car.box(parent,"EngineBlock",Vector3(0.64,0.28,0.5),Vector3(0,0.16,0),metal)
	car.box(parent,"ValveCover",Vector3(0.55,0.06,0.43),Vector3(0,0.33,0),dark)
	for z in [-0.15,-0.05,0.05,0.15]:
		car.box(parent,"ValveRib",Vector3(0.5,0.012,0.016),Vector3(0,0.366,z),metal)
		cylinder(parent,"ExhaustRunner",Vector3(0.35,0.16,z),0.03,0.18,metal,Vector3(0,0,PI/2))
	car.box(parent,"Battery",Vector3(0.21,0.18,0.30),Vector3(-0.55,0.16,0.19),dark)
	car.box(parent,"BatteryTerminal",Vector3(0.035,0.03,0.035),Vector3(-0.55,0.26,0.26),red)
	car.box(parent,"Radiator",Vector3(0.85,0.23,0.05),Vector3(0,0.14,-0.47),dark)
	var stock := Node3D.new()
	stock.name = "StockIntake"
	parent.add_child(stock)
	car.box(stock,"AirBox",Vector3(0.22,0.19,0.27),Vector3(-0.5,0.17,-0.21),dark)
	cylinder(stock,"IntakePipe",Vector3(-0.27,0.22,-0.19),0.045,0.32,dark,Vector3(0,0,PI/2))
	var sport := Node3D.new()
	sport.name = "SportIntake"
	parent.add_child(sport)
	cylinder(sport,"PolishedIntake",Vector3(-0.29,0.23,-0.2),0.045,0.35,metal,Vector3(0,0,PI/2))
	cylinder(sport,"SportFilter",Vector3(-0.53,0.23,-0.2),0.075,0.17,red,Vector3(0,0,PI/2))
	var turbo := Node3D.new()
	turbo.name = "TurboKit"
	parent.add_child(turbo)
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.03
	mesh.outer_radius = 0.105
	mesh.rings = 24
	mesh.ring_segments = 10
	var turbine := MeshInstance3D.new()
	turbine.name = "TurboHousing"
	turbine.mesh = mesh
	turbine.material_override = metal
	turbine.position = Vector3(0.49,0.20,-0.12)
	turbo.add_child(turbine)
	cylinder(turbo,"ChargePipe",Vector3(0.5,0.14,-0.30),0.037,0.35,metal,Vector3(PI/2,0,0))
	car.box(turbo,"Intercooler",Vector3(0.65,0.13,0.06),Vector3(0,0.05,-0.43),metal)
	for x in [-0.24,-0.12,0.0,0.12,0.24]:
		car.box(turbo,"IntercoolerFin",Vector3(0.012,0.11,0.012),Vector3(x,0.05,-0.469),dark)
	var brace := Node3D.new()
	brace.name = "StrutBrace"
	parent.add_child(brace)
	car.box(brace,"CrossBar",Vector3(1.20,0.035,0.045),Vector3(0,0.36,0.32),red)
	for x in [-0.58,0.58]:
		cylinder(brace,"Mount",Vector3(x,0.33,0.32),0.08,0.02,metal)

static func audio(car: Node3D, parent: Node3D, setup: int) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
	if setup == 0:
		return
	var cabinet: Material = car.material(Color("222b35"),0.0,0.95)
	var cone: Material = car.material(Color("10151c"),0.0,0.75)
	var rim: Material = car.material(Color("8b98a4"),0.55,0.32)
	var height := 0.55 if setup == 3 else 0.43
	car.box(parent,"SpeakerCabinet",Vector3(1.12,height,0.35),Vector3(0,height/2,0),cabinet)
	var centers: Array[Vector2] = [Vector2(0,0.22)]
	var radius := 0.16
	if setup == 2:
		centers = [Vector2(-0.29,0.22),Vector2(0.29,0.22)]
	if setup == 3:
		radius = 0.11
		centers = [Vector2(-0.30,0.14),Vector2(0.30,0.14),Vector2(-0.30,0.41),Vector2(0.30,0.41)]
	for p in centers:
		cylinder(parent,"SpeakerFrame",Vector3(p.x,p.y,0.185),radius,0.025,rim,Vector3(PI/2,0,0))
		cylinder(parent,"SpeakerCone",Vector3(p.x,p.y,0.203),radius*0.85,0.025,cone,Vector3(PI/2,0,0))
		cylinder(parent,"DustCap",Vector3(p.x,p.y,0.224),radius*0.28,0.015,rim,Vector3(PI/2,0,0))
