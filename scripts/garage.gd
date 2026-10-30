extends Node3D

const ProceduralMaterials = preload("res://scripts/rendering/procedural_materials.gd")
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
var track: Node3D
var photo: Node3D
var studio_environment: Environment

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
	environment.background_color = Color("171c22")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("d5d5d2")
	environment.ambient_light_energy = 0.55
	var sky := Sky.new()
	var sky_material := ShaderMaterial.new()
	sky_material.shader = load("res://shaders/studio_sky.gdshader")
	sky.sky_material = sky_material
	sky.radiance_size = Sky.RADIANCE_SIZE_256
	environment.sky = sky
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	environment.tonemap_mode = Environment.TONE_MAPPER_REINHARDT
	var world := WorldEnvironment.new()
	world.name = "WorldEnvironment"
	world.environment = environment
	add_child(world)
	var helper := Car.new()
	var concrete := helper.material(Color("43484c"),0.0,0.88)
	var wall := helper.material(Color("292f35"),0.0,0.92)
	ProceduralMaterials.add_grain(concrete,42,0.24,Vector3(12,12,12))
	var trim := helper.material(Color("d39d51"),0.35,0.4)
	helper.box(self,"ConcreteFloor",Vector3(24,0.15,24),Vector3(0,-0.10,0),concrete)
	helper.box(self,"BackWall",Vector3(24,5,0.2),Vector3(0,2.4,7),wall)
	helper.box(self,"LeftWall",Vector3(0.2,5,24),Vector3(-8,2.4,0),wall)
	var joint := helper.material(Color("373c40"),0.0,0.96)
	for x in range(-3,4):
		helper.box(self,"FloorJoint",Vector3(0.008,0.002,23),Vector3(x*3.0,-0.021,0),joint)
	for z in range(-3,4):
		helper.box(self,"FloorJoint",Vector3(23,0.002,0.008),Vector3(0,-0.020,z*3.0),joint)
	var platform := MeshInstance3D.new()
	platform.name = "Platform"
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 3.0
	cylinder.bottom_radius = 3.05
	cylinder.height = 0.12
	cylinder.radial_segments = 64
	platform.mesh = cylinder
	platform.position.y = 0.045
	platform.material_override = helper.material(Color("30353a"),0.18,0.65)
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
		light.light_color = Color("f2eeea")
		light.light_energy = 0.22
		light.omni_range = 9
		add_child(light)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55,-30,0)
	sun.light_energy = 0.65
	sun.light_color = Color("fff4e8")
	sun.shadow_blur = 2.0
	sun.shadow_opacity = 0.62
	sun.shadow_enabled = true
	add_child(sun)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-35,145,0)
	fill.light_color = Color("e0e8f0")
	fill.light_energy = 0.22
	fill.shadow_enabled = false
	add_child(fill)
	var sign := Label3D.new()
	sign.text = "GARAGEM / BRASIL"
	sign.position = Vector3(0,2.8,6.85)
	sign.rotation.y = PI
	sign.font_size = 40
	sign.pixel_size = 0.008
	sign.modulate = Color("dfaf66")
	add_child(sign)
	var contact := MeshInstance3D.new()
	contact.name = "ContactShadow"
	var shadow_mesh := QuadMesh.new()
	shadow_mesh.size = Vector2(1.9,4.2)
	contact.mesh = shadow_mesh
	contact.rotation.x = -PI/2.0
	contact.position.y = 0.107
	var shadow_material := ShaderMaterial.new()
	shadow_material.shader = load("res://shaders/contact_shadow.gdshader")
	contact.material_override = shadow_material
	contact.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(contact)
	helper.free()
	var car := Car.new()
	car.name = "VehicleVisual"
	add_child(car)
	camera = Orbit.new()
	camera.name = "OrbitCamera"
	camera.current = true
	camera.fov = 44
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
	customization_ui.drive_requested.connect(enter_track)
	customization_ui.photo_requested.connect(enter_photo)
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

func enter_track() -> void:
	if track != null or photo != null: return
	if dirty and not save_now(): return
	studio_environment = get_node("WorldEnvironment").environment
	get_node("WorldEnvironment").environment = null
	visible = false
	customization_ui.hide()
	camera.set_process_input(false)
	camera.set_process_unhandled_input(false)
	track = load("res://scripts/driving/test_track.gd").new()
	track.customization = customization
	track.garage_requested.connect(leave_track)
	track.photo_requested.connect(enter_photo)
	get_tree().root.add_child(track)

func leave_track() -> void:
	if track == null: return
	track.world.environment = null
	track.driver.controls_enabled = false
	track.queue_free()
	track = null
	get_node("WorldEnvironment").environment = studio_environment
	visible = true
	customization_ui.show()
	camera.set_process_input(true)
	camera.set_process_unhandled_input(true)
	camera.make_current()

func enter_photo() -> void:
	if photo != null: return
	photo = load("res://scripts/photo/photo_mode.gd").new()
	if track != null:
		track.photo_mode = true
		track.driver.controls_enabled = false
		track.hud.hide()
		photo.target = track.driver.global_position
		photo.previous_camera = track.camera
	else:
		customization_ui.hide()
		camera.set_process_input(false)
		camera.set_process_unhandled_input(false)
		photo.target = Vector3.ZERO
		photo.previous_camera = camera
	photo.finished.connect(leave_photo)
	get_tree().root.add_child(photo)

func leave_photo() -> void:
	photo = null
	if track != null:
		track.photo_mode = false
		track.driver.controls_enabled = not track.paused
		track.hud.show()
	else:
		customization_ui.show()
		camera.set_process_input(true)
		camera.set_process_unhandled_input(true)

func _unhandled_key_input(event: InputEvent) -> void:
	if track == null and photo == null and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P:
		get_viewport().set_input_as_handled()
		enter_photo()
