extends Button

var card_id = 0
var face_up = true
var found = false

func flip(show_face_up: bool):
	face_up = show_face_up
	if face_up:
		text = str(card_id)
	else:
		text = "?"

func _pressed():
	if found:
		return
	print("Card clicked, id: ", card_id)
