extends Node

var player_musica: AudioStreamPlayer
var player_sfx: AudioStreamPlayer


func _ready() -> void:
	player_musica = AudioStreamPlayer.new()
	add_child(player_musica)

	player_sfx = AudioStreamPlayer.new()
	add_child(player_sfx)


func reproducir_musica(ruta: String, volumen_db: float = 0.0) -> void:
	var nueva_pista = load(ruta)
	if player_musica.stream == nueva_pista and player_musica.playing:
		return  # ya está sonando esta misma pista, no la reinicies
	player_musica.stream = nueva_pista
	player_musica.volume_db = volumen_db
	player_musica.play()


func reproducir_sfx(ruta: String, volumen_db: float = 0.0) -> void:
	player_sfx.stream = load(ruta)
	player_sfx.volume_db = volumen_db
	player_sfx.play()


func detener_musica() -> void:
	player_musica.stop()
