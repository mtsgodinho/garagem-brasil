extends CharacterBody3D
## Modelo cinemático de bicicleta com colisão e gravidade; condução arcade.
const Car = preload("res://scripts/vehicles/placeholder_car.gd")
var customization: Resource
var visual: Node3D
var speed := 0.0
var steering := 0.0
var throttle := 0.0
var controls_enabled := true
var manual_controls := false
var test_accelerate := false
var test_brake := false
var test_turn := 0.0
var test_handbrake := false

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
	reset_vehicle()

func reset_vehicle() -> void:
	position = Vector3(-2.7,0.04,850)
	rotation = Vector3.ZERO
	velocity = Vector3.ZERO
	speed = 0
	steering = 0
	throttle = 0

func _physics_process(delta: float) -> void:
	if not controls_enabled:
		return
	var accel := test_accelerate if manual_controls else Input.is_physical_key_pressed(KEY_W)
	var brake := test_brake if manual_controls else Input.is_physical_key_pressed(KEY_S)
	var turn := test_turn if manual_controls else float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A))
	var handbrake := test_handbrake if manual_controls else Input.is_physical_key_pressed(KEY_SPACE)
	throttle = move_toward(throttle,1.0 if accel else 0.0,delta*2.0)
	if handbrake or (accel and brake): speed = move_toward(speed,0,20*delta)
	elif accel:
		if speed < -0.3: speed = move_toward(speed,0,13*delta)
		else: speed = minf(35.0,speed+maxf(0.25,6.0*(1-speed/36.0))*throttle*delta)
	elif brake:
		if speed > 0.3: speed = move_toward(speed,0,14*delta)
		else: speed = maxf(-8.0,speed-3.5*delta)
	else: speed = move_toward(speed,0,(0.65+0.002*speed*speed)*delta)
	if absf(position.x)>6: speed = move_toward(speed,0,3.0*delta)
	steering = move_toward(steering,turn*deg_to_rad(28)*lerpf(1.0,0.25,clampf(absf(speed)/35.0,0,1)),delta*1.8)
	rotation.y -= speed/2.45*tan(steering)*delta
	var forward := -global_basis.z
	velocity.x = forward.x*speed
	velocity.z = forward.z*speed
	if not is_on_floor(): velocity.y -= 18*delta
	else: velocity.y = -0.1
	move_and_slide()
	if get_slide_collision_count()>0:
		for i in get_slide_collision_count():
			if absf(get_slide_collision(i).get_normal().dot(forward))>0.5:
				speed = velocity.dot(forward)
	for wheel in visual.wheels:
		wheel.rotation.x -= speed/0.32*delta
		wheel.rotation.y = -steering if str(wheel.name).contains("Front") else 0.0
	if position.y < -5: reset_vehicle()
