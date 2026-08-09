extends Node2D


var imagen_fondo: TextureRect

@export var escena_siguiente: String = "res://scenes/escena_3.tscn"
@export var velocidad_letra: float = 0.03

const ANCHO_PANTALLA := 1920

const ANCHO_CAJA_TEXTO := 1600
const ALTO_CAJA_TEXTO := 260
const Y_CAJA_TEXTO := 760

const ANCHO_CAJA_NOMBRE := 280
const ALTO_CAJA_NOMBRE := 80
const ESPACIO_ENTRE_CAJAS := 0

var capa_ui: CanvasLayer
var caja_texto: RichTextLabel
var caja_nombre: Label
var indicador: Label

var indice_dialogo := 0
var escribiendo := false
var tween_texto: Tween
var tween_indicador: Tween

func _ready() -> void:
	capa_ui = CanvasLayer.new()
	capa_ui.layer = 1
	add_child(capa_ui)

	imagen_fondo = TextureRect.new()
	imagen_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	imagen_fondo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	imagen_fondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# reemplazar cuando tengan el arte real:
	imagen_fondo.texture = load("res://images/NOMBRE_IMAGEN_ESCENA2.png")
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
	
