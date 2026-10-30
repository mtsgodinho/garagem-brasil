extends Node3D
## Estudo GLB original guiado por referências do Gol G3; ainda não é reprodução fiel.
## Frente em -Z, metros. Substituir este nó por GLB mantendo os grupos de peças.

const Customization = preload("res://scripts/customization/vehicle_customization.gd")
const ProceduralMaterials = preload("res://scripts/rendering/procedural_materials.gd")
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
	body_material = material(Color("b8cbd5"),0.8,0.22)
	glass_material = material(Color(0.08,0.12,0.14,0.20),0.15,0.10)
	glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	tire_material = material(Color("242629"),0.0,0.92)
	drum_material = material(Color("454950"),0.55,0.56)
	wheel_material = material(Color("b7c1cb"),0.8,0.22)
	interior_material = material(Color("303944"),0.0,0.85)
	seat_material = material(Color("394854"),0.0,0.95)
	seat_trim_material = material(Color("222b33"),0.0,0.8)
	ProceduralMaterials.add_grain(tire_material,32,0.18,Vector3(8,3,1))
	ProceduralMaterials.add_grain(seat_material,61,0.16,Vector3(6,6,6))
	var lens := material(Color(0.65,0.73,0.78,0.28),0.05,0.08)
	lens.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	lens.cull_mode = BaseMaterial3D.CULL_DISABLED
	var bindings := {"Paint":body_material,"Glass":glass_material,"InteriorColor":interior_material,"SeatColor":seat_material,"SeatTrim":seat_trim_material,"LampLens":lens}
	var scene: PackedScene = load("res://assets/vehicles/gol_study/gol_study.glb")
	var model := scene.instantiate()
	add_child(model)
	for group in ["Body","Glass","Interior","LeftDoor","RightDoor","Hood","Hatch"]:
		model.get_node(group).reparent(self,false)
	model.queue_free()
	for part in find_children("*","MeshInstance3D",true,false):
		for surface in part.mesh.get_surface_count():
			var source: Material = part.mesh.surface_get_material(surface)
			if source != null and bindings.has(source.resource_name):
				if part.mesh.get_surface_count() == 1:
					part.material_override = bindings[source.resource_name]
				else:
					part.set_surface_override_material(surface,bindings[source.resource_name])
	# Keep the public adapter names independent from Blender's unique-name suffixes.
	for parent_name in ["LeftDoor","RightDoor"]:
		var door := get_node(parent_name)
		for role in ["DoorPanel","DoorGlass"]:
			for child in door.get_children():
				if str(child.name).begins_with(role):
					child.name = role
					break
	hinges = {"left_door":get_node("LeftDoor"),"right_door":get_node("RightDoor"),"hood":get_node("Hood"),"trunk":get_node("Hatch")}
	var bay := Node3D.new()
	bay.name = "EngineBay"
	bay.position = Vector3(0,0.60,-1.33)
	add_child(bay)
	box(bay,"BayFloor",Vector3(1.40,0.04,1.12),Vector3.ZERO,material(Color("161b20")))
	Accessories.engine(self,bay)
	var audio := Node3D.new()
	audio.name = "TrunkAudio"
	audio.position = Vector3(0,0.64,1.25)
	add_child(audio)
	var wheel_root := Node3D.new()
	wheel_root.name = "Wheels"
	add_child(wheel_root)
	for x in [-0.70,0.70]:
		for z in [-1.22,1.23]:
			var wheel := Node3D.new()
			wheel.name = "Wheel_%s_%s" % ["L" if x < 0 else "R","Front" if z < 0 else "Rear"]
			wheel.position = Vector3(x,0.425,z)
			wheel_root.add_child(wheel)
			wheels.append(wheel)
	apply_customization(Customization.new())

func apply_customization(state: Resource) -> void:
	body_material.albedo_color = Color(state.body_color, 1.0)
	body_material.metallic = 0.55 if state.finish == 1 else 0.0
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
	glass_material.albedo_color = Color(tint, lerpf(0.22, 0.99, intensity))
	glass_material.metallic = 0.15
	glass_material.roughness = 0.08
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
