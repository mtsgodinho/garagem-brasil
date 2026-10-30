extends Node3D

const Car = preload("res://scripts/vehicles/placeholder_car.gd")
const Orbit = preload("res://scripts/camera/orbit_camera.gd")
const Customization = preload("res://scripts/customization/vehicle_customization.gd")
const SaveStore = preload("res://scripts/persistence/customization_store.gd")
const CustomizationPanel = preload("res://scripts/ui/customization_panel.gd")
var customization := Customization.new()
var customization_ui: CanvasLayer
var camera: Camera3D
var persistence_enabled := true
var save_path := "user://garagem/customization.json"
var store: RefCounted
var save_timer: Timer
var dirty := false
var exit_dialog: ConfirmationDialog

func _ready() -> void:
	store = SaveStore.new(save_path)
	if persistence_enabled:
		customization = store.load_customization()
	get_tree().auto_accept_quit = false
	save_timer = Timer.new()
	save_timer.one_shot = true
	save_timer.wait_time = 0.6
	save_timer.timeout.connect(save_now)
	add_child(save_timer)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("172330")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("b2c8df")
	environment.ambient_light_energy = 0.65
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("536e93")
	sky_material.sky_horizon_color = Color("ccd7df")
	sky_material.ground_horizon_color = Color("9ca4ab")
	sky_material.ground_bottom_color = Color("29333d")
	sky.sky_material = sky_material
	sky.radiance_size = Sky.RADIANCE_SIZE_128
	environment.sky = sky
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
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
		light.light_energy = 0.65
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
	camera.h_offset = 0.9
	add_child(camera)
	create_ui()

func create_ui() -> void:
	customization_ui = CustomizationPanel.new()
	customization_ui.name = "CustomizationPanel"
	add_child(customization_ui)
	customization_ui.setup(customization)
	customization_ui.customization_changed.connect(customization_changed)
	customization_ui.restore_camera.connect(camera.reset_view)
	customization_ui.exit_requested.connect(request_exit)
	customization_ui.save_requested.connect(save_now)
	customization_ui.view_requested.connect(camera.focus_detail)
	customization_ui.opening_requested.connect(get_node("VehicleVisual").set_part_open)
	if persistence_enabled:
		customization_ui.set_save_status(store.message,store.load_result in ["invalid","recovered"])
	apply_customization()

func apply_customization() -> void:
	get_node("VehicleVisual").apply_customization(customization)

func customization_changed() -> void:
	apply_customization()
	if persistence_enabled:
		dirty = true
		customization_ui.set_save_status("Alterações pendentes • salvando automaticamente…")
		save_timer.start()

func save_now() -> bool:
	if not persistence_enabled:
		return true
	save_timer.stop()
	var success: bool = store.save_customization(customization)
	if success:
		dirty = false
	customization_ui.set_save_status(store.message,not success)
	return success

func request_exit() -> void:
	if dirty and not save_now():
		if exit_dialog == null:
			exit_dialog = ConfirmationDialog.new()
			exit_dialog.title = "Não foi possível salvar"
			exit_dialog.dialog_text = "As últimas alterações não foram salvas. Deseja sair mesmo assim?"
			exit_dialog.ok_button_text = "Sair sem salvar"
			exit_dialog.cancel_button_text = "Voltar"
			exit_dialog.confirmed.connect(get_tree().quit)
			add_child(exit_dialog)
		exit_dialog.popup_centered()
		return
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and is_node_ready():
		request_exit()
