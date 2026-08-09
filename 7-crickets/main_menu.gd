extends Control

@onready var fondo: TextureRect = TextureRect.new()
@onready var main_buttons: Container = %mainButtons
@onready var credits_menu: Container = %creditsMenu



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
	credits_menu.hide()
	main_buttons.add_theme_constant_override("separation", 15)
	credits_menu.add_theme_constant_override("separation", 15)

	var btn_back_credits = $CenterContainer/creditsMenu/back
	if btn_back_credits:
		if not btn_back_credits.is_connected("pressed", Callable(self, "_on_back_pressed")):
			btn_back_credits.pressed.connect(_on_back_pressed)

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
	for boton_container in [main_buttons, credits_menu]:
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
	main_buttons.hide()
	credits_menu.show()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	credits_menu.hide()
	main_buttons.show()
