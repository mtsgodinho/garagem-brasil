extends SceneTree
const AudioEngine = preload("res://scripts/driving/engine_audio.gd")
var failed := false
var checks := 0
func _initialize() -> void: call_deferred("run")
func check(condition: bool, text: String) -> void:
	checks+=1
	if not condition and not failed:
		failed = true
		push_error(text)
		quit(1)
func choose(option: OptionButton, index: int) -> void:
	option.select(index)
	option.item_selected.emit(index)
func run() -> void:
	var garage: Node3D = load("res://scenes/garage.tscn").instantiate()
	garage.persistence_enabled = false
	root.add_child(garage)
	await process_frame
	var ui: CanvasLayer = garage.customization_ui
	var state: Resource = garage.customization
	var car: Node3D = garage.get_node("VehicleVisual")
	for intake in 4:
		choose(ui.intake_option,intake)
		check(state.sport_intake == (intake>0),"Filtro e compatibilidade sincronizados")
		check(car.get_node("EngineBay/StockIntake").visible == (intake == 0),"Filtro original visível")
		check(car.get_node("EngineBay/SportIntake/TwinFilter").visible == (intake == 2),"Duplo fluxo possui segundo filtro")
		check(car.get_node("EngineBay/SportIntake/ColdBox").visible == (intake == 3),"Admissão fria possui caixa")
		state.engine_sound = 0
		state.turbo_visual = false
		check(AudioEngine.selected_profile(state) == [1,3,2,2][intake],"Automático adapta ronco ao filtro")
	state.turbo_visual = true
	check(AudioEngine.selected_profile(state) == 4,"Automático reconhece turbo")
	for profile in range(1,5):
		choose(ui.sound_option,profile)
		check(AudioEngine.selected_profile(state) == profile,"Pode selecionar ronco manual")
	ui.volume_slider.value = 0
	garage.preview_engine = true
	garage._process(0.016)
	check(garage.engine_audio.target_level == 0,"Volume zero silencia prévia")
	ui.volume_slider.value = 0.7
	for height in [0.0,3.0,6.0]:
		ui.lowering_slider.value = height
		choose(ui.front_option,4)
		choose(ui.rear_option,4)
		choose(ui.skirt_option,3)
		for key in ["FrontCustomBumper","RearCustomBumper"]:
			var part: MeshInstance3D = car.get_node("Exterior").get_node(key)
			check(is_equal_approx(part.get_aabb().position.y+car.get_node("Exterior").position.y,0.105),"Para-choque baixo encosta no piso em qualquer altura")
		for part in car.get_node("Exterior").get_children():
			if part.has_meta("skirt"):
				check(is_equal_approx(part.get_aabb().position.y+part.position.y+car.get_node("Exterior").position.y,0.105),"Saia baixa encosta no piso")
	choose(ui.front_option,1)
	check(car.get_node("Body/FrontBumper").visible and not car.get_node("Body/RearBumper").visible,"Dianteiro e traseiro independentes")
	var store = load("res://scripts/persistence/customization_store.gd").new("/workspace/.runtime/sound-low-%s.json" % Time.get_ticks_usec())
	check(store.save_customization(state),"Grava escolhas novas")
	var restored: Resource = store.load_customization()
	check(restored.intake_style == 3 and restored.engine_sound == 4 and is_equal_approx(restored.engine_volume,0.7),"Recupera filtro ronco volume")
	check(restored.front_bumper_style == 0 and restored.rear_bumper_style == 3 and restored.side_skirt_style == 2,"Recupera peças independentes")
	var legacy: Dictionary = store.document(state)
	legacy.schema_version = 3
	for key in ["intake_style","engine_sound","engine_volume","front_bumper_style","rear_bumper_style","side_skirt_style"]: legacy.erase(key)
	check(store.decode(legacy).intake_style == 1,"Migra antigo filtro esportivo sem perder montagem")
	var directory := "/workspace/.runtime/audio-tests/run-%s" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(directory)
	var fingerprints: Array[float] = []
	for profile in range(1,5):
		var synth := AudioEngine.new()
		synth.rpm = 3200
		synth.level = 0.7
		synth.profile = profile
		synth.noise.seed = 64821
		var bytes := PackedByteArray()
		bytes.resize(32000)
		var energy := 0.0
		var fingerprint := 0.0
		var valid := true
		for i in 16000:
			var value: float = synth.sample()
			valid = valid and is_finite(value) and absf(value)<=0.9
			energy += value*value
			fingerprint += value*float(i%71)
			bytes.encode_s16(i*2,roundi(value*32767))
		check(valid and energy>10,"Ronco com amostras finitas e energia audível")
		check(not fingerprints.has(fingerprint),"Perfis produzem ondas diferentes")
		fingerprints.append(fingerprint)
		var wave := AudioStreamWAV.new()
		wave.format = AudioStreamWAV.FORMAT_16_BITS
		wave.mix_rate = 16000
		wave.data = bytes
		check(wave.save_to_wav(directory+"/ronco-%d.wav" % profile) == OK,"Exporta WAV de teste")
		synth.free()
	print("WAV_TESTS: "+directory)
	garage.preview_engine = false
	garage.engine_audio.stop_sound()
	await create_timer(0.05).timeout
	if not failed:
		print("PASS: %d verificações de filtros roncos e peças baixas" % checks)
		quit()
