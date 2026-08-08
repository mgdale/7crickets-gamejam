extends Control

@onready var grid = $GridContainer
@onready var win_message = $WinMessage
@onready var lose_message = $LoseMessage

var cards = []
var first_card = null
var second_card = null
var waiting = false


func _ready():
	win_message.visible = false
	lose_message.visible = false
	cards = grid.get_children()
	assign_ids()
	show_face_up()

	for card in cards:
		card.pressed.connect(_on_card_pressed.bind(card))

	await get_tree().create_timer(3.0).timeout
	hide_cards()


func assign_ids():
	var indices = range(cards.size())
	indices.shuffle()

	var pair_1 = indices[0]
	var pair_2 = indices[1]

	for i in range(cards.size()):
		if i == pair_1 or i == pair_2:
			cards[i].card_id = 1
		else:
			cards[i].card_id = 100 + i


func show_face_up():
	for card in cards:
		card.flip(true)


func hide_cards():
	for card in cards:
		if not card.found:
			card.flip(false)


func _on_card_pressed(card):
	if waiting or card.found or card.face_up:
		return

	card.flip(true)

	if first_card == null:
		first_card = card
	else:
		second_card = card
		waiting = true
		compare_cards()


func compare_cards():
	if first_card.card_id == second_card.card_id:
		first_card.found = true
		second_card.found = true
		win_message.visible = true
		await get_tree().create_timer(1.5).timeout
		win_message.visible = false
		GameState.complete_current_puzzle()
	else:
		lose_message.visible = true
		await get_tree().create_timer(1.5).timeout
		lose_message.visible = false
		await get_tree().create_timer(0.5).timeout
		restart_game()


func restart_game():
	first_card = null
	second_card = null
	waiting = false
	assign_ids()
	show_face_up()
	await get_tree().create_timer(3.0).timeout
	hide_cards()
