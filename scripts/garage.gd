extends Node3D

const Car = preload("res://scripts/vehicles/placeholder_car.gd")
const Orbit = preload("res://scripts/camera/orbit_camera.gd")
var camera: Camera3D

func _ready() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("172330")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("b2c8df")
	environment.ambient_light_energy = 0.65
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)
	var helper := Car.new()
	var concrete := helper.material(Color("454f58"),0.0,0.95)
	var wall := helper.material(Color("253340"),0.0,0.9)
	var trim := helper.material(Color("d39d51"),0.35,0.4)
	helper.box(self,"ConcreteFloor",Vector3(24,0.15,24),Vector3(0,-0.10,0),concrete)
	helper.box(self,"BackWall",Vector3(24,5,0.2),Vector3(0,2.4,7),wall)
	helper.box(self,"LeftWall",Vector3(0.2,5,24),Vector3(-8,2.4,0),wall)
	for x in range(-7,9):
		helper.box(self,"FloorJoint",Vector3(0.018,0.005,23),Vector3(x*1.5,-0.02,0),wall)
	for z in range(-7,8):
		helper.box(self,"FloorJoint",Vector3(23,0.005,0.018),Vector3(0,-0.019,z*1.5),wall)
	var platform := MeshInstance3D.new()
	platform.name = "Platform"
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 3.0
	cylinder.bottom_radius = 3.05
	cylinder.height = 0.12
	cylinder.radial_segments = 64
	platform.mesh = cylinder
	platform.position.y = 0.045
	platform.material_override = helper.material(Color("232c35"),0.25,0.7)
	add_child(platform)
	for x in [-5.0,5.0]:
		helper.box(self,"WallColumn",Vector3(0.2,4.8,0.3),Vector3(x,2.3,6.8),trim)
	for z in [3.5,5.8]:
		helper.box(self,"Workbench",Vector3(2,0.1,0.7),Vector3(-6.4,0.95,z),trim)
		helper.box(self,"ToolCabinet",Vector3(1.8,0.85,0.6),Vector3(-6.4,0.47,z),wall)
	for x in [-3.0,0.0,3.0]:
		helper.box(self,"LightFixture",Vector3(0.15,0.08,3),Vector3(x,4.0,0),helper.material(Color("e9edf0")))
		var light := OmniLight3D.new()
		light.position = Vector3(x,3.7,0)
		light.light_color = Color("e1efff")
		light.light_energy = 1.6
		light.omni_range = 9
		add_child(light)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55,-30,0)
	sun.light_energy = 0.8
	sun.shadow_enabled = true
	add_child(sun)
	var sign := Label3D.new()
	sign.text = "GARAGEM / BRASIL"
	sign.position = Vector3(0,3.0,6.85)
	sign.rotation.y = PI
	sign.font_size = 72
	sign.pixel_size = 0.008
	sign.modulate = Color("dfaf66")
	add_child(sign)
	helper.free()
	var car := Car.new()
	car.name = "VehicleVisual"
	add_child(car)
	camera = Orbit.new()
	camera.name = "OrbitCamera"
	camera.current = true
	camera.fov = 48
	camera.near = 0.1
	add_child(camera)
	create_ui()

func create_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	margin.add_theme_constant_override("margin_left",32)
	margin.add_theme_constant_override("margin_top",24)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(margin)
	var heading := Label.new()
	heading.text = "GARAGEM BRASIL\nESTÚDIO 01 / VISUALIZAÇÃO"
	heading.add_theme_font_size_override("font_size",24)
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(heading)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -110
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035,0.05,0.07,0.96)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel",style)
	root.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",24)
	panel.add_child(row)
	var info := Label.new()
	info.text = "GOL G3 • ESTUDO PROVISÓRIO\nModelo geométrico aproximado — não é uma reprodução fiel.\nArraste para girar • Roda do mouse: zoom • R: restaurar câmera"
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_font_size_override("font_size",16)
	row.add_child(info)
	var reset := Button.new()
	reset.text = "Restaurar câmera"
	reset.pressed.connect(camera.reset_view)
	row.add_child(reset)
	var quit := Button.new()
	quit.text = "Sair"
	quit.pressed.connect(get_tree().quit)
	row.add_child(quit)
