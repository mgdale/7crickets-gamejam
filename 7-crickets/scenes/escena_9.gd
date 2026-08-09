extends Node2D

@export var escena_siguiente: String = "res://scenes/escena_10.tscn"
@export var zoom_target_position: Vector2 = Vector2(1230, 280)
@export var zoom_amount: float = 2.0
@export var duracion_zoom: float = 0.35  
@export var tiempo_antes_de_zoom: float = 0.6

@onready var boton_siguiente = $NextButton

var imagen_fondo: TextureRect
var capa_ui: CanvasLayer
var ya_avanzando := false
var listo_para_avanzar := false


func _ready() -> void:
	boton_siguiente.pressed.connect(_on_boton_pressed)
	boton_siguiente.visible = false

	capa_ui = CanvasLayer.new()
	capa_ui.layer = 1
	add_child(capa_ui)

	imagen_fondo = TextureRect.new()
	imagen_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	imagen_fondo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	imagen_fondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagen_fondo.texture = load("res://images/fondo9.png")
	imagen_fondo.pivot_offset = zoom_target_position
	capa_ui.add_child(imagen_fondo)

	boton_siguiente.get_parent().remove_child(boton_siguiente)
	capa_ui.add_child(boton_siguiente)

	await get_tree().create_timer(tiempo_antes_de_zoom).timeout
	await hacer_zoom_epico()
	listo_para_avanzar = true
	boton_siguiente.visible = true


func hacer_zoom_epico() -> void:
	#pequeno "retroceso" antes del golpe, como cuando alguien se sobresalta

	var tween := create_tween()
	tween.tween_property(imagen_fondo, "scale", Vector2(0.97, 0.97), 0.08)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	#el golpeeee
	tween.tween_property(imagen_fondo, "scale", Vector2(zoom_amount, zoom_amount), duracion_zoom)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	tween.tween_callback(_shake_susto)
	tween.tween_callback(_viñeta_susto)

	await tween.finished


func _shake_susto() -> void:
	var pos_original := imagen_fondo.position
	var shake := create_tween()
	var fuerza := 14.0
	for i in range(8):
		var offset := Vector2(randf_range(-fuerza, fuerza), randf_range(-fuerza, fuerza))
		shake.tween_property(imagen_fondo, "position", pos_original + offset, 0.03)
		fuerza *= 0.75 
	shake.tween_property(imagen_fondo, "position", pos_original, 0.05)


func _viñeta_susto() -> void:
	var vineta := ColorRect.new()
	vineta.color = Color(1.0, 0.986, 0.984, 0.0)
	vineta.set_anchors_preset(Control.PRESET_FULL_RECT)
	vineta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_ui.add_child(vineta)
	vineta.z_index = 10

	var tween := create_tween()
	tween.tween_property(vineta, "color:a", 0.35, 0.08)
	tween.tween_property(vineta, "color:a", 0.0, 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): vineta.queue_free())


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
