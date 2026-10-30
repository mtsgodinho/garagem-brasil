extends RefCounted
## Peças próprias, sem marcas/recursos de terceiros. Mantêm o corpo móvel independente.

static func bumper(parent: Node3D, front: bool, touring: bool, paint: Material, low: bool = false, drop: float = 0.0) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var levels := [Vector2(0.36,0.77),Vector2(0.40,0.85),Vector2(0.55,0.86),Vector2(0.72,0.81)]
	if touring:
		levels = [Vector2(0.39,0.79),Vector2(0.43,0.83),Vector2(0.61,0.84),Vector2(0.74,0.81)]
	if low:
		levels[0].x = 0.105+drop
		levels[1].x = 0.15+drop
	var vertices: Array[Vector3] = []
	for level in levels:
		for i in 33:
			var t := float(i)/16.0-1.0
			vertices.append(Vector3(t*level.y,level.x,(-1.99-0.09*(1-t*t)) if front else (1.96+0.06*(1-t*t))))
	for j in 3:
		for i in 32:
			var a := j*33+i
			var indices: Array = [a,a+33,a+34,a,a+34,a+1] if front else [a,a+34,a+33,a,a+1,a+34]
			for index in indices:
				st.add_vertex(vertices[index])
	# Side returns give the bumper real depth instead of a hanging front sheet.
	for side in [-1.0,1.0]:
		for j in 3:
			var y0: float = levels[j].x
			var y1: float = levels[j+1].x
			var x0: float = side*levels[j].y
			var x1: float = side*levels[j+1].y
			var nose := -1.99 if front else 1.96
			var back := -1.64 if front else 1.64
			var quad: Array[Vector3] = [Vector3(x0,y0,nose),Vector3(x1,y1,nose),Vector3(x1,y1,back),Vector3(x0,y0,back)]
			for index in [0,1,2,0,2,3]: st.add_vertex(quad[index])
	st.generate_normals()
	var part := MeshInstance3D.new()
	part.name = "FrontCustomBumper" if front else "RearCustomBumper"
	part.mesh = st.commit()
	part.material_override = paint
	parent.add_child(part)

