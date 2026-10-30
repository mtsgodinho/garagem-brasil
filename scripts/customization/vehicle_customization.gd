extends Resource
## Estado independente do visual. Serialização gerenciada por customization_store.gd.

const FINISHES := ["Brilhante", "Metálica", "Fosca"]
const WHEEL_NAMES := ["Estrela • 5 raios", "Clássica • 6 raios", "Turbina • 10 raios", "Esportiva • raios duplos", "Disco • 8 janelas", "Rally • 8 raios", "Multirraios • 12", "Malha • cruzada", "Três raios", "Aero • 6 pás"]
const FILMS := ["Sem película", "Clara", "Média", "Escura", "Extremamente escura", "Espelhada"]
const AUDIO_NAMES := ["Sem caixa", "Compacta • 1 subwoofer", "Dupla • 2 subwoofers", "Paredão compacto • 4 falantes"]
const UPHOLSTERIES := ["Tecido", "Couro sintético", "Esportivo bicolor"]
const FILM_LEVELS := [0.0, 0.20, 0.45, 0.70, 0.94, 0.60]

@export var body_color := Color("b8cbd5")
@export_range(0, 2) var finish := 1
@export_range(0.0, 1.0) var gloss := 0.65
@export_range(0, 9) var wheel_model := 0
@export var wheel_color := Color("b7c1cb")
@export_range(13, 17) var wheel_inches := 14
@export_range(0, 5) var film := 0
@export_range(0.0, 1.0) var film_intensity := 0.0

func select_film(index: int) -> void:
	film = clampi(index, 0, FILMS.size() - 1)
	film_intensity = FILM_LEVELS[film]

@export var sport_intake := false
@export var turbo_visual := false
@export var strut_brace := false
@export_range(0, 3) var audio_setup := 0
@export_range(0, 2) var upholstery := 0
@export var interior_color := Color("303944")
@export var seat_color := Color("394854")

const BUMPERS := ["Original", "Esportivo", "Touring"]
const FENDERS := ["Original", "Alargador discreto", "Wide body"]
const KITS := ["Sem kit", "Saias e lip", "Aero completo"]
const TAILLIGHTS := ["Original", "Fumê", "Cristal", "Vermelha"]
const STICKERS := ["Sem adesivo", "Faixa lateral", "Listras duplas", "Número 06"]
@export var bumper_style := 0
@export var fender_style := 0
@export var body_kit := 0
@export var taillight_style := 0
@export var sticker_style := 0
@export var sticker_color := Color("e6e6e6")
@export_range(0.0, 6.0) var lowering_cm := 0.0

const INTAKES := ["Original • caixa de ar", "Cônico esportivo", "Duplo fluxo", "Admissão fria • caixa fechada"]
const ENGINE_SOUNDS := ["Automático pelo filtro", "Original suave", "Grave encorpado", "Esportivo agudo", "Turbo / assobio"]
@export var intake_style := 0
@export var engine_sound := 0
@export_range(0.0, 1.0) var engine_volume := 0.5
@export var front_bumper_style := -1
@export var rear_bumper_style := -1
@export var side_skirt_style := -1

const PREPARATIONS := ["Original • 126 km/h", "Rua • 144 km/h", "Esportivo • 162 km/h", "Competição • 180 km/h"]
@export var performance_level := 0
@export var nitro_enabled := false
@export_range(0.0,100.0) var vehicle_health := 100.0
@export_range(0.0,100.0) var nitro_charge := 100.0
