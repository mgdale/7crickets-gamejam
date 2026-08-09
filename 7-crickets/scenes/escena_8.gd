extends Node2D

@export var escena_siguiente: String = "res://scenes/escena_10.tscn"
@export var tiempo_primer_fondo: float = 2.0

@onready var boton_siguiente = $NextButton

var imagen_fondo: TextureRect
var ya_avanzando := false
var listo_para_avanzar := false


func _ready() -> void:
	boton_siguiente.pressed.connect(_on_boton_pressed)
	boton_siguiente.visible = false  # oculto hasta que aparezca el segundo fondo

	var capa_ui := CanvasLayer.new()
	capa_ui.layer = 1
	add_child(capa_ui)

	imagen_fondo = TextureRect.new()
	imagen_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	imagen_fondo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	imagen_fondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagen_fondo.texture = load("res://images/fondo8.png")
	capa_ui.add_child(imagen_fondo)

	#boton sobre el fondo
	boton_siguiente.get_parent().remove_child(boton_siguiente)
	capa_ui.add_child(boton_siguiente)
	
	await get_tree().create_timer(tiempo_primer_fondo).timeout
	imagen_fondo.texture = load("res://images/fondo8.2.png")
	
	listo_para_avanzar = true
	boton_siguiente.visible = true


func _on_boton_pressed() -> void:
	_cambiar_escena(escena_siguiente)


func _unhandled_input(event: InputEvent) -> void:
	if not listo_para_avanzar:
		return
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
	
