extends Node2D

const ESCENA_MENU := "res://main_menu.tscn"

@onready var boton_menu = $BotonMenu

var imagen_fondo: TextureRect
var personaje: TextureRect


func _ready() -> void:
	boton_menu.pressed.connect(func(): get_tree().change_scene_to_file(ESCENA_MENU))

	var capa_ui := CanvasLayer.new()
	capa_ui.layer = 1
	add_child(capa_ui)

	var fondo := ColorRect.new()
	fondo.color = Color(1.0, 0.9, 0.6)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa_ui.add_child(fondo)

	imagen_fondo = TextureRect.new()
	imagen_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	imagen_fondo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	imagen_fondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# imagen_fondo.texture = load("res://images/NOMBRE_FONDO_ESCENA17.png")
	capa_ui.add_child(imagen_fondo)

	personaje = TextureRect.new()
	personaje.position = Vector2(700, 300)
	personaje.custom_minimum_size = Vector2(400, 400)
	# personaje.texture = load("res://images/personaje_feliz.png")
	capa_ui.add_child(personaje)
