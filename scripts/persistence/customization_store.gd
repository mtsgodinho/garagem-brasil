extends RefCounted
## JSON versionado, substituição por temporário e cópia da versão anterior.
## Arquivos inválidos nunca são apagados: são preservados antes da gravação.

const State = preload("res://scripts/customization/vehicle_customization.gd")
const SCHEMA_VERSION := 3
const VEHICLE_ID := "gol_g3_placeholder"
const MAX_BYTES := 65536

var path: String
var message := ""
var load_result := "new"
var last_error := OK

func _init(file_path: String = "user://garagem/customization.json") -> void:
	path = file_path

func number(value: Variant, minimum: float, maximum: float, integer: bool = false) -> bool:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var n := float(value)
	return is_finite(n) and n >= minimum and n <= maximum and (not integer or n == floorf(n))

func valid_color(value: Variant) -> bool:
	if not value is Array or value.size() != 3:
		return false
	for component in value:
		if not number(component,0,1):
			return false
	return true

func document(state: Resource) -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"vehicle_id": VEHICLE_ID,
		"body_color": [state.body_color.r,state.body_color.g,state.body_color.b],
		"finish": state.finish,
		"gloss": state.gloss,
		"wheel_model": state.wheel_model,
		"wheel_color": [state.wheel_color.r,state.wheel_color.g,state.wheel_color.b],
		"wheel_inches": state.wheel_inches,
		"film": state.film,
		"film_intensity": state.film_intensity,
		"sport_intake": state.sport_intake,
		"turbo_visual": state.turbo_visual,
		"strut_brace": state.strut_brace,
		"audio_setup": state.audio_setup,
		"upholstery": state.upholstery,
		"interior_color": [state.interior_color.r,state.interior_color.g,state.interior_color.b],
		"seat_color": [state.seat_color.r,state.seat_color.g,state.seat_color.b],
		"bumper_style":state.bumper_style,"fender_style":state.fender_style,
		"body_kit":state.body_kit,"taillight_style":state.taillight_style,
		"sticker_style":state.sticker_style,"lowering_cm":state.lowering_cm,
		"sticker_color":[state.sticker_color.r,state.sticker_color.g,state.sticker_color.b],
	}

func decode(data: Variant) -> Resource:
	if not data is Dictionary:
		return null
	if not number(data.get("schema_version"),1,SCHEMA_VERSION,true) or data.get("vehicle_id") != VEHICLE_ID:
		return null
	if not valid_color(data.get("body_color")) or not valid_color(data.get("wheel_color")):
		return null
	for field in [["finish",0,2,true],["gloss",0,1,false],["wheel_model",0,9 if int(data.schema_version) >= 3 else 4,true],["wheel_inches",13,17,true],["film",0,5,true],["film_intensity",0,1,false]]:
		if not number(data.get(field[0]),field[1],field[2],field[3]):
			return null
	if int(data.film) == 0 and not is_zero_approx(float(data.film_intensity)):
		return null
	if int(data.schema_version) >= 2:
		for key in ["sport_intake","turbo_visual","strut_brace"]:
			if typeof(data.get(key)) != TYPE_BOOL:
				return null
		if not number(data.get("audio_setup"),0,3,true) or not number(data.get("upholstery"),0,2,true):
			return null
		if not valid_color(data.get("interior_color")) or not valid_color(data.get("seat_color")):
			return null
	if int(data.schema_version) >= 3:
		for field in [["bumper_style",2],["fender_style",2],["body_kit",2],["taillight_style",3],["sticker_style",3]]:
			if not number(data.get(field[0]),0,field[1],true):
				return null
		if not number(data.get("lowering_cm"),0,6) or not valid_color(data.get("sticker_color")):
			return null
	var state := State.new()
	state.body_color = Color(data.body_color[0],data.body_color[1],data.body_color[2])
	state.wheel_color = Color(data.wheel_color[0],data.wheel_color[1],data.wheel_color[2])
	state.finish = int(data.finish)
	state.gloss = float(data.gloss)
	state.wheel_model = int(data.wheel_model)
	state.wheel_inches = int(data.wheel_inches)
	state.film = int(data.film)
	state.film_intensity = float(data.film_intensity)
	if int(data.schema_version) >= 2:
		state.sport_intake = data.sport_intake
		state.turbo_visual = data.turbo_visual
		state.strut_brace = data.strut_brace
		state.audio_setup = int(data.audio_setup)
		state.upholstery = int(data.upholstery)
		state.interior_color = Color(data.interior_color[0],data.interior_color[1],data.interior_color[2])
		state.seat_color = Color(data.seat_color[0],data.seat_color[1],data.seat_color[2])
	if int(data.schema_version) >= 3:
		for key in ["bumper_style","fender_style","body_kit","taillight_style","sticker_style","lowering_cm"]:
			state.set(key,data[key])
		state.sticker_color = Color(data.sticker_color[0],data.sticker_color[1],data.sticker_color[2])
	return state

