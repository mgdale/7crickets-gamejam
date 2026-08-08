extends Node

var puzzles_solved = {
	"memory": false,
	"find_queen": false,
	"simon": false
}

const MAP_SCENE = "res://map.tscn"
const PUZZLE_PATHS = {
	"memory": "res://puzzles/memory.tscn",
	"find_queen": "res://puzzles/find_queen.tscn",
	"simon": "res://puzzles/simon.tscn"
}

var current_puzzle = ""

func go_to_puzzle(puzzle_name: String):
	current_puzzle = puzzle_name
	get_tree().change_scene_to_file(PUZZLE_PATHS[puzzle_name])

func complete_current_puzzle():
	puzzles_solved[current_puzzle] = true
	get_tree().change_scene_to_file(MAP_SCENE)
