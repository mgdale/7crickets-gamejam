extends Control

const ESCENA_17 := "res://scenes/escena_17.tscn"
@onready var botones = [$Button1, $Button2, $Button3, $Button4, $Button5]

var secuencia = []
var input_jugador = []
var ronda = 1
var mostrando = false

# --- Intro: personaje, titulo y dialogo (mismo estilo visual que Memory) ---
var textura_personaje: Texture2D = load("res://images/tigre.png")
var textura_caja: Texture2D = load("res://images/caja_texto.png")
var fuente_titulo: Font = load("res://fonts/chinese rocks rg.otf")
var fuente_dialogo: Font = load("res://fonts/Chinese_Ruler.ttf")

@export var titulo_texto: String = "Tiger says"
@export var personaje_tamano: Vector2 = Vector2(560, 560)
@export var personaje_offset_y: float = -50.0
@export var personaje_duracion_caminata: float = 2.2
@export var personaje_duracion_por_texto: float = 2.4

var dialogos_personaje := [
	"Hello, young grass hopper, you look worried! That's bad for your health!",
	"Some herbal tea and the wisdom of ancient Chinese medicine can help you.\nJust remember: you always have to apply it in the correct order"
]


@export var tamano_charm: Vector2 = Vector2(150, 150)

var personaje_actual: TextureRect = null


func _ready():
	for i in range(botones.size()):
		botones[i].pressed.connect(_on_boton_pressed.bind(i))

	_fijar_tamano_charms()
	_crear_titulo()
	_configurar_hover_charms()
	await _mostrar_personaje()

	nueva_ronda()


func _fijar_tamano_charms() -> void:
	# Sin importar que este causando el achicado (estado "pressed" del theme,
	# recalculo de minimum_size, etc.), esto lo corrige: cada vez que el boton
	# intenta cambiar de tamano, lo devolvemos al tamano fijo que definimos.
	for boton in botones:
		if boton is TextureButton:
			boton.ignore_texture_size = true
			boton.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		boton.custom_minimum_size = tamano_charm
		boton.size = tamano_charm
		boton.pivot_offset = tamano_charm / 2
		boton.resized.connect(_on_charm_resized.bind(boton))


func _on_charm_resized(boton: Control) -> void:
	if boton.size != tamano_charm:
		boton.size = tamano_charm
		boton.pivot_offset = tamano_charm / 2


func _crear_titulo() -> void:
	var panel := PanelContainer.new()
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura_caja
	estilo.texture_margin_left = 50
	estilo.texture_margin_right = 50
	estilo.texture_margin_top = 25
	estilo.texture_margin_bottom = 25
	estilo.content_margin_left = 30
	estilo.content_margin_right = 30
	estilo.content_margin_top = 18
	estilo.content_margin_bottom = 18
	estilo.modulate_color = Color(1, 1, 1, 0.6)
	panel.add_theme_stylebox_override("panel", estilo)

	var viewport_size := get_viewport_rect().size
	var ancho := 380.0
	var alto := 100.0
	panel.position = Vector2((viewport_size.x - ancho) / 2.0, 30.0)
	panel.size = Vector2(ancho, alto)
	add_child(panel)

	var titulo := Label.new()
	titulo.text = titulo_texto
	titulo.add_theme_font_size_override("font_size", 32)
	titulo.add_theme_color_override("font_color", Color(0.35, 0.1, 0.1))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	titulo.autowrap_mode = TextServer.AUTOWRAP_WORD
	if fuente_titulo:
		titulo.add_theme_font_override("font", fuente_titulo)
	panel.add_child(titulo)


func _mostrar_personaje() -> void:
	var viewport_size := get_viewport_rect().size

	var personaje := TextureRect.new()
	personaje.texture = textura_personaje
	personaje.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	personaje.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	personaje.custom_minimum_size = personaje_tamano
	personaje.size = personaje_tamano
	add_child(personaje)
	move_child(personaje, 1)
	personaje_actual = personaje

	var y_inicio := viewport_size.y / 2.0
	var x_inicio := -personaje_tamano.x
	var x_final := viewport_size.x - personaje_tamano.x - 40.0
	var y_final := viewport_size.y - personaje_tamano.y - 20.0

	personaje.position = Vector2(x_inicio, y_inicio + personaje_offset_y)

	var tween_mov := create_tween()
	tween_mov.set_parallel(true)
	tween_mov.tween_property(personaje, "position:x", x_final, personaje_duracion_caminata)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_mov.tween_property(personaje, "position:y", y_final + personaje_offset_y, personaje_duracion_caminata)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween_mov.finished

	await _hablar_personaje(personaje)

	var t_oscurecer := create_tween()
	t_oscurecer.tween_property(personaje, "modulate", Color(0.55, 0.55, 0.55, 0.55), 0.4)
	await t_oscurecer.finished


