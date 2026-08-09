extends Control

func _ready() -> void:
	%mainButtons.show()
	%creditsMenu.hide()

	%mainButtons.add_theme_constant_override("separation", 15)
	%creditsMenu.add_theme_constant_override("separation", 15)

	var btn_back_credits = $CenterContainer/creditsMenu/back
	if btn_back_credits:
		if not btn_back_credits.is_connected("pressed", Callable(self, "_on_back_pressed")):
			btn_back_credits.pressed.connect(_on_back_pressed)

#navegacaion principal 
func _on_play_pressed() -> void:
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
	%mainButtons.hide()
	%creditsMenu.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

# regreso
func _on_back_pressed() -> void:
	%creditsMenu.hide()
	%mainButtons.show()
