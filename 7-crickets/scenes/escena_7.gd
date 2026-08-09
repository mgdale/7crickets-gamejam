extends Node2D

@export var escena_siguiente: String = "res://scenes/escena_8.tscn"

@onready var boton_siguiente = $NextButton

var imagen_fondo: TextureRect
var ya_avanzando := false


func _ready() -> void:
	boton_siguiente.pressed.connect(func(): _cambiar_escena(escena_siguiente))

	var capa_ui := CanvasLayer.new()
	capa_ui.layer = 1
	add_child(capa_ui)

	imagen_fondo = TextureRect.new()
	imagen_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	imagen_fondo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	imagen_fondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagen_fondo.texture = load("res://images/fondo7.png")
	capa_ui.add_child(imagen_fondo)

	# pulsera sobre el fondo
	var pulsera := TextureRect.new()
	pulsera.texture = load("res://images/pulsera_transparente.png")
	pulsera.position = Vector2(650, 550)  # ajusta posición
	pulsera.custom_minimum_size = Vector2(500, 500)  # ajusta tamaño
	pulsera.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	pulsera.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	capa_ui.add_child(pulsera)

	# boton sobre el fondo
	boton_siguiente.get_parent().remove_child(boton_siguiente)
	capa_ui.add_child(boton_siguiente)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		_cambiar_escena(escena_siguiente)


func _cambiar_escena(ruta: String) -> void:
	if ya_avanzando:
		return
	ya_avanzando = true

	var capa := CanvasLayer.new()
	capa.layer = 100
	add_child(capa)
	var fade := ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa.add_child(fade)
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.4)
	tween.tween_callback(func(): get_tree().change_scene_to_file(ruta))
