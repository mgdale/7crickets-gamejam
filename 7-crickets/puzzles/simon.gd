extends Control

@onready var botones = [$Button1, $Button2, $Button3, $Button4, $Button5]

var secuencia = []
var input_jugador = []
var ronda = 1
var mostrando = false


func _ready():
	for i in range(botones.size()):
		botones[i].pressed.connect(_on_boton_pressed.bind(i))
	nueva_ronda()


func nueva_ronda():
	input_jugador.clear()
	secuencia.append(randi() % botones.size())
	await mostrar_secuencia()


func mostrar_secuencia():
	mostrando = true
	for paso in secuencia:
		await parpadear(botones[paso])
		await get_tree().create_timer(0.2).timeout
	mostrando = false


func parpadear(boton):
	boton.modulate = Color.YELLOW
	await get_tree().create_timer(0.4).timeout
	boton.modulate = Color.WHITE


func _on_boton_pressed(indice):
	if mostrando:
		return

	input_jugador.append(indice)
	var paso_actual = input_jugador.size() - 1

	if input_jugador[paso_actual] != secuencia[paso_actual]:
		reiniciar()
		return

	if input_jugador.size() == secuencia.size():
		if secuencia.size() >= 5:
			GameState.complete_current_puzzle()
		else:
			ronda += 1
			await get_tree().create_timer(0.6).timeout
			nueva_ronda()


func reiniciar():
	secuencia.clear()
	input_jugador.clear()
	ronda = 1
	nueva_ronda()
