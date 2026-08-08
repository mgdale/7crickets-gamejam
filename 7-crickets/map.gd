extends Control


@onready var charm_memory = $CharmMemory
@onready var charm_find_queen = $CharmFindQueen
@onready var charm_simon = $CharmSimon


func _ready():
	charm_memory.pressed.connect(func(): GameState.go_to_puzzle("memory"))
	charm_find_queen.pressed.connect(func(): GameState.go_to_puzzle("find_queen"))
	charm_simon.pressed.connect(func(): GameState.go_to_puzzle("simon"))
	
	update_charms() #oculta los dijes ya resueltos
	
func update_charms():
	charm_memory.visible = not GameState.puzzles_solved["memory"]	
	charm_find_queen.visible = not GameState.puzzles_solved["find_queen"]	
	charm_simon.visible = not GameState.puzzles_solved["simon"]	
