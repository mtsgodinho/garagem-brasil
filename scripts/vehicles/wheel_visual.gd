extends RefCounted
## Catálogo procedural leve. Diâmetro externo do pneu permanece constante.

static func cylinder(parent: Node3D, label: String, radius: float, depth: float, x: float, mat: Material) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = depth
	mesh.radial_segments = 32
	var part := MeshInstance3D.new()
	part.name = label
	part.mesh = mesh
	part.material_override = mat
	part.rotation.z = PI / 2.0
	part.position.x = x
	parent.add_child(part)

static func ring(parent: Node3D, radius: float, x: float, mat: Material) -> void:
	var mesh := TorusMesh.new()
	mesh.inner_radius = radius - 0.018
	mesh.outer_radius = radius
	mesh.rings = 32
	mesh.ring_segments = 8
	var part := MeshInstance3D.new()
	part.name = "RimLip"
	part.mesh = mesh
	part.material_override = mat
	part.rotation.z = PI / 2.0
	part.position.x = x
	parent.add_child(part)

static func spoke(parent: Node3D, angle: float, radius: float, width: float, x: float, mat: Material) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.018, radius - 0.045, width)
	var part := MeshInstance3D.new()
	part.name = "Spoke"
	part.mesh = mesh
	part.material_override = mat
	part.rotation.x = angle
	var center := (radius + 0.045) / 2.0
	part.position = Vector3(x, cos(angle) * center, sin(angle) * center)
	parent.add_child(part)

static func tire_mesh(parent: Node3D, radius: float, mat: Material) -> void:
	var profile: Array[Vector2] = [Vector2(-0.10,radius-0.005),Vector2(-0.112,radius+0.025),Vector2(-0.111,0.283),Vector2(-0.083,0.314),Vector2(-0.045,0.32),Vector2(0.045,0.32),Vector2(0.083,0.314),Vector2(0.111,0.283),Vector2(0.112,radius+0.025),Vector2(0.10,radius-0.005)]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segments := 64
	for j in profile.size():
		var tangent := (profile[(j+1)%profile.size()]-profile[(j-1+profile.size())%profile.size()]).normalized()
		for i in segments:
			var angle := TAU*float(i)/float(segments)
			st.set_normal(Vector3(-tangent.y,tangent.x*cos(angle),tangent.x*sin(angle)))
			st.set_uv(Vector2(float(i)/segments,float(j)/profile.size()))
			st.add_vertex(Vector3(profile[j].x,profile[j].y*cos(angle),profile[j].y*sin(angle)))
	for j in profile.size():
		for i in segments:
			var a := j*segments+i
			var b := ((j+1)%profile.size())*segments+i
			var c := ((j+1)%profile.size())*segments+(i+1)%segments
			var d := j*segments+(i+1)%segments
			for index in [a,b,c,a,c,d]:
				st.add_index(index)
	var tire := MeshInstance3D.new()
	tire.name = "Tire"
	tire.mesh = st.commit()
	tire.material_override = mat
	parent.add_child(tire)

static func build(parent: Node3D, model: int, inches: int, rim: Material, tire: Material, dark: Material) -> void:
	# Só recriar geometria quando modelo/aro muda; a cor usa material compartilhado.
	for old in parent.get_children():
		parent.remove_child(old)
		old.queue_free()
	var radius := float(inches) * 0.0254 / 2.0
	parent.set_meta("model", model)
	parent.set_meta("inches", inches)
	parent.set_meta("rim_radius", radius)
	tire_mesh(parent,radius,tire)
	parent.set_meta("outer_radius",0.32)
	var groove_material := StandardMaterial3D.new()
	groove_material.albedo_color = Color("15181b")
	groove_material.roughness = 0.98
	for groove_x in [-0.028,0.028]:
		var groove := TorusMesh.new()
		groove.inner_radius = 0.319
		groove.outer_radius = 0.3205
		groove.rings = 64
		groove.ring_segments = 6
		var part := MeshInstance3D.new()
		part.name = "TreadGroove"
		part.mesh = groove
		part.material_override = groove_material
		part.rotation.z = PI/2.0
		part.position.x = groove_x
		parent.add_child(part)
	for side in [-1.0, 1.0]:
		var x: float = side * 0.118
		cylinder(parent, "BrakeDrum", radius - 0.009, 0.012, side * 0.111, dark)
		ring(parent, radius, x, rim)
		var count: int = [5,6,10,5,8][model]
		for i in count:
			var angle := TAU * float(i) / float(count)
			if model == 3:
				spoke(parent, angle - 0.075, radius - 0.008, 0.018, x, rim)
				spoke(parent, angle + 0.075, radius - 0.008, 0.018, x, rim)
			else:
				var width: float = [0.045,0.034,0.022,0.018,0.068][model]
				spoke(parent, angle + (0.20 if model == 2 else 0.0), radius - 0.007, width, x, rim)
		cylinder(parent, "CenterCap", 0.052 if model != 4 else 0.082, 0.020, side * 0.13, rim)
