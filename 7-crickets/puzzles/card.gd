extends Button

var card_id = 0
var face_up = true
var found = false

var textura_dorso: Texture2D
var textura_frente: Texture2D


func flip(show_face_up: bool):
	face_up = show_face_up
	icon = textura_frente if face_up else textura_dorso
	text = ""  # ya no mostramos texto, solo la imagen


func _pressed():
	if found:
		return
