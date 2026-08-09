extends Node2D

var dialogos := [
	{"Name": "conejo", "text": "epic dialogue in here trust"},
	{"Name": "Character", "text": "most epic dialogue in here"},
	{"Name": "Character", "text": "epic"},
]

@export var escena_siguiente: String = "res://scenes/escena_5.tscn"
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

	var fondo := ColorRect.new()
	fondo.color = Color(0.85, 0.92, 1.0)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa_ui.add_child(fondo)

	_crear_caja_nombre()
	_crear_caja_texto()
	_crear_indicador()

	_mostrar_dialogo(indice_dialogo)


func _crear_caja_nombre() -> void:
	var panel := PanelContainer.new()
	var x := (ANCHO_PANTALLA - ANCHO_CAJA_TEXTO) / 2
	var y := Y_CAJA_TEXTO - ALTO_CAJA_NOMBRE - ESPACIO_ENTRE_CAJAS
	panel.position = Vector2(x, y)
	panel.custom_minimum_size = Vector2(ANCHO_CAJA_NOMBRE, ALTO_CAJA_NOMBRE)
	panel.size = Vector2(ANCHO_CAJA_NOMBRE, ALTO_CAJA_NOMBRE)

	var estilo := StyleBoxTexture.new()
	estilo.texture = load("res://images/nombre_texto.png")
	estilo.content_margin_left = 20
	estilo.content_margin_right = 20
	estilo.content_margin_top = 20
	estilo.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", estilo)
	capa_ui.add_child(panel)

	caja_nombre = Label.new()
	caja_nombre.add_theme_font_size_override("font_size", 28)
	caja_nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja_nombre.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(caja_nombre)


func _crear_caja_texto() -> void:
	var panel := PanelContainer.new()
	var x := (ANCHO_PANTALLA - ANCHO_CAJA_TEXTO) / 2
	panel.position = Vector2(x, Y_CAJA_TEXTO)
	panel.custom_minimum_size = Vector2(ANCHO_CAJA_TEXTO, ALTO_CAJA_TEXTO)
	panel.size = Vector2(ANCHO_CAJA_TEXTO, ALTO_CAJA_TEXTO)

	var estilo := StyleBoxTexture.new()
	estilo.texture = load("res://images/caja_texto.png")
	estilo.content_margin_left = 45
	estilo.content_margin_right = 45
	estilo.content_margin_top = 35
	estilo.content_margin_bottom = 35
	panel.add_theme_stylebox_override("panel", estilo)
	capa_ui.add_child(panel)

	caja_texto = RichTextLabel.new()
	caja_texto.bbcode_enabled = false
	caja_texto.scroll_active = false
	caja_texto.fit_content = true
	caja_texto.add_theme_font_size_override("normal_font_size", 28)
	caja_texto.add_theme_color_override("default_color", Color(0.1, 0.1, 0.1))
	panel.add_child(caja_texto)


func _crear_indicador() -> void:
	indicador = Label.new()
	indicador.text = "▼"
	indicador.add_theme_font_size_override("font_size", 26)
	indicador.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	var x := (ANCHO_PANTALLA - ANCHO_CAJA_TEXTO) / 2 + ANCHO_CAJA_TEXTO - 100
	var y := Y_CAJA_TEXTO + ALTO_CAJA_TEXTO - 80
	indicador.position = Vector2(x, y)
	indicador.visible = false
	capa_ui.add_child(indicador)


func _mostrar_dialogo(indice: int) -> void:
	var d: Dictionary = dialogos[indice]
	caja_nombre.text = d["Name"]
	caja_texto.text = d["text"]
	caja_texto.visible_characters = 0

	indicador.visible = false
	if tween_indicador:
		tween_indicador.kill()

	escribiendo = true
	var total: int = String(d["text"]).length()
	if tween_texto:
		tween_texto.kill()
	tween_texto = create_tween()
	tween_texto.tween_method(_set_visible_chars, 0, total, total * velocidad_letra)
	tween_texto.finished.connect(_texto_terminado)


func _set_visible_chars(v: float) -> void:
	caja_texto.visible_characters = int(v)


func _texto_terminado() -> void:
	escribiendo = false
	_animar_indicador()


func _animar_indicador() -> void:
	indicador.visible = true
	var pos_base := indicador.position.y
	tween_indicador = create_tween()
	tween_indicador.set_loops()
	tween_indicador.tween_property(indicador, "position:y", pos_base + 8, 0.4)
	tween_indicador.tween_property(indicador, "position:y", pos_base, 0.4)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if escribiendo:
			if tween_texto:
				tween_texto.kill()
			caja_texto.visible_characters = dialogos[indice_dialogo]["text"].length()
			_texto_terminado()
		else:
			_siguiente_dialogo()


func _siguiente_dialogo() -> void:
	indice_dialogo += 1
	if indice_dialogo >= dialogos.size():
		_cambiar_escena(escena_siguiente)
		return
	_mostrar_dialogo(indice_dialogo)


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
