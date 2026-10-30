extends Node3D
## Modelo procedural provisório: não é uma reprodução fiel/licenciada do Gol G3.
## Frente em -Z, metros. Substituir este nó por GLB mantendo os grupos de peças.

const Customization = preload("res://scripts/customization/vehicle_customization.gd")
const WheelVisual = preload("res://scripts/vehicles/wheel_visual.gd")

var wheel_material := StandardMaterial3D.new()
var tire_material := StandardMaterial3D.new()
var drum_material := StandardMaterial3D.new()
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
func profile(parent: Node3D, label: String, points: Array[Vector2], width: float, mat: Material) -> MeshInstance3D:
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
	var body := Node3D.new()
	body.name = "Body"
	add_child(body)
	# 3,92 m de comprimento, 1,64 m de largura; arcos geométricos deixam as rodas livres.
	profile(body, "Shell", [Vector2(-1.96,0.49), Vector2(-1.96,0.91), Vector2(-1.57,1.00), Vector2(-0.72,1.06), Vector2(1.56,1.05), Vector2(1.96,0.91), Vector2(1.96,0.49), Vector2(1.61,0.49), Vector2(1.56,0.83), Vector2(1.38,0.99), Vector2(1.08,0.99), Vector2(0.88,0.83), Vector2(0.83,0.49), Vector2(-0.82,0.49), Vector2(-0.87,0.83), Vector2(-1.07,0.99), Vector2(-1.37,0.99), Vector2(-1.57,0.83), Vector2(-1.62,0.49)], 1.64, body_material)
	var glass := Node3D.new()
	glass.name = "Glass"
	add_child(glass)
	profile(glass, "CabinGlass", [Vector2(-0.76,1.05),Vector2(-0.19,1.52),Vector2(1.13,1.52),Vector2(1.68,1.05)], 1.45, glass_material)
	box(body,"Roof",Vector3(1.46,0.07,1.36),Vector3(0,1.54,0.47),body_material)
	for x in [-0.74,0.74]:
		box(body,"B_Pillar",Vector3(0.055,0.47,0.09),Vector3(x,1.28,0.44),black)
		var front_pillar := box(body,"A_Pillar",Vector3(0.055,0.74,0.065),Vector3(x,1.28,-0.49),body_material)
		front_pillar.rotation.x = 0.88
		var rear_pillar := box(body,"C_Pillar",Vector3(0.07,0.71,0.08),Vector3(x,1.28,1.40),body_material)
		rear_pillar.rotation.x = -0.86
		box(body,"Mirror",Vector3(0.20,0.14,0.24),Vector3(x * 1.19,1.11,-0.58),body_material)
		box(body,"DoorHandle",Vector3(0.035,0.045,0.17),Vector3(x * 1.12,1.0,0.26),black)
		box(body,"SideMoulding",Vector3(0.025,0.055,1.65),Vector3(x * 1.12,0.71,0),black)
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
	box(interior,"Dashboard",Vector3(1.33,0.13,0.35),Vector3(0,1.02,-0.45),black)
	for x in [-0.4,0.4]:
		box(interior,"Seat",Vector3(0.49,0.46,0.19),Vector3(x,1.03,0.35),black)
		box(interior,"Headrest",Vector3(0.25,0.17,0.12),Vector3(x,1.33,0.35),black)
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
