extends Resource
## Estado independente do visual. Serialização gerenciada por customization_store.gd.

const FINISHES := ["Brilhante", "Metálica", "Fosca"]
const WHEEL_NAMES := ["Estrela • 5 raios", "Clássica • 6 raios", "Turbina • 10 raios", "Esportiva • raios duplos", "Disco • 8 janelas"]
const FILMS := ["Sem película", "Clara", "Média", "Escura", "Extremamente escura", "Espelhada"]
const AUDIO_NAMES := ["Sem caixa", "Compacta • 1 subwoofer", "Dupla • 2 subwoofers", "Paredão compacto • 4 falantes"]
const UPHOLSTERIES := ["Tecido", "Couro sintético", "Esportivo bicolor"]
const FILM_LEVELS := [0.0, 0.20, 0.45, 0.70, 0.94, 0.60]

@export var body_color := Color("b8cbd5")
@export_range(0, 2) var finish := 1
@export_range(0.0, 1.0) var gloss := 0.65
@export_range(0, 4) var wheel_model := 0
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
