extends Node2D

const ESCENA_MENU := "res://main_menu.tscn"

@onready var boton_menu = $BotonMenu

var imagen_fondo: TextureRect


func _ready() -> void:
	boton_menu.pressed.connect(func(): get_tree().change_scene_to_file(ESCENA_MENU))

	var capa_ui := CanvasLayer.new()
	capa_ui.layer = 1
	add_child(capa_ui)

	imagen_fondo = TextureRect.new()
	imagen_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	imagen_fondo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	imagen_fondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagen_fondo.texture = load("res://images/fondo13.png")
	capa_ui.add_child(imagen_fondo)

	# botón sobre el fondo
	boton_menu.get_parent().remove_child(boton_menu)
	capa_ui.add_child(boton_menu)
