extends Node2D

@export var escena_siguiente: String = "res://scenes/escena_3.tscn"

var imagen_fondo: TextureRect


func _ready() -> void:
	var capa_ui := CanvasLayer.new()
	capa_ui.layer = 1
	add_child(capa_ui)

	var fondo := ColorRect.new()
	fondo.color = Color(0.7, 0.85, 0.7)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa_ui.add_child(fondo)

	imagen_fondo = TextureRect.new()
	imagen_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	imagen_fondo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	imagen_fondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# imagen_fondo.texture = load("res://images/NOMBRE_IMAGEN_AQUI.png")
	capa_ui.add_child(imagen_fondo)

	var boton_siguiente := Button.new()
	boton_siguiente.text = "Siguiente"
	boton_siguiente.position = Vector2(1700, 950)
	boton_siguiente.custom_minimum_size = Vector2(150, 60)
	boton_siguiente.pressed.connect(func(): _cambiar_escena(escena_siguiente))
	capa_ui.add_child(boton_siguiente)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_cambiar_escena(escena_siguiente)


func _cambiar_escena(ruta: String) -> void:
	var capa := CanvasLayer.new()
	capa.layer = 100
	add_child(capa)
	var fade := ColorRect.new()
	fade.color = Color(0.608, 0.427, 0.973, 1.0)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa.add_child(fade)
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.4)
	tween.tween_callback(func(): get_tree().change_scene_to_file(ruta))
	
