extends Node3D
## Modelo procedural provisório: não é uma reprodução fiel/licenciada do Gol G3.
## Frente em -Z, metros. Substituir este nó por GLB mantendo os grupos de peças.

const Customization = preload("res://scripts/customization/vehicle_customization.gd")
const Accessories = preload("res://scripts/vehicles/accessory_visuals.gd")
const WheelVisual = preload("res://scripts/vehicles/wheel_visual.gd")

var wheel_material := StandardMaterial3D.new()
var tire_material := StandardMaterial3D.new()
var drum_material := StandardMaterial3D.new()
var interior_material := StandardMaterial3D.new()
var seat_material := StandardMaterial3D.new()
var seat_trim_material := StandardMaterial3D.new()
var hinges: Dictionary = {}
var part_open := {"left_door":false,"right_door":false,"hood":false,"trunk":false}
var part_tweens: Dictionary = {}
var current_audio := -1
var current_wheel_model := -1
var current_wheel_inches := -1

var body_material := StandardMaterial3D.new()
var glass_material := StandardMaterial3D.new()
var wheels: Array[Node3D] = []

func material(color: Color, metallic: float = 0.0, roughness: float = 0.5) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.metallic = metallic
	result.roughness = roughness
	return result

func box(parent: Node3D, label: String, size: Vector3, at: Vector3, mat: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = label
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = mat
	node.position = at
	parent.add_child(node)
	return node

# Extrusão de uma silhueta lateral, preservando a separação carroceria/vidros.
func profile(parent: Node3D, label: String, points: Array[Vector2], width: float, mat: Material, open_top: bool = false) -> MeshInstance3D:
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	for side in [-1.0, 1.0]:
		for p in points:
			vertices.append(Vector3(side * width / 2.0, p.y, p.x))
	var count := points.size()
	var face := Geometry2D.triangulate_polygon(PackedVector2Array(points))
	for i in range(0, face.size(), 3):
		indices.append_array(PackedInt32Array([face[i], face[i + 1], face[i + 2]]))
		indices.append_array(PackedInt32Array([face[i + 2] + count, face[i + 1] + count, face[i] + count]))
	for i in count:
		var next := (i + 1) % count
		if open_top and minf(points[i].y,points[next].y) > 0.90 and absf(points[i].x-points[next].x) > 0.10:
			continue
		indices.append_array(PackedInt32Array([i, next, next + count, i, next + count, i + count]))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	for i in range(0, indices.size(), 3):
		for index in [indices[i + 2], indices[i + 1], indices[i]]:
			st.add_vertex(vertices[index])
	st.generate_normals()
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = st.commit()
	node.material_override = mat
	parent.add_child(node)
	return node

func _ready() -> void:
	body_material = material(Color("b8cbd5"), 0.55, 0.28)
	glass_material = material(Color(0.10, 0.19, 0.23, 0.65), 0.35, 0.18)
	glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var black := material(Color("161c24"))
	tire_material = material(Color("121519"), 0.0, 0.92)
	drum_material = material(Color("252a30"), 0.25, 0.7)
	wheel_material = material(Color("b7c1cb"), 0.75, 0.23)
	interior_material = material(Color("303944"),0.0,0.85)
	seat_material = material(Color("394854"),0.0,0.95)
	seat_trim_material = material(Color("222b33"),0.0,0.8)
	var body := Node3D.new()
	body.name = "Body"
	add_child(body)
	# 3,92 m de comprimento, 1,64 m de largura; arcos geométricos deixam as rodas livres.
	profile(body, "Shell", [Vector2(-1.96,0.49), Vector2(-1.96,0.91), Vector2(-1.57,1.00), Vector2(-0.72,1.06), Vector2(-0.66,1.05), Vector2(-0.66,0.57), Vector2(0.49,0.57), Vector2(0.49,1.05), Vector2(1.56,1.05), Vector2(1.96,0.91), Vector2(1.96,0.49), Vector2(1.61,0.49), Vector2(1.56,0.83), Vector2(1.38,0.99), Vector2(1.08,0.99), Vector2(0.88,0.83), Vector2(0.83,0.49), Vector2(-0.82,0.49), Vector2(-0.87,0.83), Vector2(-1.07,0.99), Vector2(-1.37,0.99), Vector2(-1.57,0.83), Vector2(-1.62,0.49)], 1.64, body_material, true)
	var glass := Node3D.new()
	glass.name = "Glass"
	add_child(glass)
	quad(glass,"Windshield",[Vector3(-0.725,1.05,-0.76),Vector3(0.725,1.05,-0.76),Vector3(0.725,1.52,-0.19),Vector3(-0.725,1.52,-0.19)],glass_material)
	for side in [-1.0,1.0]:
		quad(glass,"QuarterWindow",[Vector3(side*0.735,1.05,0.49),Vector3(side*0.735,1.05,1.68),Vector3(side*0.735,1.52,1.12),Vector3(side*0.735,1.52,0.49)],glass_material)
	box(body,"Roof",Vector3(1.46,0.07,1.36),Vector3(0,1.54,0.47),body_material)
	for x in [-0.74,0.74]:
		var front_pillar := box(body,"A_Pillar",Vector3(0.055,0.74,0.065),Vector3(x,1.28,-0.49),body_material)
		front_pillar.rotation.x = 0.88
		var rear_pillar := box(body,"C_Pillar",Vector3(0.07,0.71,0.08),Vector3(x,1.28,1.40),body_material)
		rear_pillar.rotation.x = -0.86
	box(body,"FrontBumper",Vector3(1.69,0.22,0.16),Vector3(0,0.56,-1.95),body_material)
	box(body,"RearBumper",Vector3(1.69,0.22,0.16),Vector3(0,0.56,1.95),body_material)
	box(body,"Grille",Vector3(0.64,0.17,0.025),Vector3(0,0.85,-1.97),black)
	box(body,"LowerGrille",Vector3(0.98,0.09,0.025),Vector3(0,0.54,-2.04),black)
	for x in [-0.57,0.57]:
		box(body,"Headlamp",Vector3(0.43,0.20,0.04),Vector3(x,0.86,-1.98),material(Color("e1ebd4"),0.2,0.18))
		box(body,"Taillamp",Vector3(0.25,0.29,0.04),Vector3(x,0.88,1.98),material(Color("a9262c"),0.15,0.2))
	var interior := Node3D.new()
	interior.name = "Interior"
	add_child(interior)
	box(interior,"CabinFloor",Vector3(1.40,0.045,2.0),Vector3(0,0.60,0.25),interior_material)
	box(interior,"Dashboard",Vector3(1.33,0.13,0.35),Vector3(0,1.02,-0.45),interior_material)
	for x in [-0.36,0.36]:
		box(interior,"SeatCushion",Vector3(0.49,0.12,0.50),Vector3(x,0.77,0.16),seat_material)
		box(interior,"SeatBack",Vector3(0.49,0.49,0.15),Vector3(x,1.02,0.38),seat_material)
		box(interior,"Headrest",Vector3(0.25,0.17,0.12),Vector3(x,1.36,0.38),seat_material)
		for side in [-1.0,1.0]:
			box(interior,"SeatBolster",Vector3(0.07,0.43,0.18),Vector3(x+side*0.22,1.02,0.35),seat_trim_material)
	box(interior,"RearBench",Vector3(1.15,0.34,0.18),Vector3(0,0.94,0.89),seat_material)
	box(interior,"TrunkFloor",Vector3(1.35,0.04,0.88),Vector3(0,0.61,1.39),interior_material)
	for side in [-1.0,1.0]:
		for z in [-1.22,1.23]:
			box(interior,"WheelHousing",Vector3(0.23,0.37,0.62),Vector3(side*0.65,0.69,z),black)
	build_openings(body,interior,black)
	var bay := Node3D.new()
	bay.name = "EngineBay"
	bay.position = Vector3(0,0.65,-1.33)
	add_child(bay)
	box(bay,"BayFloor",Vector3(1.40,0.04,1.12),Vector3(0,0,0),black)
	Accessories.engine(self,bay)
	var audio := Node3D.new()
	audio.name = "TrunkAudio"
	audio.position = Vector3(0,0.64,1.25)
	add_child(audio)
	var wheel_root := Node3D.new()
	wheel_root.name = "Wheels"
	add_child(wheel_root)
	for x in [-0.79,0.79]:
		for z in [-1.22,1.23]:
			var wheel := Node3D.new()
			wheel.name = "Wheel_%s_%s" % ["L" if x < 0 else "R", "Front" if z < 0 else "Rear"]
			wheel.position = Vector3(x,0.45,z)
			wheel_root.add_child(wheel)
			wheels.append(wheel)
	apply_customization(Customization.new())

func apply_customization(state: Resource) -> void:
	body_material.albedo_color = Color(state.body_color, 1.0)
	body_material.metallic = 0.8 if state.finish == 1 else 0.0
	body_material.roughness = lerpf(0.38, 0.08, state.gloss)
	if state.finish == 2:
		body_material.roughness = lerpf(1.0, 0.78, state.gloss)
	body_material.clearcoat_enabled = state.finish != 2
	body_material.clearcoat = 0.6 * state.gloss if state.finish != 2 else 0.0
	body_material.clearcoat_roughness = 0.12
	wheel_material.albedo_color = Color(state.wheel_color, 1.0)
	if current_wheel_model != state.wheel_model or current_wheel_inches != state.wheel_inches:
		for wheel in wheels:
			WheelVisual.build(wheel, state.wheel_model, state.wheel_inches, wheel_material, tire_material, drum_material)
		current_wheel_model = state.wheel_model
		current_wheel_inches = state.wheel_inches
	var intensity: float = 0.0 if state.film == 0 else clampf(state.film_intensity, 0.0, 1.0)
	var tint := Color(0.17, 0.25, 0.29).lerp(Color(0.012, 0.018, 0.024), intensity)
	glass_material.albedo_color = Color(tint, lerpf(0.12, 0.99, intensity))
	glass_material.metallic = 0.15
	glass_material.roughness = 0.12
	if state.film == 5:
		glass_material.albedo_color = Color(0.62, 0.72, 0.80, lerpf(0.3, 0.98, intensity))
		glass_material.metallic = 0.95
		glass_material.roughness = 0.05

	interior_material.albedo_color = Color(state.interior_color,1.0)
	seat_material.albedo_color = Color(state.seat_color,1.0)
	seat_material.roughness = 0.28 if state.upholstery == 1 else 0.94
	seat_trim_material.albedo_color = Color(state.interior_color,1.0) if state.upholstery == 2 else Color(state.seat_color,1.0)
	seat_trim_material.roughness = seat_material.roughness
	get_node("EngineBay/StockIntake").visible = not state.sport_intake
	get_node("EngineBay/SportIntake").visible = state.sport_intake
	get_node("EngineBay/TurboKit").visible = state.turbo_visual
	get_node("EngineBay/StrutBrace").visible = state.strut_brace
	if current_audio != state.audio_setup:
		Accessories.audio(self,get_node("TrunkAudio"),state.audio_setup)
		current_audio = state.audio_setup

func quad(parent: Node3D, label: String, points: Array[Vector3], mat: Material) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	for index in [0,1,2,0,2,3]:
		st.add_vertex(points[index])
	st.generate_normals()
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = st.commit()
	node.material_override = mat
	parent.add_child(node)

func hinge(label: String, at: Vector3, key: String) -> Node3D:
	var node := Node3D.new()
	node.name = label
	node.position = at
	add_child(node)
	hinges[key] = node
	return node

func build_openings(body: Node3D, interior: Node3D, black: Material) -> void:
	for side in [-1.0,1.0]:
		var key := "left_door" if side < 0 else "right_door"
		var door := hinge("LeftDoor" if side < 0 else "RightDoor",Vector3(side*0.82,0.57,-0.66),key)
		box(door,"DoorPanel",Vector3(0.055,0.46,1.13),Vector3(0,0.24,0.57),body_material)
		box(door,"DoorInsert",Vector3(0.02,0.30,0.92),Vector3(-side*0.04,0.23,0.57),interior_material)
		box(door,"DoorHandle",Vector3(0.04,0.045,0.16),Vector3(side*0.04,0.42,0.94),black)
		box(door,"Moulding",Vector3(0.03,0.055,1.1),Vector3(side*0.035,0.14,0.57),black)
		box(door,"Mirror",Vector3(0.20,0.14,0.24),Vector3(side*0.06,0.54,0.08),body_material)
		box(door,"WindowPillar",Vector3(0.055,0.47,0.07),Vector3(-side*0.085,0.72,1.12),black)
		box(door,"WindowFrame",Vector3(0.045,0.04,0.66),Vector3(-side*0.085,0.96,0.80),body_material)
		var front_frame := box(door,"FrontWindowFrame",Vector3(0.04,0.665,0.04),Vector3(-side*0.085,0.715,0.235),body_material)
		front_frame.rotation.x = PI/4.0
		quad(door,"DoorGlass",[Vector3(-side*0.085,0.48,0),Vector3(-side*0.085,0.48,1.12),Vector3(-side*0.085,0.95,1.12),Vector3(-side*0.085,0.95,0.47)],glass_material)
	var hood := hinge("Hood",Vector3(0,1.055,-0.73),"hood")
	profile(hood,"HoodPanel",[Vector2(-1.22,-0.145),Vector2(-1.22,-0.10),Vector2(-0.84,-0.032),Vector2(0,0.025),Vector2(0,-0.020),Vector2(-0.84,-0.075)],1.50,body_material)
	profile(hood,"HoodLiner",[Vector2(-1.12,-0.14),Vector2(-1.12,-0.125),Vector2(-0.84,-0.08),Vector2(-0.08,-0.025),Vector2(-0.08,-0.04),Vector2(-0.84,-0.095)],1.28,black)
	for side in [-1.0,1.0]:
		var wing := box(body,"FenderTop",Vector3(0.14,0.04,1.20),Vector3(side*0.775,0.99,-1.33),body_material)
		wing.rotation.x = -0.117
	var hatch := hinge("Hatch",Vector3(0,1.54,1.12),"trunk")
	for side in [-1.0,1.0]:
		var rail := box(hatch,"HatchFrame",Vector3(0.045,0.73,0.045),Vector3(side*0.715,-0.255,0.28),body_material)
		rail.rotation.x = -0.873
	box(hatch,"HatchTopFrame",Vector3(1.46,0.045,0.045),Vector3(0,-0.02,0),body_material)
	box(hatch,"HatchBottomFrame",Vector3(1.46,0.045,0.045),Vector3(0,-0.49,0.56),body_material)
	quad(hatch,"RearGlass",[Vector3(-0.70,-0.02,0),Vector3(0.70,-0.02,0),Vector3(0.70,-0.49,0.56),Vector3(-0.70,-0.49,0.56)],glass_material)
	var panel := box(hatch,"HatchPanel",Vector3(1.41,0.28,0.055),Vector3(0,-0.62,0.69),body_material)
	panel.rotation.x = -0.64
	box(hatch,"HatchHandle",Vector3(0.22,0.045,0.035),Vector3(0,-0.66,0.77),black)
	# Painel traseiro baixo e soleiras permanecem fixos ao abrir.
	box(body,"RearValance",Vector3(1.40,0.18,0.05),Vector3(0,0.70,1.95),body_material)
	box(interior,"SteeringColumn",Vector3(0.07,0.07,0.17),Vector3(-0.36,1.08,-0.28),black)
	Accessories.cylinder(interior,"SteeringWheel",Vector3(-0.36,1.13,-0.18),0.14,0.03,black,Vector3(PI/2.8,0,0))

func set_part_open(key: String, opened: bool, animate: bool = true) -> void:
	if not hinges.has(key):
		return
	part_open[key] = opened
	if part_tweens.has(key) and part_tweens[key].is_valid():
		part_tweens[key].kill()
	var angles := {"left_door":-70.0,"right_door":70.0,"hood":68.0,"trunk":-78.0}
	var property := "rotation:y" if key.ends_with("door") else "rotation:x"
	var angle := deg_to_rad(float(angles[key])) if opened else 0.0
	if animate:
		var tween := create_tween()
		part_tweens[key] = tween
		tween.tween_property(hinges[key],property,angle,0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	else:
		hinges[key].set_indexed(NodePath(property),angle)
