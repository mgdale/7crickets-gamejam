extends Node

var puzzles_resueltos = {
	"memoria": false,
	"find_queen": false,
	"simon": false
}

var escena_actual = "intro"

func completar_puzzle(nombre):
	puzzles_resueltos[nombre] = true
	print(nombre, " resuelto!")

func todos_resueltos():
	for resuelto in puzzles_resueltos.values():
		if not resuelto:
			return false
	return true
