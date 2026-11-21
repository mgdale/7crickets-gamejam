extends Node

const VOLUMEN_MUSICA_DB := -12.0
const VOLUMEN_SFX_DB := -6.0
const MUSICA_MENU := "res://music/zodiance_main_theme.mp3"
const MUSICA_HISTORIA := "res://music/year_of_the_panda.mp3"
const MUSICA_MAPA := "res://music/fortune_valley.mp3"
const MUSICA_JUEGOS := "res://music/rise_from_the_house.mp3"  # suena de la escena 9 a la 12

const MAX_SFX := 8

var player_a: AudioStreamPlayer
var player_b: AudioStreamPlayer
var pool_sfx: Array[AudioStreamPlayer] = []
var cache_sfx := {}
var activo: AudioStreamPlayer
var ruta_actual := ""


func _ready() -> void:
	player_a = AudioStreamPlayer.new()
	player_b = AudioStreamPlayer.new()
	add_child(player_a)
	add_child(player_b)
	for i in range(MAX_SFX):
		var p := AudioStreamPlayer.new()
		add_child(p)
		pool_sfx.append(p)
	activo = player_a


func reproducir_musica(ruta: String, volumen_db: float = VOLUMEN_MUSICA_DB, fade: float = 2.5) -> void:
	if ruta == ruta_actual and activo.playing:
		_fade(activo, volumen_db, fade, false)
		return
	ruta_actual = ruta

	var saliente := activo
	var entrante := player_b if activo == player_a else player_a
	activo = entrante

	entrante.stream = load(ruta)
	entrante.volume_db = -80.0
	entrante.play()
	_fade(entrante, volumen_db, fade, false)

	if saliente.playing:
		_fade(saliente, -80.0, fade, true)


func detener_musica(fade: float = 1.5) -> void:
	ruta_actual = ""
	if activo.playing:
		_fade(activo, -80.0, fade, true)

func bajar_musica(volumen_db: float = -30.0, fade: float = 1.0) -> void:
	if activo.playing:
		_fade(activo, volumen_db, fade, false)

func reproducir_sfx(ruta: String, volumen_db: float = VOLUMEN_SFX_DB, pitch: float = 1.0) -> void:
	if not cache_sfx.has(ruta):
		cache_sfx[ruta] = load(ruta)

	var libre: AudioStreamPlayer = pool_sfx[0]
	for p in pool_sfx:
		if not p.playing:
			libre = p
			break

	libre.stream = cache_sfx[ruta]
	libre.volume_db = volumen_db
	libre.pitch_scale = pitch
	libre.play()

func _fade(player: AudioStreamPlayer, destino_db: float, duracion: float, detener_al_final: bool) -> void:
	if player.has_meta("tween_fade"):
		var viejo: Tween = player.get_meta("tween_fade")
		if viejo and viejo.is_valid():
			viejo.kill()

	var desde := db_to_linear(player.volume_db)
	var hasta := db_to_linear(destino_db)

	var t := create_tween()
	t.tween_method(
		func(v: float): player.volume_db = linear_to_db(maxf(v, 0.0001)),
		desde, hasta, duracion
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	if detener_al_final:
		t.tween_callback(player.stop)

	player.set_meta("tween_fade", t)
