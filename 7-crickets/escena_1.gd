extends Node2D

var panel_settings: Control
var abierto := false

func _ready() -> void:
	var pantalla := Vector2(1920, 1080)
	var margen := 80

	# Fondo (placeholder amarillo)
	var fondo := ColorRect.new()
	fondo.color = Color(1, 0.92, 0.2)
	fondo.size = pantalla
	add_child(fondo)

	# Personaje (cuadrado rojo placeholder) - centrado
	var personaje_size := Vector2(140, 140)
	var personaje := ColorRect.new()
	personaje.color = Color(0.9, 0.15, 0.15)
	personaje.size = personaje_size
	personaje.position = pantalla / 2 - personaje_size / 2
	add_child(personaje)

	var boton_size := Vector2(90, 90)

	# Flecha izquierda -> puzzle 1
	var flecha_izq := Button.new()
	flecha_izq.text = "<"
	flecha_izq.custom_minimum_size = boton_size
	flecha_izq.position = Vector2(margen, pantalla.y / 2 - boton_size.y / 2)
	flecha_izq.modulate = Color(0.3, 0.5, 1)
	add_child(flecha_izq)
	flecha_izq.pressed.connect(func():
		_cambiar_escena("res://Escenas/PuzzleCartas.tscn")
	)

	# Flecha arriba -> puzzle 2
	var flecha_arriba := Button.new()
	flecha_arriba.text = "^"
	flecha_arriba.custom_minimum_size = boton_size
	flecha_arriba.position = Vector2(pantalla.x / 2 - boton_size.x / 2, margen)
	flecha_arriba.modulate = Color(0.3, 0.9, 0.4)
	add_child(flecha_arriba)
	flecha_arriba.pressed.connect(func():
		_cambiar_escena("res://Escenas/PuzzleQueen.tscn")
	)

	# Flecha derecha -> puzzle 3
	var flecha_der := Button.new()
	flecha_der.text = ">"
	flecha_der.custom_minimum_size = boton_size
	flecha_der.position = Vector2(pantalla.x - margen - boton_size.x, pantalla.y / 2 - boton_size.y / 2)
	flecha_der.modulate = Color(0.7, 0.3, 0.9)
	add_child(flecha_der)
	flecha_der.pressed.connect(func():
		_cambiar_escena("res://Escenas/PuzzleSimon.tscn")
	)

	_crear_boton_settings()
	_crear_panel_settings()

	# --- FADE DE ENTRADA ---
	var capa := CanvasLayer.new()
	capa.layer = 100
	add_child(capa)

	var fade_in := ColorRect.new()
	fade_in.color = Color(0, 0, 0, 1)
	fade_in.size = get_viewport_rect().size
	fade_in.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(fade_in)

	var tween_in := create_tween()
	tween_in.tween_property(fade_in, "color:a", 0.0, 0.6)
	tween_in.tween_callback(capa.queue_free)


# --- BOTÓN DE TUERCA (esquina superior derecha) ---
func _crear_boton_settings() -> void:
	var btn := Button.new()
	btn.text = "⚙" # placeholder de ícono, luego se reemplaza por un TextureButton con la tuerca real
	btn.custom_minimum_size = Vector2(70, 70)
	btn.position = Vector2(1920 - 70 - 30, 30)
	btn.modulate = Color(0.6, 0.6, 0.6)
	btn.z_index = 50
	add_child(btn)
	btn.pressed.connect(_toggle_settings)


# --- PANEL DE SETTINGS (oculto por defecto, con animación) ---
func _crear_panel_settings() -> void:
	panel_settings = Panel.new()
	panel_settings.size = Vector2(420, 320)
	panel_settings.position = Vector2(1920 - 420 - 30, 120)
	panel_settings.pivot_offset = Vector2(210, 0) # pivote arriba-centro para el efecto de apertura
	panel_settings.scale = Vector2(1, 0)
	panel_settings.modulate.a = 0
	panel_settings.z_index = 49
	add_child(panel_settings)

	var contenedor := VBoxContainer.new()
	contenedor.position = Vector2(30, 20)
	contenedor.size = Vector2(360, 280)
	contenedor.add_theme_constant_override("separation", 18)
	panel_settings.add_child(contenedor)

	var titulo := Label.new()
	titulo.text = "Configuración"
	titulo.add_theme_font_size_override("font_size", 24)
	contenedor.add_child(titulo)

	# Volumen general (Master)
	var label_master := Label.new()
	label_master.text = "Volumen general"
	contenedor.add_child(label_master)

	var slider_master := HSlider.new()
	slider_master.min_value = 0
	slider_master.max_value = 1
	slider_master.step = 0.01
	slider_master.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	slider_master.custom_minimum_size = Vector2(360, 20)
	contenedor.add_child(slider_master)
	slider_master.value_changed.connect(func(v):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(v))
	)

	# Volumen de música (bus "Music" - ajustar nombre si tu proyecto usa otro)
	var label_musica := Label.new()
	label_musica.text = "Volumen de música"
	contenedor.add_child(label_musica)

	var slider_musica := HSlider.new()
	slider_musica.min_value = 0
	slider_musica.max_value = 1
	slider_musica.step = 0.01
	var idx_music := AudioServer.get_bus_index("Music")
	slider_musica.value = 1.0 if idx_music == -1 else db_to_linear(AudioServer.get_bus_volume_db(idx_music))
	slider_musica.custom_minimum_size = Vector2(360, 20)
	contenedor.add_child(slider_musica)
	slider_musica.value_changed.connect(func(v):
		var idx := AudioServer.get_bus_index("Music")
		if idx != -1:
			AudioServer.set_bus_volume_db(idx, linear_to_db(v))
	)

	# Botón salir al menú principal
	var btn_salir := Button.new()
	btn_salir.text = "Salir al menú principal"
	btn_salir.custom_minimum_size = Vector2(360, 50)
	contenedor.add_child(btn_salir)
	btn_salir.pressed.connect(func():
		_cambiar_escena("res://Escenas/main_menu.tscn")
	)


func _toggle_settings() -> void:
	abierto = not abierto
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	if abierto:
		tween.tween_property(panel_settings, "scale:y", 1.0, 0.35)
		tween.parallel().tween_property(panel_settings, "modulate:a", 1.0, 0.25)
	else:
		tween.tween_property(panel_settings, "scale:y", 0.0, 0.25)
		tween.parallel().tween_property(panel_settings, "modulate:a", 0.0, 0.2)


func _cambiar_escena(ruta: String) -> void:
	var capa := CanvasLayer.new()
	capa.layer = 100
	add_child(capa)

	var fade := ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.size = get_viewport_rect().size
	capa.add_child(fade)

	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.4)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(ruta)
	)
