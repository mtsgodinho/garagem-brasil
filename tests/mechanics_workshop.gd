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
func frames(n: int) -> void:
	for i in n: await physics_frame
func run() -> void:
	var garage: Node3D = load("res://scenes/garage.tscn").instantiate()
	garage.persistence_enabled = false
	root.add_child(garage)
	await process_frame
	var workshop: Node3D = garage.get_node("Workshop")
	check(workshop.station_names.size() >= 8,"Oficina com estações identificáveis")
	check(workshop.primitive_count>100 and workshop.batch_count<20,"Geometria agrupada em poucos lotes")
	for name in workshop.station_names:
		var marker: Node3D = workshop.get_node(NodePath(name))
		check(Vector2(marker.position.x,marker.position.z).length()>5,"Objetos fora da plataforma central")
	garage.customization.nitro_enabled = true
	garage.enter_track()
	await process_frame
	var driver: CharacterBody3D = garage.track.driver
	driver.manual_controls = true
	driver.test_accelerate = true
	await frames(120)
	var original_speed: float = driver.speed
	driver.reset_vehicle()
	garage.customization.performance_level = 3
	check(is_equal_approx(driver.max_speed(),50),"Preparação competição aumenta limite a 180 km/h")
	await frames(120)
	check(driver.speed > original_speed,"Preparação aumenta aceleração real")
	var before: float = driver.speed
	driver.test_nitro = true
	await frames(30)
	check(driver.nitro_active and driver.speed>before,"Nitro ativo impulsiona carro")
	check(garage.customization.nitro_charge < 100,"Nitro consome carga")
	garage.customization.nitro_charge = 0.1
	await frames(2)
	check(garage.customization.nitro_charge == 0 and not driver.nitro_active,"Nitro esgota e não fica infinito")
	var saved_health: float = garage.customization.vehicle_health
	driver.apply_impact(20)
	check(garage.customization.vehicle_health < saved_health,"Colisão reduz estado")
	check(driver.max_speed()<50,"Dano reduz desempenho")
	check(driver.visual.get_node("Hood/DamageMarks").get_child_count()>0,"Dano deixa marcas visuais")
	check(not driver.service(),"Reparo não ocorre em movimento")
	driver.reset_vehicle()
	check(garage.customization.vehicle_health < 100 and garage.customization.nitro_charge < 100,"Reposicionar não apaga dano nem recarrega nitro")
	driver.test_accelerate = false
	driver.test_nitro = false
	check(driver.service(),"Reparo parado funciona")
	check(garage.customization.vehicle_health == 100 and garage.customization.nitro_charge == 100,"Reparo recupera estado e carga")
	check(driver.visual.get_node("Hood/DamageMarks").get_child_count() == 0,"Reparo remove marcas")
	driver.apply_impact(100)
	await frames(2)
	check(garage.customization.vehicle_health == 0,"Estado tem limite zero")
	driver.test_accelerate = true
	await frames(45)
	check(driver.speed < 0.1,"Motor avariado não acelera")
	driver.test_accelerate = false
	driver.test_brake = true
	await frames(30)
	check(absf(driver.speed) < 0.1,"Motor avariado também não engata ré")
	garage.leave_track()
	await process_frame
	check(garage.get_node("VehicleVisual").get_node("Hood/DamageMarks").get_child_count()>0,"Dano permanece ao retornar à garagem")
	garage.repair_vehicle()
	check(garage.customization.vehicle_health == 100,"Reparo na garagem")
	var store = load("res://scripts/persistence/customization_store.gd").new("/workspace/.runtime/mechanics-%s.json" % Time.get_ticks_usec())
	garage.customization.vehicle_health = 43.0
	garage.customization.nitro_charge = 21.0
	check(store.save_customization(garage.customization),"Grava estado e preparação")
	var loaded: Resource = store.load_customization()
	check(loaded.performance_level == 3 and loaded.nitro_enabled and loaded.vehicle_health == 43 and loaded.nitro_charge == 21,"Recupera mecânica e estado")
	var legacy: Dictionary = store.document(garage.customization)
	legacy.schema_version = 4
	for field in ["performance_level","nitro_enabled","vehicle_health","nitro_charge"]: legacy.erase(field)
	check(store.decode(legacy).vehicle_health == 100,"Save antigo inicia íntegro sem perder personalização")
	await create_timer(0.1).timeout
	if not failed:
		print("PASS: %d verificações de desempenho nitro danos reparo e oficina" % checks)
		quit()
