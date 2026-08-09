extends Node2D

var dialogos := [
	{"Name": "Horse", "text": "You did it!"},
	{"Name": "Horse", "text": "We are going to have a prosperous new year thanks to you."},
]

const ESCENA_MENU := "res://main_menu.tscn"
@export var velocidad_letra: float = 0.03

const ANCHO_PANTALLA := 1920
const ALTO_PANTALLA := 1080
const ANCHO_CAJA_TEXTO := 1600
const ALTO_CAJA_TEXTO := 260
const Y_CAJA_TEXTO := 760
const ANCHO_CAJA_NOMBRE := 280
const ALTO_CAJA_NOMBRE := 80
const ESPACIO_ENTRE_CAJAS := 0

@onready var boton_menu = $BotonMenu

var capa_ui: CanvasLayer
var capa_fuegos: Node2D
var imagen_fondo: TextureRect
var panel_nombre: PanelContainer
var panel_texto: PanelContainer
var caja_texto: RichTextLabel
var caja_nombre: Label
var indicador: Label

var textura_particula: Texture2D
var timer_fuegos: Timer

var colores_fuegos := [
	Color(1.0, 0.42, 0.62),
	Color(0.35, 0.9, 0.82),
	Color(1.0, 0.55, 0.15),
	Color(1.0, 0.85, 0.25),
	Color(0.9, 0.2, 0.25),
]

var zonas_esquinas := [
	{"x_min": 60, "x_max": 340, "y_min": 60, "y_max": 260},
	{"x_min": ANCHO_PANTALLA - 340, "x_max": ANCHO_PANTALLA - 60, "y_min": 60, "y_max": 260},
	{"x_min": 60, "x_max": 340, "y_min": ALTO_PANTALLA - 460, "y_max": ALTO_PANTALLA - 260},
	{"x_min": ANCHO_PANTALLA - 340, "x_max": ANCHO_PANTALLA - 60, "y_min": ALTO_PANTALLA - 460, "y_max": ALTO_PANTALLA - 260},
]

var indice_dialogo := 0
var escribiendo := false
var tween_texto: Tween
var tween_indicador: Tween


func _ready() -> void:
	boton_menu.pressed.connect(func(): get_tree().change_scene_to_file(ESCENA_MENU))
	boton_menu.visible = false

	capa_ui = CanvasLayer.new()
	capa_ui.layer = 1
	add_child(capa_ui)

	imagen_fondo = TextureRect.new()
	imagen_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	imagen_fondo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	imagen_fondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagen_fondo.texture = load("res://images/fondo13.png")
	capa_ui.add_child(imagen_fondo)

	_crear_textura_particula()
	_crear_capa_fuegos()
	_crear_caja_nombre()
	_crear_caja_texto()
	_crear_indicador()

	boton_menu.get_parent().remove_child(boton_menu)
	capa_ui.add_child(boton_menu)

	_animar_fondo()
	_iniciar_fuegos_artificiales()
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
	panel.self_modulate = Color(1, 1, 1, 0.65)
	capa_ui.add_child(panel)
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


