extends SceneTree
var failed := false
var checks := 0
func _initialize() -> void: call_deferred("run")
func check(condition: bool, message: String) -> void:
	checks+=1
	if not condition and not failed:
		failed = true
		push_error(message)
		quit(1)
func frames(count: int) -> void:
	for i in count: await physics_frame
func run() -> void:
	var garage: Node3D = load("res://scenes/garage.tscn").instantiate()
	garage.persistence_enabled = false
	root.add_child(garage)
	garage.customization.body_color = Color("cc2345")
	garage.customization.wheel_model = 9
	garage.customization.lowering_cm = 6
	garage.apply_customization()
	garage.enter_track()
	await process_frame
	var track: Node3D = garage.track
	var driver: CharacterBody3D = track.driver
	driver.manual_controls = true
	check(not garage.visible and not garage.customization_ui.visible,"Garagem oculta ao entrar na pista")
	check(driver.visual.body_material.albedo_color.is_equal_approx(Color("cc2345")),"Pintura preservada")
	check(driver.visual.wheels[0].get_meta("model") == 9,"Rodas preservadas")
	check(driver.customization.lowering_cm == 6,"Rebaixamento preservado")
	await frames(15)
	var start: Vector3 = driver.position
	driver.test_accelerate = true
	await frames(120)
	check(driver.speed>4 and driver.position.z<start.z-3,"Acelera e anda para frente")
	check(driver.position.y > -0.05 and driver.position.y < 0.1,"Contato com piso sem afundar")
	track.camera_mode = 1
	track.update_camera(1.0/60.0)
	check(track.camera.global_position.distance_to(driver.global_position+driver.global_basis*Vector3(0,1.20,-1.05))<0.001,"Câmera de capô sem atraso que atravesse o interior")
	var speed: float = driver.speed
	driver.test_accelerate = false
	driver.test_handbrake = true
	await frames(45)
	check(absf(driver.speed)<speed,"Freio de mão desacelera")
	driver.test_handbrake = false
	driver.test_brake = true
	await frames(90)
	check(driver.speed<0,"S dá ré após frear")
	driver.reset_vehicle()
	driver.test_brake = false
	driver.test_accelerate = true
	driver.test_turn = 1
	await frames(90)
	check(driver.rotation.y < -0.01,"D vira para a direita")
	driver.reset_vehicle()
	driver.test_accelerate = false
	driver.test_turn = 0
	driver.position = Vector3(-2.7,0.02,-1194)
	driver.speed = 15
	await frames(45)
	check(driver.position.z > -1197 and absf(driver.speed)<0.5,"Barreira impede atravessar fim da pista")
	track.set_paused(true)
	var paused_at: Vector3 = driver.position
	await frames(10)
	check(driver.position.is_equal_approx(paused_at),"Menu pausa movimento")
	track.set_paused(false)
	garage.enter_photo()
	await process_frame
	check(not driver.controls_enabled and not track.hud.visible,"Modo foto congela carro e oculta HUD")
	garage.photo.close()
	await process_frame
	check(driver.controls_enabled and track.hud.visible,"Sair da foto retoma pista")
	garage.leave_track()
	await process_frame
	check(garage.visible and garage.customization_ui.visible,"Volta à garagem")
	check(garage.get_world_3d().environment == garage.get_node("WorldEnvironment").environment,"Iluminação da garagem restaurada")
	garage.enter_track()
	await process_frame
	check(garage.track != null,"Pode entrar na pista novamente")
	garage.leave_track()
	await process_frame
	check(garage.customization.body_color.is_equal_approx(Color("cc2345")),"Volta com escolhas preservadas")
	await create_timer(0.05).timeout
	if not failed:
		print("PASS: %d verificações de direção, pausa, foto e retorno" % checks)
		quit()
