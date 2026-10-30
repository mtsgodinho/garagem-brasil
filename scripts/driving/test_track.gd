extends Node3D

const Car = preload("res://scripts/vehicles/placeholder_car.gd")
const Driver = preload("res://scripts/driving/vehicle_driver.gd")
signal vitals_changed
signal garage_requested
signal photo_requested
var customization: Resource
var driver: CharacterBody3D
var camera: Camera3D
var hud: CanvasLayer
var speed_label: Label
var condition_label: Label
var message_label: Label
var pause_panel: PanelContainer
var paused := false
var camera_mode := 0
var photo_mode := false
var world: WorldEnvironment

func material(color: String) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(color)
	mat.roughness = 0.9
	return mat

func block(label: String, size: Vector3, at: Vector3, mat: Material, collision: bool = false) -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = label
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.position = at
	mesh.material_override = mat
	add_child(mesh)
	if collision:
		var body := StaticBody3D.new()
		var collider := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = size
		collider.shape = box
		body.position = at
		body.add_child(collider)
		add_child(body)

func instances(mesh: Mesh, mat: Material, transforms: Array[Transform3D]) -> void:
	var node := MultiMeshInstance3D.new()
	node.multimesh = MultiMesh.new()
	node.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	node.multimesh.mesh = mesh
	node.multimesh.instance_count = transforms.size()
	for i in transforms.size(): node.multimesh.set_instance_transform(i,transforms[i])
	node.material_override = mat
	add_child(node)

func _ready() -> void:
	name = "TestTrack"
	world = WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("679acd")
	sky_mat.sky_horizon_color = Color("c9ddea")
	sky_mat.ground_bottom_color = Color("45653c")
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("d9e3ef")
	env.ambient_light_energy = 0.5
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48,-35,0)
	sun.light_energy = 0.9
	sun.shadow_enabled = true
	sun.shadow_opacity = 0.6
	sun.directional_shadow_max_distance = 90
	add_child(sun)
	block("Ground",Vector3(90,1,2400),Vector3(0,-0.51,0),material("547746"),true)
	block("Asphalt",Vector3(12,0.02,2400),Vector3(0,-0.01,0),material("34383c"),true)
	var white := material("e1e1cb")
	for x in [-5.5,5.5]: block("EdgeLine",Vector3(0.12,0.008,2400),Vector3(x,0.005,0),white)
	var marks := BoxMesh.new()
	marks.size = Vector3(0.13,0.009,5)
	var markings: Array[Transform3D] = []
	for z in range(-1180,1190,14): markings.append(Transform3D(Basis(),Vector3(0,0.006,z)))
	instances(marks,material("dec17a"),markings)
	for x in [-13.0,13.0]: block("Guardrail",Vector3(0.18,0.8,2400),Vector3(x,0.4,0),material("89969c"),true)
	for z in [-1198.0,1198.0]: block("EndBarrier",Vector3(26,1.0,0.3),Vector3(0,0.5,z),material("bb7449"),true)
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.16
	trunk.bottom_radius = 0.25
	trunk.height = 2.3
	trunk.radial_segments = 6
	var crown := CylinderMesh.new()
	crown.top_radius = 0.3
	crown.bottom_radius = 2.3
	crown.height = 5.2
	crown.radial_segments = 7
	var trunks: Array[Transform3D] = []
	var crowns: Array[Transform3D] = []
	for side in [-1,1]:
		for i in range(80):
			var at := Vector3(side*(19.0+(i%4)*2.1),1.15,-1160+i*29)
			trunks.append(Transform3D(Basis(),at))
			crowns.append(Transform3D(Basis(),at+Vector3(0,2.7,0)))
	instances(trunk,material("695442"),trunks)
	instances(crown,material("345c38"),crowns)
	var sign := Label3D.new()
	sign.text = "GARAGEM BRASIL\nPISTA DE TESTES • 2,4 km"
	sign.position = Vector3(-8,2.7,842)
	sign.rotation.y = 0
	sign.font_size = 48
	sign.pixel_size = 0.007
	add_child(sign)
	driver = Driver.new()
	driver.customization = customization
	add_child(driver)
	driver.vitals_changed.connect(func() -> void: vitals_changed.emit())
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 62
	add_child(camera)
	build_ui()
	update_camera(1.0)

