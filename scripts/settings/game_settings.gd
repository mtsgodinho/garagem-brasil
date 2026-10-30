extends Node
const RESOLUTIONS := [Vector2i(960,540),Vector2i(1280,720),Vector2i(1600,900),Vector2i(1920,1080)]
const DEFAULTS := {"resolution":1,"fullscreen":false,"quality":1,"volume":0.7}
var values: Dictionary = DEFAULTS.duplicate()
var file_path := "user://settings.cfg"
var allow_window_changes := true
var last_error := ""

func _ready() -> void:
	load_settings()
	get_tree().node_added.connect(on_node_added)
	apply(values)

func normalize(data: Dictionary) -> Dictionary:
	var result := DEFAULTS.duplicate()
	for key in ["resolution","quality"]:
		var value: Variant = data.get(key)
		var maximum := 3 if key == "resolution" else 2
		if typeof(value) == TYPE_INT and value >= 0 and value <= maximum: result[key] = value
	if typeof(data.get("fullscreen")) == TYPE_BOOL: result.fullscreen = data.fullscreen
	var volume: Variant = data.get("volume")
	if typeof(volume) in [TYPE_FLOAT,TYPE_INT] and is_finite(float(volume)) and volume>=0 and volume<=1: result.volume = float(volume)
	return result

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(file_path) != OK: return
	var data := {}
	for key in DEFAULTS: data[key] = config.get_value("game",key,DEFAULTS[key])
	values = normalize(data)

func apply(data: Dictionary) -> void:
	values = normalize(data)
	get_viewport().msaa_3d = [Viewport.MSAA_DISABLED,Viewport.MSAA_2X,Viewport.MSAA_4X][values.quality]
	AudioServer.set_bus_mute(0,values.volume == 0)
	AudioServer.set_bus_volume_db(0,linear_to_db(maxf(values.volume,0.0001)))
	for light in get_tree().root.find_children("*","DirectionalLight3D",true,false): apply_light(light)
	if allow_window_changes and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if values.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		if not values.fullscreen:
			var bounds := DisplayServer.screen_get_usable_rect()
			var size: Vector2i = RESOLUTIONS[values.resolution].min(bounds.size)
			DisplayServer.window_set_size(size)
			DisplayServer.window_set_position(bounds.position+(bounds.size-size)/2)

func on_node_added(node: Node) -> void:
	if node is DirectionalLight3D: call_deferred("apply_light",node)

func apply_light(light: DirectionalLight3D) -> void:
	if not is_instance_valid(light) or not light.is_inside_tree(): return
	if not light.has_meta("settings_base_shadow"): light.set_meta("settings_base_shadow",light.shadow_enabled)
	light.shadow_enabled = bool(light.get_meta("settings_base_shadow")) and values.quality>0
	light.directional_shadow_max_distance = 45.0 if values.quality == 1 else 90.0

func save_settings() -> bool:
	var config := ConfigFile.new()
	for key in values: config.set_value("game",key,values[key])
	var result := DirAccess.make_dir_recursive_absolute(file_path.get_base_dir())
	if result == OK: result = config.save(file_path+".tmp")
	if result == OK: result = DirAccess.rename_absolute(file_path+".tmp",file_path)
	last_error = "" if result == OK else "Não foi possível salvar as configurações."
	return result == OK
