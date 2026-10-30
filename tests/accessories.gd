extends SceneTree

var failed := false

var checks := 0
func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition and not failed:
		failed = true
		push_error(message)
		quit(1)
		return

func run() -> void:
	var garage: Node3D = load("res://scenes/garage.tscn").instantiate()
	garage.persistence_enabled = false
	root.add_child(garage)
	await process_frame
	var ui: CanvasLayer = garage.customization_ui
	var car: Node3D = garage.get_node("VehicleVisual")
	check(ui.tabs.get_tab_count() == 6,"Seis categorias")
	for i in 6:
		ui.category_buttons[i].pressed.emit()
		check(ui.tabs.current_tab == i,"Botão abre categoria")
	for key in ["left_door","right_door","hood","trunk"]:
		check(car.hinges.has(key),"Pivô independente")
		ui.opening_checks[key].button_pressed = true
		check(car.part_open[key],"Controle abre peça")
	await create_timer(0.4).timeout
	var angle_before: float = car.hinges.right_door.rotation.y
	ui.body_picker.color_changed.emit(Color("b54c31"))
	check(is_equal_approx(car.hinges.right_door.rotation.y,angle_before),"Pintura mantém peça aberta")
	check(car.get_node("RightDoor/DoorPanel").material_override == car.body_material,"Pintura compartilhada nas portas")
	check(car.get_node("RightDoor/DoorGlass").material_override == car.glass_material,"Película compartilhada nas portas")
	check(car.get_node("Hatch/RearGlass").material_override == car.glass_material,"Película compartilhada na tampa traseira")
	check(car.hinges.left_door.rotation.y < -1.0,"Porta esquerda abre para fora")
	check(car.hinges.right_door.rotation.y > 1.0,"Porta direita abre para fora")
	check(car.hinges.hood.rotation.x > 1.0,"Capô levanta")
	check(car.hinges.trunk.rotation.x < -1.0,"Tampa traseira levanta")
	for key in car.hinges:
		ui.request_open(key,false)
	await create_timer(0.4).timeout
	for key in car.hinges:
		check(car.hinges[key].rotation.is_equal_approx(Vector3.ZERO),"Peça volta à posição fechada")
	ui.view_requested.emit("trunk")
	check(is_equal_approx(garage.camera.yaw,2.65),"Ver porta-malas enquadra a traseira")
	garage.camera.reset_view()
	check(garage.camera.target.is_equal_approx(Vector3(0,0.86,0)),"Restaurar câmera desfaz enquadramento")
	# Inverter a animação a meio caminho sem acumular tweens.
	car.set_part_open("hood",true)
	await create_timer(0.1).timeout
	car.set_part_open("hood",false)
	await create_timer(0.4).timeout
	check(car.hinges.hood.rotation.is_equal_approx(Vector3.ZERO),"Reversão de animação")
	ui.sport_intake_check.button_pressed = true
	check(car.get_node("EngineBay/SportIntake").visible,"Filtro esportivo visível")
	check(not car.get_node("EngineBay/StockIntake").visible,"Admissão original oculta")
	check(car.part_open.hood,"Modificar motor abre capô")
	ui.turbo_check.button_pressed = true
	check(car.get_node("EngineBay/TurboKit").visible,"Turbo instalado")
	ui.brace_check.button_pressed = true
	check(car.get_node("EngineBay/StrutBrace").visible,"Barra instalada")
	ui.sport_intake_check.button_pressed = false
	check(car.get_node("EngineBay/StockIntake").visible,"Pode voltar à admissão original")
	for setup in 4:
		ui.audio_option.select(setup)
		ui.audio_option.item_selected.emit(setup)
		check(car.part_open.trunk,"Trocar caixa abre porta-malas")
		var speakers := 0
		for child in car.get_node("TrunkAudio").get_children():
			if str(child.name).begins_with("SpeakerCone") or (child is MeshInstance3D and child.material_override.albedo_color.is_equal_approx(Color("10151c"))):
				speakers += 1
		check(speakers == [0,1,2,4][setup],"Quantidade de falantes da montagem")
		await process_frame
	ui.seat_picker.color_changed.emit(Color("ad6044"))
	ui.interior_picker.color_changed.emit(Color("d0ba87"))
	check(car.seat_material.albedo_color.is_equal_approx(Color("ad6044")),"Cor dos bancos")
	check(car.interior_material.albedo_color.is_equal_approx(Color("d0ba87")),"Cor do painel e portas")
	for upholstery in 3:
		ui.upholstery_option.select(upholstery)
		ui.upholstery_option.item_selected.emit(upholstery)
		check(garage.customization.upholstery == upholstery,"Tipo de estofado")
		if upholstery == 1:
			check(car.seat_material.roughness < 0.4,"Couro sintético mais liso")
		if upholstery == 2:
			check(car.seat_trim_material.albedo_color == car.interior_material.albedo_color,"Esportivo bicolor")
	if failed:
		return
	print("PASS: %d verificações de aberturas, motor, caixas de som e interior" % checks)
	quit(1 if failed else 0)
