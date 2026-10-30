extends SceneTree

const State = preload("res://scripts/customization/vehicle_customization.gd")
const Car = preload("res://scripts/vehicles/placeholder_car.gd")
var checks := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		push_error(message)
		quit(1)
		assert(condition,message)

func choose(option: OptionButton, index: int) -> void:
	option.select(index)
	option.item_selected.emit(index)

func run() -> void:
	var garage: Node3D = load("res://scenes/garage.tscn").instantiate()
	root.add_child(garage)
	await process_frame
	var ui: CanvasLayer = garage.customization_ui
	var car: Node3D = garage.get_node("VehicleVisual")
	var state: Resource = garage.customization
	check(ui.tabs.get_tab_count() == 3, "Três categorias disponíveis")
	check(ui.wheel_option.item_count == 5, "Cinco desenhos de rodas")
	check(ui.film_option.item_count == 6, "Seis opções de película")
	var original_glass: Color = car.glass_material.albedo_color
	ui.body_picker.color = Color("c23a38")
	ui.body_picker.color_changed.emit(ui.body_picker.color)
	check(car.body_material.albedo_color.is_equal_approx(Color("c23a38")), "Cor aplicada ao material")
	check(car.glass_material.albedo_color == original_glass, "Pintura não muda vidros")
	choose(ui.finish_option,0)
	ui.gloss_slider.value = 0.0
	var low_gloss: float = car.body_material.roughness
	ui.gloss_slider.value = 1.0
	check(car.body_material.roughness < low_gloss, "Mais brilho reduz rugosidade")
	check(is_zero_approx(car.body_material.metallic), "Pintura brilhante não metálica")
	choose(ui.finish_option,1)
	check(car.body_material.metallic > 0.7, "Pintura metálica")
	choose(ui.finish_option,2)
	check(car.body_material.roughness > 0.77 and not car.body_material.clearcoat_enabled, "Acabamento fosco")
	for model in 5:
		choose(ui.wheel_option, model)
		for wheel in car.wheels:
			check(wheel.get_meta("model") == model, "Modelo aplicado nas quatro rodas")
			var spoke_count := 0
			for child in wheel.get_children():
				if child is MeshInstance3D and child.mesh is BoxMesh:
					spoke_count += 1
			check(spoke_count == [10,12,20,20,16][model], "Geometria do desenho de roda")
		await process_frame
	var wheel_child: Node = car.wheels[0].get_child(0)
	ui.wheel_picker.color = Color("c6a253")
	ui.wheel_picker.color_changed.emit(ui.wheel_picker.color)
	check(car.wheel_material.albedo_color.is_equal_approx(Color("c6a253")), "Cor das rodas aplicada")
	check(car.wheels[0].get_child(0) == wheel_child, "Trocar cor não recria malhas")
	for inches in range(13,18):
		ui.size_slider.value = inches
		for wheel in car.wheels:
			check(wheel.get_meta("inches") == inches, "Tamanho aplicado a todas as rodas")
			check(is_equal_approx(wheel.get_meta("rim_radius"),inches * 0.0254 / 2.0), "Escala do aro em metros")
			var tire: MeshInstance3D = wheel.get_node("Tire")
			check(is_equal_approx(tire.mesh.top_radius,0.32), "Diâmetro externo do pneu preservado")
		await process_frame
	var previous_alpha := 0.0
	for film in range(5):
		choose(ui.film_option,film)
		check(state.film == film, "Tipo de película atualizado")
		check(is_equal_approx(ui.film_slider.value,state.film_intensity), "Slider sincronizado com preset")
		check(car.glass_material.albedo_color.a > previous_alpha, "Presets progressivamente mais escuros")
		previous_alpha = car.glass_material.albedo_color.a
	choose(ui.film_option,5)
	check(car.glass_material.metallic > 0.9, "Película espelhada reflexiva")
	ui.film_slider.value = 0.15
	var light_alpha: float = car.glass_material.albedo_color.a
	ui.film_slider.value = 0.9
	check(car.glass_material.albedo_color.a > light_alpha, "Intensidade altera transparência")
	choose(ui.film_option,0)
	check(not ui.film_slider.editable and is_zero_approx(state.film_intensity), "Sem película desabilita intensidade")
	var other := Car.new()
	root.add_child(other)
	var original_color: Color = other.body_material.albedo_color
	ui.body_picker.color_changed.emit(Color("2a55bb"))
	check(other.body_material.albedo_color == original_color, "Materiais independentes entre veículos")
	check(other.body_material != car.body_material, "Materiais próprios por instância")
	other.queue_free()
	await process_frame
	print("PASS: %d verificações de personalização pela interface" % checks)
	quit(0)