func _hablar_personaje(personaje: TextureRect) -> void:
	var burbuja := PanelContainer.new()
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura_caja
	estilo.texture_margin_left = 40
	estilo.texture_margin_right = 40
	estilo.texture_margin_top = 20
	estilo.texture_margin_bottom = 20
	estilo.content_margin_left = 35
	estilo.content_margin_right = 35
	estilo.content_margin_top = 18
	estilo.content_margin_bottom = 18
	estilo.modulate_color = Color(1, 1, 1, 0.6)
	burbuja.add_theme_stylebox_override("panel", estilo)
	burbuja.z_index = 5
	burbuja.custom_minimum_size = Vector2(360, 150)
	burbuja.size = Vector2(360, 150)
	burbuja.pivot_offset = Vector2(180, 75)
	personaje.add_child(burbuja)
	burbuja.position = Vector2(personaje_tamano.x / 2.0 - 180, -170)
	burbuja.modulate.a = 0
	burbuja.scale = Vector2(0.7, 0.7)

	var texto := Label.new()
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD
	texto.add_theme_font_size_override("font_size", 24)
	texto.add_theme_color_override("font_color", Color(0.35, 0.1, 0.1))
	if fuente_dialogo:
		texto.add_theme_font_override("font", fuente_dialogo)
	burbuja.add_child(texto)

	personaje.pivot_offset = Vector2(personaje_tamano.x / 2.0, personaje_tamano.y)
	var personaje_y_base := personaje.position.y

	for i in range(dialogos_personaje.size()):
		texto.text = dialogos_personaje[i]

		var t := create_tween()
		if i == 0:
			t.tween_property(burbuja, "modulate:a", 1.0, 0.2)
			t.parallel().tween_property(burbuja, "scale", Vector2(1.0, 1.0), 0.2)\
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else:
			var y_base := burbuja.position.y
			t.tween_property(burbuja, "position:y", y_base - 18, 0.12)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			t.tween_property(burbuja, "position:y", y_base, 0.15)\
				.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			t.parallel().tween_property(personaje, "position:y", personaje_y_base - 22, 0.12)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			t.chain().tween_property(personaje, "position:y", personaje_y_base, 0.15)\
				.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		await t.finished
		await get_tree().create_timer(personaje_duracion_por_texto).timeout

	var t_fin := create_tween()
	t_fin.tween_property(burbuja, "modulate:a", 0.0, 0.25)
	await t_fin.finished
	burbuja.queue_free()


func _tigre_dice(mensaje: String) -> void:
	# Burbuja corta y rapida para reacciones durante el juego (ej. "Keep going!"),
	# distinta de _hablar_personaje que es para la intro larga.
	if personaje_actual == null:
		return

	var burbuja := PanelContainer.new()
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura_caja
	estilo.texture_margin_left = 35
	estilo.texture_margin_right = 35
	estilo.texture_margin_top = 18
	estilo.texture_margin_bottom = 18
	estilo.content_margin_left = 28
	estilo.content_margin_right = 28
	estilo.content_margin_top = 14
	estilo.content_margin_bottom = 14
	estilo.modulate_color = Color(1, 1, 1, 0.85)
	burbuja.add_theme_stylebox_override("panel", estilo)
	burbuja.z_index = 6
	burbuja.custom_minimum_size = Vector2(260, 90)
	burbuja.size = Vector2(260, 90)
	burbuja.pivot_offset = Vector2(130, 45)

	# La agregamos como hija de la escena (no del tigre), para que no herede
	# la transparencia con la que se oscurece al tigre despues de la intro.
	add_child(burbuja)
	burbuja.position = personaje_actual.position + Vector2(
		personaje_tamano.x / 2.0 - 130, -110
	)
	burbuja.modulate.a = 0
	burbuja.scale = Vector2(0.7, 0.7)

	var texto := Label.new()
	texto.text = mensaje
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD
	texto.add_theme_font_size_override("font_size", 24)
	texto.add_theme_color_override("font_color", Color(0.35, 0.1, 0.1))
	if fuente_dialogo:
		texto.add_theme_font_override("font", fuente_dialogo)
	burbuja.add_child(texto)

	var t := create_tween()
	t.tween_property(burbuja, "modulate:a", 1.0, 0.15)
	t.parallel().tween_property(burbuja, "scale", Vector2(1.0, 1.0), 0.15)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_interval(0.9)
	t.tween_property(burbuja, "modulate:a", 0.0, 0.2)
	t.tween_callback(burbuja.queue_free)


