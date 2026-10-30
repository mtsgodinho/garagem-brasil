extends AudioStreamPlayer
## Som procedural próprio. Timbres sintetizados, sem gravações externas.
const RATE := 16000.0
var phase := 0.0
var whistle_phase := 0.0
var rpm := 950.0
var target_rpm := 950.0
var level := 0.0
var target_level := 0.0
var profile := 1
var boosted := false
var noise := RandomNumberGenerator.new()
var playback: AudioStreamGeneratorPlayback

static func selected_profile(state: Resource) -> int:
	if state.engine_sound > 0: return state.engine_sound
	if state.turbo_visual: return 4
	var intake: int = state.intake_style
	if intake == 0 and state.sport_intake: intake = 1
	return [1,3,2,2][intake]

func _ready() -> void:
	noise.seed = 64821
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = RATE
	generator.buffer_length = 0.22
	stream = generator


func update_engine(state: Resource, speed: float, throttle: float, running: bool) -> void:
	if running and state.engine_volume > 0 and not playing:
		play()
		playback = get_stream_playback()
	profile = selected_profile(state)
	boosted = state.turbo_visual
	var road_speed := absf(speed)
	var gear := mini(4,int(road_speed/8.0))
	var ratio: float = [12.0,8.5,6.0,4.6,3.7][gear]
	target_rpm = maxf(950.0,road_speed*ratio*29.84)+throttle*500.0
	target_level = (0.10+throttle*0.14+minf(road_speed/35.0,1.0)*0.04)*state.engine_volume if running else 0.0

func sample() -> float:
	phase = fmod(phase+TAU*(rpm/30.0)/RATE,TAU*2.0)
	whistle_phase = fmod(whistle_phase+TAU*(1000.0+rpm*0.18)/RATE,TAU)
	var result := sin(phase)*0.58+sin(phase*2.0)*0.23+sin(phase*4.0)*0.08
	if profile == 2: result = sin(phase)*0.72+sin(phase*0.5)*0.20+sin(phase*3)*0.13
	elif profile == 3: result = sin(phase)*0.39+sin(phase*2)*0.34+sin(phase*5)*0.22
	elif profile == 4: result += sin(whistle_phase)*0.12*clampf((rpm-1500)/4000,0,1)
	result += noise.randf_range(-1,1)*(0.025 if profile == 1 else 0.055)
	return clampf(result*level,-0.9,0.9)

func _process(delta: float) -> void:
	rpm = move_toward(rpm,target_rpm,delta*9000)
	level = move_toward(level,target_level,delta*0.8)
	if level == 0 and target_level == 0 and playing:
		stop_sound()
	if playback == null: return
	var available := mini(playback.get_frames_available(),int(RATE*0.22))
	for i in available:
		var value := sample()
		playback.push_frame(Vector2(value,value))

func stop_sound() -> void:
	stop()
	playback = null

func _exit_tree() -> void:
	stop_sound()
	stream = null
