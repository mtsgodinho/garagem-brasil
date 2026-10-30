extends SceneTree

var failed := false
## Rodar em processos separados: write, read, exit, read-exit, failure.

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition and not failed:
		failed = true
		push_error(message)
		quit(1)
		return

func choose(option: OptionButton, index: int) -> void:
	option.select(index)
	option.item_selected.emit(index)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	check(args.size() == 2,"Modo e caminho de teste obrigatórios")
	var mode: String = args[0]
	var garage: Node3D = load("res://scenes/garage.tscn").instantiate()
	garage.save_path = args[1]
	root.add_child(garage)
	await process_frame
	var ui: CanvasLayer = garage.customization_ui
	var state: Resource = garage.customization
	if mode in ["write","failure"]:
		ui.body_picker.color = Color("b52c48")
		ui.body_picker.color_changed.emit(ui.body_picker.color)
		choose(ui.finish_option,2)
		ui.gloss_slider.value = 0.29
		choose(ui.wheel_option,3)
		ui.wheel_picker.color = Color("c2a450")
		ui.wheel_picker.color_changed.emit(ui.wheel_picker.color)
		ui.size_slider.value = 17
		choose(ui.film_option,5)
		ui.film_slider.value = 0.84
		ui.sport_intake_check.button_pressed = true
		ui.turbo_check.button_pressed = true
		ui.brace_check.button_pressed = true
		choose(ui.audio_option,3)
		choose(ui.upholstery_option,2)
		ui.interior_picker.color_changed.emit(Color("d0ba87"))
		ui.seat_picker.color_changed.emit(Color("ad6044"))
		check(garage.dirty,"Alteração marca estado pendente")
		if mode == "failure":
			DirAccess.make_dir_recursive_absolute(garage.save_path + ".tmp")
			garage.request_exit()
			check(garage.dirty,"Falha mantém estado pendente")
			check(garage.exit_dialog != null and garage.exit_dialog.visible,"Falha ao sair pede confirmação")
			check(ui.status.text.begins_with("Não foi possível salvar"),"Falha visível no jogo")
			garage.save_timer.stop()
		else:
			await create_timer(0.9).timeout
			check(not garage.dirty,"Timer concluiu salvamento automático")
			check(ui.status.text.begins_with("Modificações salvas"),"Sucesso visível")
			check(FileAccess.file_exists(garage.save_path),"Arquivo gravado pelo fluxo real")
	elif mode in ["read","read-exit"]:
		var expected := Color("268349") if mode == "read-exit" else Color("b52c48")
		check(state.body_color.is_equal_approx(expected),"Cor restaurada em novo processo")
		check(state.finish == 2 and is_equal_approx(state.gloss,0.29),"Acabamento e brilho restaurados")
		check(state.wheel_model == 3 and state.wheel_inches == 17,"Desenho e aro restaurados")
		check(state.wheel_color.is_equal_approx(Color("c2a450")),"Cor das rodas restaurada")
		check(state.film == 5 and is_equal_approx(state.film_intensity,0.84),"Tipo e intensidade restaurados")
		check(ui.body_picker.color.is_equal_approx(expected),"Seletor inicializado com cor salva")
		check(ui.wheel_option.selected == 3 and ui.size_slider.value == 17,"Controles das rodas sincronizados")
		check(ui.film_option.selected == 5 and is_equal_approx(ui.film_slider.value,0.84),"Controles dos vidros sincronizados")
		check(state.sport_intake and state.turbo_visual and state.strut_brace,"Peças do motor restauradas")
		check(state.audio_setup == 3 and state.upholstery == 2,"Som e estofado restaurados")
		check(ui.sport_intake_check.button_pressed and ui.turbo_check.button_pressed and ui.brace_check.button_pressed,"Controles do motor sincronizados")
		check(ui.audio_option.selected == 3 and ui.upholstery_option.selected == 2,"Controles de som e interior sincronizados")
		check(ui.interior_picker.color.is_equal_approx(Color("d0ba87")),"Cor do interior restaurada")
		check(ui.seat_picker.color.is_equal_approx(Color("ad6044")),"Cor dos bancos restaurada")
		for part in garage.get_node("VehicleVisual").part_open.values():
			check(not part,"Peças começam fechadas após reabrir")
		check(ui.status.text == "Modificações carregadas.","Carregamento informado")
		var visual: Node3D = garage.get_node("VehicleVisual")
		check(visual.body_material.albedo_color.is_equal_approx(expected),"Visual inicia com cor salva")
		check(visual.wheels[0].get_meta("inches") == 17,"Visual inicia com aro salvo")
	elif mode == "exit":
		ui.body_picker.color_changed.emit(Color("268349"))
		check(garage.dirty,"Há alteração ainda não salva")
		if failed:
			return
		print("PASS: fechamento com alteração pendente solicitado")
		garage.notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
		return
	else:
		check(false,"Modo desconhecido")
	if failed:
		return
	print("PASS: processo " + mode)
	quit(1 if failed else 0)
