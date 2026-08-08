extends Control

@onready var grid = $GridContainer
@onready var mensaje_perdiste = $MensajePerdiste

var cartas = []
# Aquí vamos a guardar la lista de las 8 cartas 

var primera_carta = null
var segunda_carta = null
# Cuando el jugador hace click en una carta, la guardamos aquí.
# Cuando hace click en la segunda, comparamos ambas.

var esperando = false
# variable que bloquea clicks


func _ready():
	
	cartas = grid.get_children()
	
	asignar_ids()
	mostrar_boca_arriba()
	# Muestra todas las cartas con su dibujo, para que el jugador memorice.

	for carta in cartas:
		carta.pressed.connect(_on_carta_pressed.bind(carta))
		
	await get_tree().create_timer(1.0).timeout
	# tiempo para memorizar las cartas
	

	ocultar_cartas()
	# Pasado el tiempo, las voltea todas boca abajo.


func asignar_ids():
	var indices = range(cartas.size())
	# Crea una lista de números x cada carta [0,1,2,3,4,5,6,7] 
	indices.shuffle()
	# Los revuelve en orden aleatorio.

	var pareja_1 = indices[0]
	var pareja_2 = indices[1]
	# Tomamos los primeros dos (ya revueltos al azar) como LA pareja real.

	for i in range(cartas.size()):
		if i == pareja_1 or i == pareja_2:
			cartas[i].id_carta = 1
			# Ambas cartas de la pareja real comparten el mismo id (1).
		else:
			cartas[i].id_carta = 100 + i
			# El resto de cartas reciben ids únicos (101, 102, 103...) para
			# que NUNCA puedan coincidir entre sí ni con la pareja real.

func mostrar_boca_arriba():
	for carta in cartas:
		carta.voltear(true)
		# Llama a la función voltear() para que muestre boca arriba


func ocultar_cartas():
	for carta in cartas:
		if not carta.encontrada:
			carta.voltear(false)
			# Voltea boca abajo solo las que no han sido encontradas todavía.


func _on_carta_pressed(carta):
	if esperando or carta.encontrada or carta.boca_arriba:
		return
		# Ignora el click si: estamos procesando otra jugada,
		# esta carta ya fue encontrada, o ya está boca arriba.

	carta.voltear(true)
	# Voltea la carta clickeada para mostrar su dibujo.

	if primera_carta == null:
		primera_carta = carta
		# Si es el primer click de esta ronda, solo la guardamos y esperamos
		# la segunda.
	else:
		segunda_carta = carta
		esperando = true
		comparar_cartas()


func comparar_cartas():
	if primera_carta.id_carta == segunda_carta.id_carta:
		# acertó la pareja
		print("¡Pareja encontrada!")
		primera_carta.encontrada = true
		segunda_carta.encontrada = true
		primera_carta = null
		segunda_carta = null
		esperando = false
	else:
		# falló, pierde y reinicia
		mensaje_perdiste.visible = true
		await get_tree().create_timer(1.5).timeout
		mensaje_perdiste.visible = false
		reiniciar_juego()


func reiniciar_juego():
	primera_carta = null
	segunda_carta = null
	esperando = false
	asignar_ids()        # reparte la pareja en otra posición al azar
	mostrar_boca_arriba()
	await get_tree().create_timer(1.0).timeout
	ocultar_cartas()
