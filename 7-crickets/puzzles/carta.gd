extends Button
var id_carta = 0
# Guarda qué "dibujo" tiene esta carta. Dos cartas con el mismo id_carta
# son pareja. Por defecto es 0, pero se lo vamos a asignar desde afuera


var boca_arriba = true
# true = la carta muestra su dibujo (id_carta).
# false = la carta muestra el dorso ("?").

var encontrada = false
# Una vez que el jugador encuentra la pareja correcta, esta carta pasa
# a true, y así sabemos que ya no debe reaccionar a más clicks.

func voltear(mostrar_boca_arriba: bool):
	boca_arriba = mostrar_boca_arriba
	if boca_arriba:
		text = str(id_carta)
		# "str()" convierte el número id_carta en texto, para poder
		# mostrarlo en la propiedad "text" del botón.
	else:
		text = "?"

func _pressed():
	if encontrada:
		return
		# Si la carta ya fue encontrada, no hacemos nada al hacerle click
		
	print("Se hizo click en la carta con id: ", id_carta)
	