func _animar_fondo() -> void:
	imagen_fondo.pivot_offset = Vector2(ANCHO_PANTALLA / 2.0, ALTO_PANTALLA / 2.0)
	imagen_fondo.scale = Vector2(1.03, 1.03)
	imagen_fondo.position = Vector2(-10, -6)

	var mov := create_tween()
	mov.set_loops()
	mov.tween_property(imagen_fondo, "scale", Vector2(1.06, 1.06), 4.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	mov.parallel().tween_property(imagen_fondo, "position", Vector2(12, 5), 4.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	mov.tween_property(imagen_fondo, "scale", Vector2(1.02, 1.02), 4.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	mov.parallel().tween_property(imagen_fondo, "position", Vector2(-10, -10), 4.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	mov.tween_property(imagen_fondo, "scale", Vector2(1.03, 1.03), 3.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	mov.parallel().tween_property(imagen_fondo, "position", Vector2(-10, -6), 3.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _crear_textura_particula() -> void:
	var img := Image.create(12, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0))
	for y in range(12):
		for x in range(12):
			if Vector2(x - 5.5, y - 5.5).length() <= 5.5:
				img.set_pixel(x, y, Color(1, 1, 1, 1))
	textura_particula = ImageTexture.create_from_image(img)


func _crear_capa_fuegos() -> void:
	capa_fuegos = Node2D.new()
	capa_ui.add_child(capa_fuegos)


func _iniciar_fuegos_artificiales() -> void:
	timer_fuegos = Timer.new()
	timer_fuegos.one_shot = true
	add_child(timer_fuegos)
	timer_fuegos.timeout.connect(_on_timer_fuegos_timeout)
	_on_timer_fuegos_timeout()


func _on_timer_fuegos_timeout() -> void:
	_lanzar_fuego_artificial()
	timer_fuegos.wait_time = randf_range(1.2, 2.4)
	timer_fuegos.start()


func _lanzar_fuego_artificial() -> void:
	var zona: Dictionary = zonas_esquinas[randi() % zonas_esquinas.size()]
	var x := randf_range(zona["x_min"], zona["x_max"])
	var y_destino := randf_range(zona["y_min"], zona["y_max"])
	var color: Color = colores_fuegos[randi() % colores_fuegos.size()]
	var duracion_subida := randf_range(0.5, 0.75)

	var cohete := Sprite2D.new()
	cohete.texture = textura_particula
	cohete.position = Vector2(x + randf_range(-10, 10), ALTO_PANTALLA + 20)
	cohete.scale = Vector2(0.22, 0.22)
	cohete.modulate = Color(1.0, 1.0, 0.85, 0.55)
	capa_fuegos.add_child(cohete)

	var subida := create_tween()
	subida.tween_property(cohete, "position", Vector2(x, y_destino), duracion_subida)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	subida.parallel().tween_property(cohete, "modulate:a", 0.0, duracion_subida)\
		.set_delay(duracion_subida * 0.6)
	await subida.finished

	cohete.queue_free()
	_explosion(Vector2(x, y_destino), color)


func _explosion(pos: Vector2, color: Color) -> void:
	var particulas := CPUParticles2D.new()
	particulas.texture = textura_particula
	particulas.position = pos
	particulas.amount = 36
	particulas.lifetime = 0.9
	particulas.one_shot = true
	particulas.emitting = true
	particulas.explosiveness = 1.0
	particulas.direction = Vector2(0, -1)
	particulas.spread = 180
	particulas.initial_velocity_min = 60
	particulas.initial_velocity_max = 130
	particulas.gravity = Vector2(0, 180)
	particulas.scale_amount_min = 0.7
	particulas.scale_amount_max = 1.3
	particulas.color = color

	var degradado := Gradient.new()
	degradado.offsets = PackedFloat32Array([0.0, 0.7, 1.0])
	degradado.colors = PackedColorArray([
		Color(color.r, color.g, color.b, 0.55),
		Color(color.r, color.g, color.b, 0.5),
		Color(color.r, color.g, color.b, 0.0),
	])
	particulas.color_ramp = degradado

	capa_fuegos.add_child(particulas)
	particulas.finished.connect(particulas.queue_free)

	var destello := Sprite2D.new()
	destello.texture = textura_particula
	destello.position = pos
	destello.modulate = Color(1, 1, 1, 0.4)
	destello.scale = Vector2(0.3, 0.3)
	capa_fuegos.add_child(destello)
	var t := create_tween()
	t.tween_property(destello, "scale", Vector2(1.8, 1.8), 0.2)
	t.parallel().tween_property(destello, "modulate:a", 0.0, 0.2)
	t.tween_callback(destello.queue_free)


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
		panel_nombre.visible = false
		panel_texto.visible = false
		indicador.visible = false
		boton_menu.visible = true
		return
	_mostrar_dialogo(indice_dialogo)
