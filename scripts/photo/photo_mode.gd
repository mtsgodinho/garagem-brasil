extends Node3D
const Orbit = preload("res://scripts/camera/orbit_camera.gd")
signal finished
var target := Vector3.ZERO
var previous_camera: Camera3D
var camera: Camera3D
var overlay: CanvasLayer
var status: Label
var output_dir := "user://photos"
var capturing := false
var first_frame := 0
var last_photo := ""

func _ready() -> void:
	first_frame = Engine.get_process_frames()
	camera = Orbit.new()
	camera.target = target+Vector3(0,0.85,0)
	camera.h_offset = 0
	camera.fov = 50
	camera.distance = 6.0
	add_child(camera)
	camera.make_current()
	overlay = CanvasLayer.new()
	overlay.layer = 10
	add_child(overlay)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	overlay.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var row := HBoxContainer.new()
	column.add_child(row)
	var title := Label.new()
	title.text = "MODO FOTO • Arraste: girar • Rodinha: zoom • TAB: ocultar interface • R: enquadrar"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	var shoot := Button.new()
	shoot.text = "Fotografar (F12)"
	shoot.pressed.connect(capture)
	row.add_child(shoot)
	var folder := Button.new()
	folder.text = "Abrir pasta"
	folder.pressed.connect(func() -> void:
		if DirAccess.make_dir_recursive_absolute(output_dir) != OK or OS.shell_open(ProjectSettings.globalize_path(output_dir)) != OK:
			status.text = "Não foi possível abrir a pasta de fotos.")
	row.add_child(folder)
	var back := Button.new()
	back.text = "Voltar (P / ESC)"
	back.pressed.connect(close)
	row.add_child(back)
	status = Label.new()
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.text = "As fotos são gravadas sem interface na pasta de fotos do jogo."
	column.add_child(status)

func close() -> void:
	if capturing: return
	previous_camera.make_current()
	finished.emit()
	queue_free()

func capture() -> bool:
	if capturing: return false
	capturing = true
	var was_visible := overlay.visible
	overlay.hide()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var result := DirAccess.make_dir_recursive_absolute(output_dir)
	if result == OK:
		var stamp := Time.get_datetime_string_from_system().replace(":","-")
		last_photo = output_dir.path_join("garagem-"+stamp+"-"+str(Time.get_ticks_usec())+".png")
		var original := last_photo.trim_suffix(".png")
		var index := 1
		while FileAccess.file_exists(last_photo):
			last_photo = original+"-"+str(index)+".png"
			index += 1
		result = get_viewport().get_texture().get_image().save_png(last_photo)
	overlay.visible = was_visible
	capturing = false
	status.text = "Foto salva: "+ProjectSettings.globalize_path(last_photo) if result == OK else "Não foi possível salvar a foto. Verifique espaço e permissão da pasta."
	return result == OK

func _unhandled_key_input(event: InputEvent) -> void:
	if capturing or Engine.get_process_frames() <= first_frame+1: return
	if not event is InputEventKey or not event.pressed or event.echo: return
	if event.keycode in [KEY_ESCAPE,KEY_P]:
		get_viewport().set_input_as_handled()
		close()
	elif event.keycode == KEY_R:
		camera.target = target+Vector3(0,0.85,0)
		camera.yaw = 0.65
		camera.pitch = 0.15
		camera.distance = 6.0
		camera.update_view()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_F12:
		get_viewport().set_input_as_handled()
		capture()
	elif event.keycode == KEY_TAB:
		overlay.visible = not overlay.visible
		get_viewport().set_input_as_handled()