func read_state(file_path: String) -> Resource:
	if not FileAccess.file_exists(file_path):
		return null
	var file := FileAccess.open(file_path,FileAccess.READ)
	if file == null:
		return null
	if file.get_length() > MAX_BYTES:
		file.close()
		return null
	var json := JSON.new()
	var result := json.parse(file.get_as_text())
	file.close()
	if result != OK:
		return null
	return decode(json.data)

func load_customization() -> Resource:
	var state := read_state(path)
	if state != null:
		load_result = "loaded"
		message = "Modificações carregadas."
		return state
	state = read_state(path + ".bak")
	if state != null:
		load_result = "recovered"
		message = "Cópia de segurança carregada. Clique em Salvar para recuperar."
		return state
	if FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak"):
		load_result = "invalid"
		message = "Arquivo inválido. Padrões carregados; original preservado ao salvar."
	else:
		load_result = "new"
		message = "Personalize seu carro • salvamento automático ativo"
	return State.new()

func fail(error: int) -> bool:
	last_error = error
	message = "Não foi possível salvar. Verifique espaço e permissão da pasta."
	return false

func preserve(file_path: String) -> int:
	# Timestamp + contador evitam substituir arquivos preservados anteriormente.
	var base := file_path + ".invalid-" + str(int(Time.get_unix_time_from_system()))
	var destination := base + ".json"
	var index := 1
	while FileAccess.file_exists(destination):
		destination = base + "-" + str(index) + ".json"
		index += 1
	return DirAccess.copy_absolute(file_path,destination)

func save_customization(state: Resource) -> bool:
	last_error = OK
	var data := document(state)
	if decode(data) == null:
		return fail(ERR_INVALID_DATA)
	var result := DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if result != OK:
		return fail(result)
	var temp := path + ".tmp"
	var file := FileAccess.open(temp,FileAccess.WRITE)
	if file == null:
		return fail(FileAccess.get_open_error())
	file.store_string(JSON.stringify(data,"\t"))
	file.flush()
	result = file.get_error()
	file.close()
	if result != OK:
		return fail(result)
	if FileAccess.file_exists(path):
		if read_state(path) != null:
			# Só promover um arquivo válido à cópia de segurança.
			if FileAccess.file_exists(path + ".bak") and read_state(path + ".bak") == null:
				result = preserve(path + ".bak")
				if result != OK:
					return fail(result)
			result = DirAccess.copy_absolute(path,path + ".bak.tmp")
			if result == OK:
				result = DirAccess.rename_absolute(path + ".bak.tmp",path + ".bak")
		else:
			result = preserve(path)
		if result != OK:
			return fail(result)
	result = DirAccess.rename_absolute(temp,path)
	if result != OK:
		return fail(result)
	message = "Modificações salvas neste computador."
	return true
