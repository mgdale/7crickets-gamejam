extends Node2D

var dialogos := [
	{"Name": "Narrator", "text": "Congratulations! The zodiac spirit for this new year has been chosen."},
	{"Name": "Narrator", "text": "It's you, little one!"},
]

@export var escena_siguiente: String = "res://scenes/escena_2.tscn"
@export var velocidad_letra: float = 0.03
@export var tiempo_dormido: float = 0.5

const ANCHO_PANTALLA := 1920

const ANCHO_CAJA_TEXTO := 1600
const ALTO_CAJA_TEXTO := 260
const Y_CAJA_TEXTO := 760

const ANCHO_CAJA_NOMBRE := 280
const ALTO_CAJA_NOMBRE := 80
const ESPACIO_ENTRE_CAJAS := 0

var capa_ui: CanvasLayer
var fondo: TextureRect
var panel_nombre: PanelContainer
var panel_texto: PanelContainer
var caja_texto: RichTextLabel
var caja_nombre: Label
var indicador: Label

var indice_dialogo := 0
var escribiendo := false
var despierto := false
var tween_texto: Tween
var tween_indicador: Tween


func _ready() -> void:
	capa_ui = CanvasLayer.new()
	capa_ui.layer = 1
	add_child(capa_ui)

	fondo = TextureRect.new()
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	fondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	fondo.texture = load("res://images/fondo1.png")
	capa_ui.add_child(fondo)

	_crear_caja_nombre()
	_crear_caja_texto()
	_crear_indicador()

	panel_nombre.visible = false
	panel_texto.visible = false

	await get_tree().create_timer(tiempo_dormido).timeout
	despertar()


func despertar() -> void:
	despierto = true
	_transicion_nacimiento()


func _transicion_nacimiento() -> void:
	fondo.pivot_offset = fondo.size / 2

	#Flash blanco que se pone encima de todo
	var flash := ColorRect.new()
	flash.color = Color(1, 1, 1, 0)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_ui.add_child(flash)
	flash.z_index = 10

	var tween := create_tween()

	tween.tween_property(fondo, "scale", Vector2(1.08, 1.08), 0.35)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.tween_callback(func():
		fondo.texture = load("res://images/fondo1.2.png")
		_lanzar_fuegos_artificiales()
	)

	tween.tween_property(flash, "color:a", 0.9, 0.06)
	tween.tween_property(flash, "color:a", 0.0, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(fondo, "scale", Vector2(1.0, 1.0), 0.7)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	#Shake sutil de cámara mientras suenan los "fuegos"
	tween.parallel().tween_callback(_shake_pantalla)


	tween.tween_callback(func():
		flash.queue_free()
		panel_nombre.visible = true
		panel_texto.visible = true
		_mostrar_dialogo(indice_dialogo)
	)


func _shake_pantalla() -> void:
	var pos_original := fondo.position
	var shake := create_tween()
	for i in range(6):
		var offset := Vector2(randf_range(-8, 8), randf_range(-8, 8))
		shake.tween_property(fondo, "position", pos_original + offset, 0.04)
	shake.tween_property(fondo, "position", pos_original, 0.05)


func _lanzar_fuegos_artificiales() -> void:
	var particulas := CPUParticles2D.new()
	particulas.position = Vector2(960, 400)  #centro-arriba de la pantalla
	particulas.emitting = true
	particulas.one_shot = true
	particulas.explosiveness = 0.9
	particulas.amount = 60
	particulas.lifetime = 1.1
	particulas.direction = Vector2(0, -1)
	particulas.spread = 180.0
	particulas.gravity = Vector2(0, 250)
	particulas.initial_velocity_min = 150.0
	particulas.initial_velocity_max = 350.0
	particulas.scale_amount_min = 4.0
	particulas.scale_amount_max =10.0
	particulas.color = Color(1.0, 0.85, 0.3)  #dorado
	capa_ui.add_child(particulas)

	#Auto-limpieza después de que terminen
	get_tree().create_timer(particulas.lifetime + 0.3).timeout.connect(
		func(): particulas.queue_free()
	)

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
	panel.self_modulate = Color(1, 1, 1, 0.65)
	capa_ui.add_child(panel)
	panel_nombre = panel

	caja_nombre = Label.new()
	caja_nombre.add_theme_font_size_override("font_size", 28)
	caja_nombre.add_theme_color_override("font_color", Color(0.85, 0.15, 0.15))
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
	panel.self_modulate = Color(1, 1, 1, 0.65)
	panel_texto = panel

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
	if not despierto:
		return
	if event.is_action_pressed("ui_accept") and not event.is_echo():
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
