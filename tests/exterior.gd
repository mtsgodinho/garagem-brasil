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
func choose(option: OptionButton, value: int) -> void:
	option.select(value)
	option.item_selected.emit(value)
func run() -> void:
	var garage: Node3D = load("res://scenes/garage.tscn").instantiate()
	garage.persistence_enabled = false
	root.add_child(garage)
	await process_frame
	var car: Node3D = garage.get_node("VehicleVisual")
	var ui: CanvasLayer = garage.customization_ui
	for style in 3:
		choose(ui.bumper_option,style)
		check(car.get_node("Body/FrontBumper").visible == (style == 0),"Substitui para-choque original")
		check(car.get_node("Exterior").has_node("FrontCustomBumper") == (style != 0),"Opção de para-choque visível")
		choose(ui.fender_option,style)
		var count := 0
		for child in car.get_node("Exterior").get_children():
			if child.has_meta("fender_extension"):
				count += 1
		check(count == (0 if style == 0 else 4),"Quatro alargadores")
		choose(ui.kit_option,style)
		check(car.get_node("Hatch").has_node("RoofSpoiler") == (style == 2),"Aerofólio montado na tampa móvel")
		await process_frame
	for style in 4:
		choose(ui.sticker_option,style)
		var count := 0
		for child in car.get_node("LeftDoor").get_children():
			if child.has_meta("exterior_decal"): count+=1
		check(count == (1 if style in [1,3] else 0),"Adesivo acompanha porta sem duplicar")
		choose(ui.tail_option,style)
		var lens: MeshInstance3D = car.get_node("Body/TailLampRed")
		check(lens.material_override != null,"Material da sinaleira aplicado")
		await process_frame
	for amount in [0.0,3.0,6.0,0.0]:
		ui.lowering_slider.value = amount
		check(is_equal_approx(car.get_node("Body").position.y,-amount/100.0),"Carroceria desce")
		for wheel in car.wheels:
			check(is_equal_approx(wheel.position.y,0.425),"Rodas permanecem no piso")
		check(is_equal_approx(car.hinges.hood.position.y,1.055-amount/100.0),"Capô acompanha altura")
		check(is_equal_approx(car.get_node("Interior").position.y+car.get_node("Interior/InnerWheelTub").position.y,0),"Caixa de roda mantém proteção sobre o pneu")
	var store = load("res://scripts/persistence/customization_store.gd").new("/workspace/.runtime/exterior-test-%s.json" % Time.get_ticks_usec())
	ui.lowering_slider.value = 6
	choose(ui.sticker_option,2)
	ui.sticker_picker.color_changed.emit(Color("efaf32"))
	choose(ui.wheel_option,9)
	check(store.save_customization(garage.customization),"Grava todas as opções novas")
	var restored: Resource = store.load_customization()
	check(restored.lowering_cm == 6 and restored.wheel_model == 9 and restored.sticker_style == 2,"Recupera opções novas")
	check(restored.sticker_color.is_equal_approx(Color("efaf32")),"Recupera cor do adesivo")
	var legacy: Dictionary = store.document(garage.customization)
	legacy.schema_version = 2
	legacy.wheel_model = 4
	for key in ["bumper_style","fender_style","body_kit","taillight_style","sticker_style","sticker_color","lowering_cm"]: legacy.erase(key)
	var migrated: Resource = store.decode(legacy)
	check(migrated != null and migrated.wheel_model == 4 and migrated.lowering_cm == 0,"Migra save v2 sem perder rodas")
	for field in ["lowering_cm","wheel_model","bumper_style"]:
		var invalid: Dictionary = store.document(garage.customization)
		invalid[field] = 100
		check(store.decode(invalid) == null,"Rejeita valor fora do limite")
	if not failed:
		print("PASS: %d verificações de exterior e suspensão" % checks)
		quit()
