extends Node3D
## Oficina estática própria. Agrupamento por material reduz chamadas de desenho.
var materials: Dictionary = {}
var station_names: Array[String] = []
var primitive_count := 0
var batch_count := 0

func mat(key: String, color: String, metallic: float = 0, roughness: float = 0.6) -> Material:
	if materials.has(key): return materials[key]
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color)
	material.metallic = metallic
	material.roughness = roughness
	materials[key] = material
	return material

func part(label: String, mesh: Mesh, at: Vector3, material: Material, rotation: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position = at
	node.rotation = rotation
	node.material_override = material
	add_child(node)
	primitive_count += 1
	return node

func box(label: String, size: Vector3, at: Vector3, material: Material) -> void:
	var shape := BoxMesh.new()
	shape.size = size
	part(label,shape,at,material)

func cylinder(label: String, radius: float, height: float, at: Vector3, material: Material, rotation: Vector3 = Vector3.ZERO) -> void:
	var shape := CylinderMesh.new()
	shape.top_radius = radius
	shape.bottom_radius = radius
	shape.height = height
	shape.radial_segments = 16
	part(label,shape,at,material,rotation)

func station(label: String, at: Vector3) -> void:
	station_names.append(label)
	var marker := Marker3D.new()
	marker.name = label
	marker.position = at
	add_child(marker)

func sign_text(text: String, at: Vector3, size: int = 40) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = at
	label.rotation.y = PI
	label.font_size = size
	label.pixel_size = 0.007
	label.modulate = Color("e1b773")
	add_child(label)

func _ready() -> void:
	name = "Workshop"
	var metal := mat("metal","71808b",0.65,0.4)
	var dark := mat("dark","20282e",0.2,0.7)
	var blue := mat("blue","245674",0.35,0.45)
	var red := mat("red","a23635",0.3,0.5)
	var wood := mat("wood","866348",0,0.85)
	var rubber := mat("rubber","161a1e",0,0.95)
	var white := mat("white","d1d1c6",0,0.65)
	var yellow := mat("yellow","cc9d42",0.1,0.7)
	station("Workbench",Vector3(-4,0,6.3))
	box("BenchTop",Vector3(3.2,0.10,0.85),Vector3(-4,1.0,6.3),wood)
	for x in [-5.35,-2.65]: box("BenchLeg",Vector3(0.09,0.95,0.65),Vector3(x,0.48,6.3),metal)
	box("LowerShelf",Vector3(3.0,0.06,0.7),Vector3(-4,0.32,6.3),dark)
	box("ToolBoard",Vector3(3.1,1.10,0.06),Vector3(-4,2.02,6.84),dark)
	for i in 8:
		var x := -5.3+i*0.35
		box("Spanner",Vector3(0.032,0.32,0.024),Vector3(x,2.05,6.79),metal)
		var ring := TorusMesh.new()
		ring.inner_radius = 0.024
		ring.outer_radius = 0.043
		ring.rings = 12
		ring.ring_segments = 6
		part("SpannerHead",ring,Vector3(x,2.22,6.79),metal,Vector3(PI/2,0,0))
	for i in 4:
		box("ScrewdriverHandle",Vector3(0.045,0.13,0.035),Vector3(-5.1+i*.35,1.70,6.79),red)
		box("Screwdriver",Vector3(0.015,0.16,0.015),Vector3(-5.1+i*.35,1.83,6.79),metal)
	box("Vice",Vector3(0.25,0.16,0.20),Vector3(-2.9,1.13,6.25),blue)
	box("ViceJaw",Vector3(0.32,0.09,0.08),Vector3(-2.9,1.25,6.25),metal)
	cylinder("ViceHandle",0.012,0.30,Vector3(-2.9,1.10,6.10),metal,Vector3(0,0,PI/2))
	station("ToolCabinets",Vector3(4,0,6.45))
	for x in [3.0,4.2,5.4]:
		box("Cabinet",Vector3(1.05,1.0,0.70),Vector3(x,0.50,6.45),blue)
		box("CabinetTop",Vector3(1.1,0.07,0.76),Vector3(x,1.02,6.45),metal)
		for j in 5:
			box("Drawer",Vector3(0.95,0.15,0.025),Vector3(x,0.17+j*0.18,6.085),dark)
			box("DrawerHandle",Vector3(0.30,0.022,0.035),Vector3(x,0.21+j*0.18,6.055),metal)
	station("StorageShelves",Vector3(-6.8,0,2.8))
	for z in [1.5,4.0]:
		for x in [-7.2,-6.45]: box("ShelfPost",Vector3(0.05,2.7,0.05),Vector3(x,1.35,z),metal)
	for y in [0.18,0.95,1.72,2.49]:
		box("Shelf",Vector3(0.82,0.045,2.6),Vector3(-6.8,y,2.75),metal)
		for j in 3:
			box("PartsBox",Vector3(0.60,0.38,0.56),Vector3(-6.8,y+0.21,1.85+j*.78),wood)
			box("BoxLabel",Vector3(0.008,0.10,0.22),Vector3(-6.49,y+0.25,1.85+j*.78),white)
	station("TyreRack",Vector3(6.8,0,3.6))
	for z in [2.7,3.5,4.3]:
		for j in 3:
			var tire := TorusMesh.new()
			tire.inner_radius = 0.19
			tire.outer_radius = 0.34
			tire.rings = 24
			tire.ring_segments = 10
			var tire_node := part("StoredTyre",tire,Vector3(6.85,0.13+j*0.24,z),rubber)
			tire_node.scale.y = 1.4
	station("Compressor",Vector3(6.9,0,-1.5))
	cylinder("AirTank",0.28,1.0,Vector3(6.9,0.40,-1.5),red,Vector3(PI/2,0,0))
	box("CompressorMotor",Vector3(0.30,0.25,0.4),Vector3(6.9,0.78,-1.5),dark)
	for z in [-1.85,-1.15]: cylinder("CompressorWheel",0.12,0.06,Vector3(7.13,0.12,z),rubber,Vector3(0,0,PI/2))
	for i in 16:
		var angle := TAU*i/16.0
		box("AirHose",Vector3(0.04,0.025,0.14),Vector3(6.55+cos(angle)*0.25,0.025,-1.5+sin(angle)*0.25),yellow)
	station("ToolCart",Vector3(-4.2,0,-5.9))
	box("RollingCart",Vector3(1.1,0.65,0.55),Vector3(-4.2,0.55,-5.9),red)
	box("CartTop",Vector3(1.16,0.05,0.62),Vector3(-4.2,0.90,-5.9),dark)
	for j in 3:
		box("CartDrawer",Vector3(1.0,0.16,0.025),Vector3(-4.2,0.35+j*.19,-5.61),dark)
		box("CartHandle",Vector3(.35,.02,.035),Vector3(-4.2,0.40+j*.19,-5.58),metal)
	for x in [-4.65,-3.75]:
		for z in [-6.1,-5.7]: cylinder("Caster",0.09,0.05,Vector3(x,.12,z),rubber,Vector3(0,0,PI/2))
	station("Desk",Vector3(6.8,0,-5.0))
	box("DeskTop",Vector3(1.2,.08,1.8),Vector3(6.8,.82,-5),wood)
	for z in [-5.7,-4.3]: box("DeskSupport",Vector3(.9,.8,.08),Vector3(6.8,.4,z),dark)
	box("Monitor",Vector3(.08,.43,.65),Vector3(6.8,1.16,-5.1),dark)
	box("Screen",Vector3(.012,.34,.54),Vector3(6.748,1.16,-5.1),blue)
	box("Keyboard",Vector3(.25,.025,.48),Vector3(6.43,.88,-5.1),dark)
	box("ChairSeat",Vector3(.5,.07,.5),Vector3(5.95,.50,-5.0),dark)
	box("ChairBack",Vector3(.08,.55,.5),Vector3(5.72,.78,-5.0),dark)
	for x in [5.75,6.15]:
		for z in [-5.2,-4.8]: box("ChairLeg",Vector3(.05,.48,.05),Vector3(x,.24,z),metal)
	station("ServiceArea",Vector3(-6.7,0,-2.7))
	for x in [-7.0,-6.6]:
		cylinder("OilDrum",.21,.72,Vector3(x,.36,-2.5),blue)
		cylinder("DrumRim",.22,.035,Vector3(x,.72,-2.5),metal)
	box("FloorJack",Vector3(.30,.11,.75),Vector3(-6.6,.11,-3.4),red)
	box("JackArm",Vector3(.055,.80,.055),Vector3(-6.6,.51,-3.7),metal)
	station("SafetyStation",Vector3(-7.5,0,5.2))
	cylinder("Extinguisher",.12,.46,Vector3(-7.5,1.0,5.2),red)
	box("ExtinguisherHandle",Vector3(.20,.045,.07),Vector3(-7.5,1.29,5.2),dark)
	box("RightWall",Vector3(.18,4.8,14),Vector3(8.0,2.3,0),mat("wall","292f35",0,.92))
	box("ServiceDoor",Vector3(2.2,2.6,.035),Vector3(0,1.3,6.87),dark)
	for y in [0.3,0.6,0.9,1.2,1.5,1.8,2.1,2.4]: box("DoorSlat",Vector3(2.1,.025,.012),Vector3(0,y,6.84),metal)
	box("DoorHandle",Vector3(.35,.06,.04),Vector3(0,1.0,6.81),yellow)
	sign_text("FERRAMENTAS",Vector3(-4,2.95,6.8),32)
	sign_text("PEÇAS / SERVIÇO",Vector3(4.1,2.35,6.8),32)
	bake_meshes()

func bake_meshes() -> void:
	var groups := {}
	for node in get_children():
		if not node is MeshInstance3D: continue
		var id: int = node.material_override.get_instance_id()
		if not groups.has(id):
			var surface := SurfaceTool.new()
			surface.begin(Mesh.PRIMITIVE_TRIANGLES)
			groups[id] = {"surface":surface,"material":node.material_override}
		groups[id].surface.append_from(node.mesh,0,node.transform)
		remove_child(node)
		node.queue_free()
	for id in groups:
		var node := MeshInstance3D.new()
		node.name = "WorkshopBatch%d" % batch_count
		node.mesh = groups[id].surface.commit()
		node.material_override = groups[id].material
		add_child(node)
		batch_count += 1
