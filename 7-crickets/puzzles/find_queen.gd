extends Control

var cartas = []
var posiciones = []  # guarda las posiciones fijas (100,100 / 250,100 / 400,100)
var id_reina = 1      # id que identifica a la carta reina

func _ready():
	cartas = get_children()

	for carta in cartas:
		posiciones.append(carta.position)  # guarda posición inicial de cada una

	asignar_reina()
	mostrar_boca_arriba()

	for carta in cartas:
		carta.pressed.connect(_on_carta_pressed.bind(carta))

	await get_tree().create_timer(3.0).timeout
	ocultar_cartas()
	await mezclar()


func asignar_reina():
	cartas.shuffle()  # revuelve el orden de la lista (no las posiciones visuales)
	cartas[0].id_carta = id_reina
	cartas[1].id_carta = 101
	cartas[2].id_carta = 102


func mostrar_boca_arriba():
	for carta in cartas:
		carta.voltear(true)


func ocultar_cartas():
	for carta in cartas:
		carta.voltear(false)


func mezclar():
	for i in range(4):  # 4 intercambios
		var a = randi() % cartas.size()
		var b = randi() % cartas.size()
		if a != b:
			await intercambiar(cartas[a], cartas[b])


func intercambiar(carta_a, carta_b):
	var pos_a = carta_a.position
	var pos_b = carta_b.position

	var tween = create_tween()  # anima el movimiento suavemente
	tween.tween_property(carta_a, "position", pos_b, 0.4)
	tween.parallel().tween_property(carta_b, "position", pos_a, 0.4)

	await tween.finished  # espera a que termine la animación


func _on_carta_pressed(carta):
	carta.voltear(true)
	if carta.id_carta == id_reina:
		print("¡Ganaste, encontraste la reina!")
	else:
		print("Has perdido")
		await get_tree().create_timer(1.0).timeout
		reiniciar()


func reiniciar():
	for carta in cartas:
		carta.encontrada = false
	asignar_reina()
	mostrar_boca_arriba()
	await get_tree().create_timer(3.0).timeout
	ocultar_cartas()
	await mezclar()
