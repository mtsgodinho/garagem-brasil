extends SceneTree

const Store = preload("res://scripts/persistence/customization_store.gd")
const State = preload("res://scripts/customization/vehicle_customization.gd")
var checks := 0
var base := "/workspace/.runtime/save-tests/unit-%s" % str(Time.get_unix_time_from_system()).replace(".","-")

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		push_error(message)
		quit(1)
		assert(condition,message)

func raw(path: String, contents: String) -> void:
	var file := FileAccess.open(path,FileAccess.WRITE)
	check(file != null,"Abrir fixture isolada")
	file.store_string(contents)
	file.close()

func invalid_copies(path: String) -> Array[String]:
	var found: Array[String] = []
	for filename in DirAccess.get_files_at(path.get_base_dir()):
		if filename.begins_with(path.get_file() + ".invalid-"):
			found.append(path.get_base_dir().path_join(filename))
	return found

func run() -> void:
	DirAccess.make_dir_recursive_absolute(base)
	var path := base + "/customization.json"
	var store := Store.new(path)
	var state: Resource = store.load_customization()
	check(store.load_result == "new","Sem arquivo carrega padrões")
	check(not FileAccess.file_exists(path),"Abrir sem alterações não grava")
	state.body_color = Color(0.1234,0.3456,0.7891)
	state.finish = 2
	state.gloss = 0.31
	state.wheel_model = 3
	state.wheel_color = Color(0.95,0.37,0.19)
	state.wheel_inches = 17
	state.select_film(5)
	state.film_intensity = 0.81
	state.sport_intake = true
	state.turbo_visual = true
	state.strut_brace = true
	state.audio_setup = 3
	state.upholstery = 2
	state.interior_color = Color("b9a580")
	state.seat_color = Color("a55335")
	check(store.save_customization(state),"Primeira gravação")
	check(store.document(store.load_customization()) == store.document(state),"Todos os campos preservados no JSON")
	check(not FileAccess.file_exists(path + ".tmp"),"Temporário promovido após sucesso")
	var legacy := store.document(state).duplicate(true)
	legacy.schema_version = 1
	for key in ["sport_intake","turbo_visual","strut_brace","audio_setup","upholstery","interior_color","seat_color"]:
		legacy.erase(key)
	var migrated := store.decode(legacy)
	check(migrated != null,"Save da versão anterior aceito")
	check(migrated.body_color == state.body_color and migrated.wheel_inches == 17,"Migração mantém pintura e rodas")
	check(not migrated.turbo_visual and migrated.audio_setup == 0,"Novas opções recebem padrões na migração")
	var legacy_path := base + "/legacy.json"
	raw(legacy_path,JSON.stringify(legacy))
	var legacy_store := Store.new(legacy_path)
	check(legacy_store.load_customization().wheel_inches == 17,"Arquivo v1 lido do disco")
	check(legacy_store.save_customization(migrated),"Arquivo v1 atualizado para v2")
	check(int(JSON.parse_string(FileAccess.get_file_as_string(legacy_path)).schema_version) == 2,"Schema atualizado")
	check(int(JSON.parse_string(FileAccess.get_file_as_string(legacy_path + ".bak")).schema_version) == 1,"Arquivo v1 original no backup")
	var first := store.document(state)
	state.body_color = Color("2367ac")
	check(store.save_customization(state),"Substituição do arquivo existente")
	check(store.document(store.read_state(path + ".bak")) == first,"Backup contém versão válida anterior")
	var damaged := "{JSON interrompido"
	raw(path,damaged)
	var recovered := store.load_customization()
	check(store.load_result == "recovered","Arquivo corrompido recupera backup")
	check(store.document(recovered) == first,"Recuperação usa valores anteriores corretos")
	check(store.save_customization(recovered),"Gravação após recuperação")
	var archives := invalid_copies(path)
	check(archives.size() == 1,"Original inválido arquivado")
	check(FileAccess.get_file_as_string(archives[0]) == damaged,"Bytes inválidos preservados")
	check(store.read_state(path + ".bak") != null,"Backup válido preservado após recuperação")
	raw(path,"broken again")
	raw(path + ".bak","broken backup")
	var defaults := store.load_customization()
	check(store.load_result == "invalid","Sem backup válido usa padrões com aviso")
	check(defaults.wheel_inches == 14,"Padrão seguro")
	check(store.save_customization(defaults),"Pode salvar padrões após arquivo inválido")
	check(invalid_copies(path).size() == 2,"Não sobrescreve arquivo já arquivado")
	check(store.save_customization(state),"Grava estado após padrões")
	check(invalid_copies(path + ".bak").size() == 1,"Backup inválido também preservado")
	var valid := store.document(state)
	for change in [
		{"wheel_inches":18}, {"wheel_model":-1}, {"wheel_model":1.5},
		{"gloss":true}, {"gloss":"0.5"}, {"gloss":-0.01},
		{"film_intensity":1.1}, {"film":6}, {"finish":3},
		{"body_color":[1,0]}, {"wheel_color":[1,0,"x"]},
		{"body_color":[1.2,0,0]}, {"vehicle_id":"other_car"},
		{"schema_version":3}, {"schema_version":"1"},
		{"film":0,"film_intensity":0.5},
		{"sport_intake":1}, {"turbo_visual":"true"}, {"strut_brace":null},
		{"audio_setup":4}, {"upholstery":3}, {"interior_color":[1,2,0]},
		{"seat_color":[0,0]},
	]:
		var data := valid.duplicate(true)
		data.merge(change,true)
		check(store.decode(data) == null,"Dados incompatíveis rejeitados: " + str(change.keys()))
	var missing := valid.duplicate(true)
	missing.erase("wheel_color")
	check(store.decode(missing) == null,"Campo obrigatório ausente")
	check(store.decode([]) == null,"Raiz de JSON inválida")
	check(not store.number(INF,0,1),"Infinito rejeitado")
	check(not store.number(NAN,0,1),"NaN rejeitado")
	var huge := base + "/huge.json"
	raw(huge," ".repeat(Store.MAX_BYTES + 1))
	check(Store.new(huge).read_state(huge) == null,"Arquivo excessivo rejeitado")
	# Falha determinística: o caminho temporário é um diretório, sem tocar permissões do usuário.
	var before := FileAccess.get_file_as_string(path)
	DirAccess.make_dir_absolute(path + ".tmp")
	check(not store.save_customization(state),"Falha de gravação retorna false")
	check(store.last_error != OK,"Erro exposto à interface")
	check(FileAccess.get_file_as_string(path) == before,"Falha preserva versão principal")
	check(store.read_state(path + ".bak") != null,"Falha preserva backup")
	print("PASS: %d verificações de JSON, backup, recuperação e falhas de gravação" % checks)
	quit(0)