func _configurar_hover_charms() -> void:
	# Cuando el mouse pasa por encima de un charm, se agranda un poco
	# para dar a entender que se puede interactuar con el.
	for boton in botones:
		boton.mouse_entered.connect(_on_charm_hover.bind(boton, true))
		boton.mouse_exited.connect(_on_charm_hover.bind(boton, false))


func _on_charm_hover(boton: Button, entrando: bool) -> void:
	var escala_objetivo := Vector2(1.12, 1.12) if entrando else Vector2(1.0, 1.0)
	var t := create_tween()
	t.tween_property(boton, "scale", escala_objetivo, 0.15)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func nueva_ronda():
	input_jugador.clear()
	secuencia.append(randi() % botones.size())
	await mostrar_secuencia()


func mostrar_secuencia():
	mostrando = true
	for paso in secuencia:
		await parpadear(botones[paso])
		await get_tree().create_timer(0.2).timeout
	mostrando = false


func _crear_glow_charm(boton: Control) -> TextureRect:
	var aura_size := tamano_charm * 1.7

	var degradado := Gradient.new()
	degradado.set_color(0, Color(1.0, 0.85, 0.3, 0.9))
	degradado.set_color(1, Color(1.0, 0.85, 0.3, 0.0))

	var textura_glow := GradientTexture2D.new()
	textura_glow.gradient = degradado
	textura_glow.fill = GradientTexture2D.FILL_RADIAL
	textura_glow.fill_from = Vector2(0.5, 0.5)
	textura_glow.fill_to = Vector2(1.0, 0.5)
	textura_glow.width = int(aura_size.x)
	textura_glow.height = int(aura_size.y)

	var glow := TextureRect.new()
	glow.texture = textura_glow
	glow.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.modulate.a = 0.0
	glow.z_index = boton.z_index - 1
	glow.size = aura_size

	var padre := boton.get_parent()
	padre.add_child(glow)
	glow.position = boton.position - (aura_size - boton.size) / 2.0
	return glow


func parpadear(boton):
	var glow := _crear_glow_charm(boton)

	var t_in := create_tween()
	t_in.set_parallel(true)
	t_in.tween_property(glow, "modulate:a", 1.0, 0.08)
	t_in.tween_property(boton, "modulate", Color(1.35, 1.25, 0.55), 0.08)
	t_in.tween_property(boton, "scale", Vector2(1.18, 1.18), 0.08)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await t_in.finished

	await get_tree().create_timer(0.24).timeout

	var t_out := create_tween()
	t_out.set_parallel(true)
	t_out.tween_property(glow, "modulate:a", 0.0, 0.12)
	t_out.tween_property(boton, "modulate", Color.WHITE, 0.12)
	t_out.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.12)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await t_out.finished
	glow.queue_free()


func _on_boton_pressed(indice):
	if mostrando:
		return
	input_jugador.append(indice)
	var paso_actual = input_jugador.size() - 1
	if paso_actual >= secuencia.size():
		reiniciar()
		return
	if input_jugador[paso_actual] != secuencia[paso_actual]:
		reiniciar()
		return
	if input_jugador.size() == secuencia.size():
		if secuencia.size() >= 5:
			GameState.puzzles_solved[GameState.current_puzzle] = true
			var memoria_lista = GameState.puzzles_solved.get("memory", false)
			var find_queen_lista = GameState.puzzles_solved.get("find_queen", false)
			if memoria_lista and find_queen_lista:
				get_tree().change_scene_to_file(ESCENA_17)
			else:
				get_tree().change_scene_to_file(GameState.MAP_SCENE)
		else:
			ronda += 1
			_tigre_dice("Keep going!")
			await get_tree().create_timer(0.6).timeout
			nueva_ronda()


func reiniciar():
	_tigre_dice("Try again!")
	secuencia.clear()
	input_jugador.clear()
	ronda = 1
	nueva_ronda()
