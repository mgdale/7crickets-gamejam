extends Node

signal cerrado

var textura_caja: Texture2D = load("res://images/caja_texto.png")
var fuente_titulo: Font = load("res://fonts/chinese rocks rg.otf")
var fuente_texto: Font = load("res://fonts/Chinese_Ruler.ttf")


func mostrar(textura_personaje: Texture2D, titulo: String, texto: String) -> void:
	var capa := CanvasLayer.new()
	capa.layer = 400
	get_tree().current_scene.add_child(capa)

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	capa.add_child(overlay)

	var t_fade := create_tween()
	t_fade.tween_property(overlay, "color", Color(0, 0, 0, 0.55), 0.2)

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
	estilo.modulate_color = Color(1, 1, 1, 0.95)
	panel.add_theme_stylebox_override("panel", estilo)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -560
	panel.offset_right = 560
	panel.offset_top = -280
	panel.offset_bottom = 280
	panel.pivot_offset = Vector2(560, 280)
	panel.scale = Vector2(0.8, 0.8)
	panel.modulate.a = 0
	overlay.add_child(panel)

	var t_pop := create_tween()
	t_pop.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t_pop.parallel().tween_property(panel, "modulate:a", 1.0, 0.2)

	# fila: personaje a la izquierda, texto a la derecha
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 20)
	panel.add_child(fila)

	var personaje := TextureRect.new()
	personaje.texture = textura_personaje
	personaje.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	personaje.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	personaje.custom_minimum_size = Vector2(560, 560)
	personaje.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fila.add_child(personaje)

	var columna := VBoxContainer.new()
	columna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columna.alignment = BoxContainer.ALIGNMENT_CENTER
	columna.add_theme_constant_override("separation", 20)
	fila.add_child(columna)
	fila.move_child(personaje, 1)

	var lbl_titulo := Label.new()
	lbl_titulo.text = titulo
	lbl_titulo.add_theme_font_size_override("font_size", 44)
	lbl_titulo.add_theme_color_override("font_color", Color(0.35, 0.1, 0.1))
	lbl_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD
	if fuente_titulo:
		lbl_titulo.add_theme_font_override("font", fuente_titulo)
	columna.add_child(lbl_titulo)

	var lbl_texto := Label.new()
	lbl_texto.text = texto
	lbl_texto.add_theme_font_size_override("font_size", 30)
	lbl_texto.add_theme_color_override("font_color", Color(0.35, 0.1, 0.1))
	lbl_texto.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl_texto.custom_minimum_size = Vector2(520, 0)
	lbl_texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if fuente_texto:
		lbl_texto.add_theme_font_override("font", fuente_texto)
	columna.add_child(lbl_texto)

	var verde := Color(0.15, 0.55, 0.2)
	var boton := Button.new()
	boton.text = "✓"
	boton.custom_minimum_size = Vector2(90, 90)
	boton.add_theme_font_size_override("font_size", 48)
	boton.add_theme_color_override("font_color", verde)
	boton.add_theme_color_override("font_hover_color", verde.lightened(0.25))
	boton.focus_mode = Control.FOCUS_NONE
	boton.flat = true
	boton.size_flags_horizontal = Control.SIZE_SHRINK_END
	columna.add_child(boton)

	boton.pressed.connect(func():
		var t_cierre := create_tween()
		t_cierre.tween_property(overlay, "modulate:a", 0.0, 0.15)
		t_cierre.tween_callback(func():
			capa.queue_free()
			cerrado.emit()
		)
	)

	await cerrado
