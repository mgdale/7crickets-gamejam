extends Control

@onready var fondo: TextureRect = TextureRect.new()
@onready var main_buttons: Container = %mainButtons



var capa_particulas: Node2D
var textura_particula: Texture2D

var colores_particulas := [
	Color(0.85, 0.15, 0.15),
	Color(0.95, 0.35, 0.25),
	Color(1.0, 0.85, 0.5),
]

var pos_base_botones := Vector2.ZERO


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

	_crear_fondo()
	_crear_particulas_fondo()

	main_buttons.show()
	main_buttons.add_theme_constant_override("separation", 15)

	_subir_botones()
	_configurar_hover_botones()


func _crear_fondo() -> void:
	fondo.texture = load("res://images/menubg.png")
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.offset_left = 0
	fondo.offset_top = 0
	fondo.offset_right = 0
	fondo.offset_bottom = 0
	fondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo.stretch_mode = TextureRect.STRETCH_SCALE
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fondo)
	move_child(fondo, 0)


func _subir_botones() -> void:
	var center_container := $CenterContainer
	if center_container:
		pos_base_botones = center_container.position
		center_container.position.y -= 90


func _configurar_hover_botones() -> void:
	for boton_container in [main_buttons]:
		for hijo in boton_container.get_children():
			if hijo is BaseButton:
				_conectar_hover(hijo)


func _conectar_hover(boton: BaseButton) -> void:
	boton.pivot_offset = boton.size / 2.0
	boton.resized.connect(func(): boton.pivot_offset = boton.size / 2.0)

	boton.mouse_entered.connect(func():
		var t := create_tween()
		t.tween_property(boton, "scale", Vector2(1.08, 1.08), 0.15)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(boton, "modulate", Color(1.15, 1.15, 1.15), 0.15)
	)

	boton.mouse_exited.connect(func():
		var t := create_tween()
		t.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.15)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(boton, "modulate", Color(1, 1, 1), 0.15)
	)

	boton.button_down.connect(func():
		var t := create_tween()
		t.tween_property(boton, "scale", Vector2(0.96, 0.96), 0.08)
	)

	boton.button_up.connect(func():
		var t := create_tween()
		t.tween_property(boton, "scale", Vector2(1.08, 1.08), 0.1)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)

func _cerrar_popup_creditos(overlay: Control, capa: CanvasLayer) -> void:
	var t_cierre := create_tween()
	t_cierre.tween_property(overlay, "modulate:a", 0.0, 0.15)
	t_cierre.tween_callback(func(): capa.queue_free())

func _crear_particulas_fondo() -> void:
	var img := Image.create(10, 10, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0))
	for y in range(10):
		for x in range(10):
			if Vector2(x - 4.5, y - 4.5).length() <= 4.5:
				img.set_pixel(x, y, Color(1, 1, 1, 1))
	textura_particula = ImageTexture.create_from_image(img)

	capa_particulas = Node2D.new()
	add_child(capa_particulas)
	move_child(capa_particulas, 1)

	for i in range(3):
		var color: Color = colores_particulas[i % colores_particulas.size()]
		var particulas := CPUParticles2D.new()
		particulas.texture = textura_particula
		particulas.position = Vector2(960, 540)
		particulas.amount = 30
		particulas.lifetime = randf_range(5.0, 8.0)
		particulas.preprocess = 6.0
		particulas.emitting = true
		particulas.direction = Vector2(0, -1)
		particulas.spread = 180
		particulas.gravity = Vector2.ZERO
		particulas.initial_velocity_min = 6
		particulas.initial_velocity_max = 18
		particulas.scale_amount_min = 0.9
		particulas.scale_amount_max = 1.8
		particulas.color = Color(color.r, color.g, color.b, 0.65)
		particulas.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		particulas.emission_rect_extents = Vector2(980, 560)

		var degradado := Gradient.new()
		degradado.offsets = PackedFloat32Array([0.0, 0.15, 0.85, 1.0])
		degradado.colors = PackedColorArray([
			Color(color.r, color.g, color.b, 0.0),
			Color(color.r, color.g, color.b, 0.7),
			Color(color.r, color.g, color.b, 0.7),
			Color(color.r, color.g, color.b, 0.0),
		])
		particulas.color_ramp = degradado

		capa_particulas.add_child(particulas)


func _on_play_pressed() -> void:
	MusicManager.reproducir_musica("res://music/soundtrack_suave.mp3")
	
	var fade := ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.size = get_viewport_rect().size
	fade.z_index = 100
	add_child(fade)
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.5)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/escena_1.tscn")
	)


func _on_credits_pressed() -> void:
	var textura_caja = load("res://images/caja_texto.png")
	var fuente_dialogo = load("res://fonts/Chinese_Ruler.ttf")

	var capa := CanvasLayer.new()
	capa.layer = 200
	add_child(capa)

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	capa.add_child(overlay)

	var t_fade := create_tween()
	t_fade.tween_property(overlay, "color", Color(0, 0, 0, 0.5), 0.2)

	var panel := PanelContainer.new()
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura_caja
	estilo.texture_margin_left = 60
	estilo.texture_margin_right = 60
	estilo.texture_margin_top = 40
	estilo.texture_margin_bottom = 40
	estilo.content_margin_left = 50
	estilo.content_margin_right = 50
	estilo.content_margin_top = 35
	estilo.content_margin_bottom = 35
	estilo.modulate_color = Color(1, 1, 1, 0.9)
	panel.add_theme_stylebox_override("panel", estilo)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -400
	panel.offset_right = 400
	panel.offset_top = -250
	panel.offset_bottom = 250
	panel.pivot_offset = Vector2(400, 250)
	panel.scale = Vector2(0.7, 0.7)
	panel.modulate.a = 0
	overlay.add_child(panel)

	var t_pop := create_tween()
	t_pop.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t_pop.parallel().tween_property(panel, "modulate:a", 1.0, 0.2)

	var contenido := VBoxContainer.new()
	contenido.add_theme_constant_override("separation", 20)
	contenido.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(contenido)

	var titulo := Label.new()
	titulo.text = "Credits"
	titulo.add_theme_font_size_override("font_size", 36)
	titulo.add_theme_color_override("font_color", Color(0.35, 0.1, 0.1))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if fuente_dialogo:
		titulo.add_theme_font_override("font", fuente_dialogo)
	contenido.add_child(titulo)

	var texto_creditos := Label.new()
	texto_creditos.text = "Programming: \nMigdaly Badilla & Nicolle Hernández\nArt: \nCarolina Reyes & Jimena Castillo"  # ajusta el texto real
	texto_creditos.add_theme_font_size_override("font_size", 54)
	texto_creditos.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	texto_creditos.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto_creditos.autowrap_mode = TextServer.AUTOWRAP_WORD
	if fuente_dialogo:
		texto_creditos.add_theme_font_override("font", fuente_dialogo)
	contenido.add_child(texto_creditos)

	var boton_original = $CenterContainer/back
	var boton_cerrar = boton_original.duplicate()
	boton_cerrar.visible = true
	contenido.add_child(boton_cerrar)

	if not boton_cerrar.is_connected("pressed", Callable(self, "_cerrar_popup_creditos")):
		boton_cerrar.pressed.connect(_cerrar_popup_creditos.bind(overlay, capa))

func _on_quit_pressed() -> void:
	get_tree().quit()