static func arc(parent: Node3D, side: float, z: float, wide: bool, paint: Material, drop: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var verts: Array[Vector3] = []
	for i in 41:
		var a := 0.24+(PI-0.48)*i/40.0
		for edge in 2:
			var radius := 0.355+edge*(0.060 if wide else 0.028)
			verts.append(Vector3(side*(0.84+(0.045 if wide else 0.015)*(1-edge*.4)),0.425+radius*sin(a)+drop*(1-edge*0.4),z+radius*cos(a)))
	for i in 40:
		for index in [i*2,i*2+1,i*2+3,i*2,i*2+3,i*2+2]:
			st.add_vertex(verts[index])
	st.generate_normals()
	var part := MeshInstance3D.new()
	part.name = "FenderExtension"
	part.set_meta("fender_extension",true)
	part.mesh = st.commit()
	part.material_override = paint
	parent.add_child(part)

static func build(car: Node3D, parent: Node3D, state: Resource, decal: Material) -> void:
	for old in parent.get_children():
		parent.remove_child(old)
		old.queue_free()
	# Decals are real surface meshes, including separate pieces on moving doors/hood.
	for root in [car.get_node("LeftDoor"),car.get_node("RightDoor"),car.get_node("Hood"),car.get_node("Hatch")]:
		for old in root.get_children():
			if old.has_meta("exterior_decal"):
				root.remove_child(old)
				old.queue_free()
	var black: Material = car.material(Color("15191d"),0.05,0.6)
	var paint: Material = car.body_material.duplicate()
	paint.cull_mode = BaseMaterial3D.CULL_DISABLED
	var front: int = state.front_bumper_style if state.front_bumper_style >= 0 else state.bumper_style
	var rear: int = state.rear_bumper_style if state.rear_bumper_style >= 0 else state.bumper_style
	var drop: float = state.lowering_cm/100.0
	if front > 0:
		bumper(parent,true,front == 2,paint,front == 3,drop)
		car.box(parent,"SportIntake",Vector3(0.82,0.16,0.025),Vector3(0,0.53,-2.085),black)
		for x in [-0.59,0.59]:
			car.box(parent,"SideIntake",Vector3(0.20,0.105,0.024),Vector3(x,0.53,-2.065),black)
	if rear > 0:
		bumper(parent,false,rear == 2,paint,rear == 3,drop)
		car.box(parent,"RearDiffuser",Vector3(1.15,0.105,0.035),Vector3(0,0.1575+drop if rear == 3 else 0.425,2.02),black)
	if state.fender_style > 0:
		for side in [-1.0,1.0]:
			for z in [-1.22,1.23]:
				arc(parent,side,z,state.fender_style == 2,paint,state.lowering_cm/100.0)
	var skirt: int = state.side_skirt_style if state.side_skirt_style >= 0 else (1 if state.body_kit > 0 else 0)
	if skirt > 0:
		for side in [-1.0,1.0]:
			var height: float = 0.545-(0.105+drop) if skirt == 2 else 0.085
			var y: float = 0.545-height/2.0 if skirt == 2 else 0.49
			var part: Node3D
			if skirt == 2:
				var bottom := 0.105+drop
				var outline: Array[Vector2] = [Vector2(-0.715,bottom+0.03),Vector2(-0.715,0.545),Vector2(0.795,0.545),Vector2(0.795,bottom+0.03),Vector2(0.72,bottom),Vector2(-0.64,bottom)]
				part = car.profile(parent,"SideSkirt",outline,0.11,paint)
				part.position.x = side*0.79
			else:
				part = car.box(parent,"SideSkirt",Vector3(0.11,height,1.51),Vector3(side*0.79,y,0.04),paint)
			part.set_meta("skirt",true)
	if state.body_kit > 0:
		car.box(parent,"FrontLip",Vector3(1.66,0.035,0.20),Vector3(0,0.1225+drop if front == 3 else (0.375 if front > 0 else 0.435),-1.99),black)
		if state.body_kit == 2:
			for x in [-0.50,0.50]:
				var mount: Node = car.box(car.get_node("Hatch"),"WingMount",Vector3(0.045,0.10,0.10),Vector3(x,0.05,-0.07),black)
				mount.set_meta("exterior_decal",true)
			var wing: Node = car.box(car.get_node("Hatch"),"RoofSpoiler",Vector3(1.48,0.045,0.25),Vector3(0,0.11,-0.03),paint)
			wing.set_meta("exterior_decal",true)
	if state.sticker_style == 1:
		for side in [-1.0,1.0]:
			var door := car.get_node("LeftDoor" if side < 0 else "RightDoor")
			var strip: Node3D = car.box(door,"DoorStripe",Vector3(0.004,0.07,1.10),Vector3(side*0.009,0.28,0.57),decal)
			strip.set_meta("exterior_decal",true)
			car.box(parent,"RearStripe",Vector3(0.005,0.07,0.92),Vector3(side*0.832,0.85,1.0),decal)
	elif state.sticker_style == 2:
		for x in [-0.16,0.16]:
			for roof in [false,true]:
				var st := SurfaceTool.new()
				st.begin(Mesh.PRIMITIVE_TRIANGLES)
				var points: Array[Vector3] = []
				for i in 25:
					var v := float(i)/24.0
					for edge in [-1.0,1.0]:
						var px: float = x+edge*0.05
						if roof:
							points.append(Vector3(px,1.492+0.05*(1-pow(px/(0.674+0.024*sin(v*PI)),2))-0.012*pow(2*v-1,4),-0.22+1.36*v))
						else:
							var z := -1.215+1.215*v
							var dent: float = 0.055*(1-state.vehicle_health/100.0)*exp(-pow((px-0.25)/0.35,2)-pow((z+0.9)/0.3,2))
							points.append(Vector3(px,-0.062+0.065*v+0.023*(1-pow(px/(0.762-0.006*cos(v*PI)),2))*sin(v*PI*0.9)-dent,z))
				for i in 24:
					for index in [i*2,i*2+1,i*2+3,i*2,i*2+3,i*2+2]:
						st.add_vertex(points[index])
				st.generate_normals()
				var stripe := MeshInstance3D.new()
				stripe.name = "RacingStripe"
				stripe.mesh = st.commit()
				stripe.material_override = decal
				stripe.set_meta("exterior_decal",true)
				(parent if roof else car.get_node("Hood")).add_child(stripe)
	elif state.sticker_style == 3:
		for side in [-1.0,1.0]:
			var label := Label3D.new()
			label.text = "06"
			label.font_size = 96
			label.pixel_size = 0.0035
			label.outline_size = 8
			label.modulate = state.sticker_color
			label.position = Vector3(side*0.027,0.25,0.54)
			label.rotation.y = side*PI/2
			label.set_meta("exterior_decal",true)
			car.get_node("LeftDoor" if side < 0 else "RightDoor").add_child(label)
