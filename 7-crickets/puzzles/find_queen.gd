extends Control

var cards = []
var positions = []
var queen_id = 1

func _ready():
	cards = get_children()

	for card in cards:
		positions.append(card.position)

	assign_queen()
	show_face_up()

	for card in cards:
		card.pressed.connect(_on_card_pressed.bind(card))

	await get_tree().create_timer(3.0).timeout
	hide_cards()
	await shuffle()


func assign_queen():
	cards.shuffle()
	cards[0].card_id = queen_id
	cards[1].card_id = 101
	cards[2].card_id = 102


func show_face_up():
	for card in cards:
		card.flip(true)


func hide_cards():
	for card in cards:
		card.flip(false)


func shuffle():
	for i in range(4):
		var a = randi() % cards.size()
		var b = randi() % cards.size()
		if a != b:
			await swap(cards[a], cards[b])


func swap(card_a, card_b):
	var pos_a = card_a.position
	var pos_b = card_b.position

	var tween = create_tween()
	tween.tween_property(card_a, "position", pos_b, 0.4)
	tween.parallel().tween_property(card_b, "position", pos_a, 0.4)

	await tween.finished


func _on_card_pressed(card):
	card.flip(true)
	if card.card_id == queen_id:
		print("You won, found the queen!")
	else:
		print("You lost")
		await get_tree().create_timer(1.0).timeout
		restart()


func restart():
	for card in cards:
		card.found = false
	assign_queen()
	show_face_up()
	await get_tree().create_timer(3.0).timeout
	hide_cards()
	await shuffle()
