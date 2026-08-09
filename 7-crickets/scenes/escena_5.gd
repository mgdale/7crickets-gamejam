extends Node2D

@export var escena_siguiente: String = "res://scenes/escena_6.tscn"
@onready var boton_siguiente = $NextButton

var capa_ui: CanvasLayer
var imagen_fondo: TextureRect
var glow: TextureRect
var ya_avanzando := false
var listo_para_avanzar := false


func _ready() -> void:
	boton_siguiente.pressed.connect(func(): _cambiar_escena(escena_siguiente))
	boton_siguiente.visible = false

	capa_ui = CanvasLayer.new()
	capa_ui.layer = 1
	add_child(capa_ui)

	_crear_telon_fondo()
	_crear_resplandor()

	imagen_fondo = TextureRect.new()
	imagen_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	imagen_fondo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	imagen_fondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagen_fondo.texture = load("res://images/pulsera_original.png")
	imagen_fondo.pivot_offset = Vector2(960, 540)
	imagen_fondo.modulate = Color(1, 1, 1, 0)
	imagen_fondo.scale = Vector2(0.85, 0.85)
	capa_ui.add_child(imagen_fondo)

	#boton sobre el fondo!!!!!!!!!!!
	boton_siguiente.get_parent().remove_child(boton_siguiente)
	capa_ui.add_child(boton_siguiente)

	await _entrada_celestial()
	listo_para_avanzar = true
	boton_siguiente.visible = true
	_respiracion_idle()


func _crear_telon_fondo() -> void:
	#cubre TODA la pantalla siempre, sin escalarse nunca,
	var telon := ColorRect.new()
	telon.color = Color(0.04, 0.05, 0.1)  # noche oscura, va bien con el tono celestial
	telon.set_anchors_preset(Control.PRESET_FULL_RECT)
	telon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa_ui.add_child(telon)


func _crear_resplandor() -> void:
	var degradado := Gradient.new()
	degradado.set_color(0, Color(1.0, 0.95, 0.75, 0.9))
	degradado.set_color(1, Color(1.0, 0.95, 0.75, 0.0))

	var textura_glow := GradientTexture2D.new()
	textura_glow.gradient = degradado
	textura_glow.fill = GradientTexture2D.FILL_RADIAL
	textura_glow.fill_from = Vector2(0.5, 0.5)
	textura_glow.fill_to = Vector2(1.0, 0.5)
	textura_glow.width = 900
	textura_glow.height = 900

	glow = TextureRect.new()
	glow.texture = textura_glow
	glow.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.modulate = Color(1, 1, 1, 0)
	capa_ui.add_child(glow)


func _entrada_celestial() -> void:
	var tween := create_tween()

	tween.set_parallel(true)
	tween.tween_property(imagen_fondo, "modulate:a", 1.0, 0.8)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(imagen_fondo, "scale", Vector2(1.0, 1.0), 1.1)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(glow, "modulate:a", 1.0, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished

	_lanzar_brillos()

	var tween_pulso := create_tween()
	tween_pulso.set_loops()
	tween_pulso.tween_property(glow, "modulate:a", 0.55, 1.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_pulso.tween_property(glow, "modulate:a", 1.0, 1.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _respiracion_idle() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(imagen_fondo, "scale", Vector2(1.02, 1.02), 1.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(imagen_fondo, "scale", Vector2(1.0, 1.0), 1.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _lanzar_brillos() -> void:
	var particulas := CPUParticles2D.new()
	particulas.position = Vector2(960, 540)
	particulas.emitting = true
	particulas.amount = 26
	particulas.lifetime = 2.2
	particulas.preprocess = 1.0
	particulas.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particulas.emission_sphere_radius = 380.0
	particulas.direction = Vector2(0, -1)
	particulas.spread = 180.0
	particulas.gravity = Vector2.ZERO
	particulas.initial_velocity_min = 4.0
	particulas.initial_velocity_max = 14.0
	particulas.scale_amount_min = 2.0
	particulas.scale_amount_max = 5.0

	#El fade in/out de cada partícula 
	var color_ramp := Gradient.new()
	color_ramp.set_color(0, Color(1.0, 0.97, 0.8, 0.0))
	color_ramp.add_point(0.15, Color(1.0, 0.97, 0.8, 1.0))
	color_ramp.add_point(0.85, Color(1.0, 0.97, 0.8, 1.0))
	color_ramp.set_color(color_ramp.get_point_count() - 1, Color(1.0, 0.97, 0.8, 0.0))
	particulas.color_ramp = color_ramp

	capa_ui.add_child(particulas)


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
