extends CharacterBody3D
signal vitals_changed
## Modelo cinemático de bicicleta com colisão e gravidade; condução arcade.
const Car = preload("res://scripts/vehicles/placeholder_car.gd")
var customization: Resource
var visual: Node3D
var engine_audio: AudioStreamPlayer
var speed := 0.0
var steering := 0.0
var throttle := 0.0
var controls_enabled := true
var manual_controls := false
var test_accelerate := false
var test_brake := false
var test_turn := 0.0
var test_handbrake := false
var test_nitro := false
var nitro_active := false
var collision_cooldown := 0.0
var flame: MeshInstance3D

func _ready() -> void:
	name = "DrivenVehicle"
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.6,1.38,3.85)
	collision.shape = shape
	collision.position.y = 0.69
	add_child(collision)
	visual = Car.new()
	add_child(visual)
	visual.position.y = -0.105
	visual.apply_customization(customization)
	engine_audio = load("res://scripts/driving/engine_audio.gd").new()
	add_child(engine_audio)
	flame = MeshInstance3D.new()
	var jet := CylinderMesh.new()
	jet.top_radius = 0.01
	jet.bottom_radius = 0.075
	jet.height = 0.6
	jet.radial_segments = 10
	flame.mesh = jet
	flame.rotation.x = PI/2
	flame.position = Vector3(-0.5,0.25,2.18)
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color("48bbfa")
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flame.material_override = glow
	flame.visible = false
	add_child(flame)
	reset_vehicle()

func reset_vehicle() -> void:
	position = Vector3(-2.7,0.04,850)
	rotation = Vector3.ZERO
	velocity = Vector3.ZERO
	speed = 0
	steering = 0
	throttle = 0
	nitro_active = false
	if flame != null: flame.hide()

func _physics_process(delta: float) -> void:
	if not controls_enabled:
		return
	collision_cooldown = maxf(0,collision_cooldown-delta)
	var accel := test_accelerate if manual_controls else Input.is_physical_key_pressed(KEY_W)
	var brake := test_brake if manual_controls else Input.is_physical_key_pressed(KEY_S)
	var turn := test_turn if manual_controls else float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A))
	var handbrake := test_handbrake if manual_controls else Input.is_physical_key_pressed(KEY_SPACE)
	var boost := test_nitro if manual_controls else Input.is_physical_key_pressed(KEY_SHIFT)
	if customization.vehicle_health <= 0: accel = false
	nitro_active = boost and accel and speed > 1 and customization.nitro_enabled and customization.nitro_charge>0 and customization.vehicle_health>0
	if nitro_active:
		customization.nitro_charge = maxf(0,customization.nitro_charge-20*delta)
		vitals_changed.emit()
	flame.visible = nitro_active
	throttle = move_toward(throttle,1.0 if accel else 0.0,delta*2.0)
	if handbrake or (accel and brake): speed = move_toward(speed,0,20*delta)
	elif accel:
		if speed < -0.3: speed = move_toward(speed,0,13*delta)
		else:
			var maximum := max_speed()+(10.0 if nitro_active else 0.0)
			if speed > maximum: speed = move_toward(speed,maximum,delta*2)
			else: speed = minf(maximum,speed+maxf(0.25,(6.0+customization.performance_level*1.3)*(1-speed/(maximum+1.0)))*(0.5+customization.vehicle_health/200.0)*throttle*delta+(6.0*delta if nitro_active else 0.0))
	elif brake:
		if speed > 0.3: speed = move_toward(speed,0,14*delta)
		elif customization.vehicle_health>0: speed = maxf(-8.0,speed-3.5*delta)
		else: speed = move_toward(speed,0,14*delta)
	else: speed = move_toward(speed,0,(0.65+0.002*speed*speed)*delta)
	if absf(position.x)>6: speed = move_toward(speed,0,3.0*delta)
	steering = move_toward(steering,turn*deg_to_rad(28)*lerpf(1.0,0.25,clampf(absf(speed)/35.0,0,1)),delta*1.8)
	rotation.y -= speed/2.45*tan(steering)*delta
	var forward := -global_basis.z
	velocity.x = forward.x*speed
	velocity.z = forward.z*speed
	if not is_on_floor(): velocity.y -= 18*delta
	else: velocity.y = -0.1
	var impact_velocity := velocity
	move_and_slide()
	if get_slide_collision_count()>0:
		for i in get_slide_collision_count():
			var normal := get_slide_collision(i).get_normal()
			var impact := maxf(0,-impact_velocity.dot(normal))
			if absf(normal.y)<0.5 and impact>2 and collision_cooldown == 0:
				apply_impact(impact)
				collision_cooldown = 0.5
			if absf(normal.dot(forward))>0.5:
				speed = velocity.dot(forward)
	for wheel in visual.wheels:
		wheel.rotation.x -= speed/0.32*delta
		wheel.rotation.y = -steering if str(wheel.name).contains("Front") else 0.0
	if position.y < -5: reset_vehicle()

func _process(_delta: float) -> void:
	if engine_audio != null:
		engine_audio.update_engine(customization,speed,throttle,controls_enabled and customization.vehicle_health>0)

func max_speed() -> float:
	return (35.0+5.0*customization.performance_level)*(0.35+0.65*customization.vehicle_health/100.0)

func apply_impact(impact_speed: float) -> void:
	customization.vehicle_health = maxf(0,customization.vehicle_health-maxf(0,impact_speed-2.0)*3.2)
	visual.apply_customization(customization)
	vitals_changed.emit()

func service() -> bool:
	if absf(speed)>0.5: return false
	customization.vehicle_health = 100.0
	customization.nitro_charge = 100.0
	visual.apply_customization(customization)
	vitals_changed.emit()
	return true
