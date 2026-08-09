extends Node2D

@export var escena_siguiente: String = "res://scenes/escena_8.tscn"

var imagen_fondo: TextureRect


func _ready() -> void:
	var capa_ui := CanvasLayer.new()
	capa_ui.layer = 1
	add_child(capa_ui)

	imagen_fondo = TextureRect.new()
	imagen_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	imagen_fondo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	imagen_fondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# reemplazar cuando tengan el arte real:
	imagen_fondo.texture = load("res://images/NOMBRE_IMAGEN_ESCENA7.png")
	capa_ui.add_child(imagen_fondo)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_cambiar_escena(escena_siguiente)


func _cambiar_escena(ruta: String) -> void:
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
	