func build_ui() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(root)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	root.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",18)
	panel.add_child(row)
	var title := Label.new()
	title.text = "  GARAGEM BRASIL / PISTA DE TESTES"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	for spec in [["Voltar à garagem",func() -> void: garage_requested.emit()],["Modo foto (P)",func() -> void: photo_requested.emit()],["Reposicionar (R)",func() -> void: driver.reset_vehicle()],["Reparar (parado)",repair]]:
		var button := Button.new()
		button.text = spec[0]
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(spec[1])
		row.add_child(button)
	var info := Label.new()
	info.text = "W: acelerar • S: frear/ré • A/D: virar • Espaço: freio de mão\nSHIFT: nitro • C: câmera • ESC: menu • P: foto • R: reposicionar"
	info.position = Vector2(24,64)
	root.add_child(info)
	message_label = Label.new()
	message_label.position = Vector2(24,125)
	root.add_child(message_label)
	condition_label = Label.new()
	condition_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	condition_label.position = Vector2(24,-45)
	root.add_child(condition_label)
	speed_label = Label.new()
	speed_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	speed_label.position = Vector2(24,-88)
	speed_label.add_theme_font_size_override("font_size",36)
	root.add_child(speed_label)
	pause_panel = PanelContainer.new()
	pause_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pause_panel.position = Vector2(-145,-100)
	pause_panel.custom_minimum_size = Vector2(290,200)
	root.add_child(pause_panel)
	var column := VBoxContainer.new()
	pause_panel.add_child(column)
	var label := Label.new()
	label.text = "PISTA PAUSADA"
	column.add_child(label)
	for spec in [["Continuar",func() -> void: set_paused(false)],["Voltar à garagem",func() -> void: garage_requested.emit()],["Reposicionar carro",func() -> void: driver.reset_vehicle(); set_paused(false)]]:
		var button := Button.new()
		button.text = spec[0]
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(spec[1])
		column.add_child(button)
	pause_panel.hide()

func set_paused(value: bool) -> void:
	paused = value
	driver.controls_enabled = not value and not photo_mode
	pause_panel.visible = value

func _process(delta: float) -> void:
	speed_label.text = "%03d km/h  %s" % [roundi(absf(driver.speed)*3.6),"RÉ" if driver.speed < -0.2 else ""]
	condition_label.text = "Estado: %.0f%% • Nitro: %.0f%%  %s" % [customization.vehicle_health,customization.nitro_charge,"NITRO ATIVO" if driver.nitro_active else ""]
	if customization.vehicle_health <= 0: message_label.text = "Motor avariado. Pare e repare, ou volte à garagem."
	if not photo_mode: update_camera(delta)

func update_camera(delta: float) -> void:
	var at: Vector3 = driver.global_position
	var offset := Vector3(0,2.7,6.6) if camera_mode == 0 else Vector3(0,1.20,-1.05)
	var desired: Vector3 = at+driver.global_basis*offset
	camera.global_position = desired if camera_mode == 1 else camera.global_position.lerp(desired,1.0-exp(-8*delta))
	camera.look_at(at+driver.global_basis*Vector3(0,0.9,-6))

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo or photo_mode: return
	if event.keycode == KEY_ESCAPE: set_paused(not paused)
	elif event.keycode == KEY_C:
		camera_mode = (camera_mode+1)%2
		update_camera(1)
	elif event.keycode == KEY_R: driver.reset_vehicle()
	elif event.keycode == KEY_P: photo_requested.emit()

func repair() -> void:
	if driver.service(): message_label.text = "Veículo reparado e nitro recarregado."
	else: message_label.text = "Pare o carro para reparar."
