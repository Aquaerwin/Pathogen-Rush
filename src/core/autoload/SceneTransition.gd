extends CanvasLayer

# ==============================================================================
# SIGNALS
# ==============================================================================
signal transition_finished

# ==============================================================================
# PUBLIC VARIABLES
# ==============================================================================
var color_rect: ColorRect
var logo: TextureRect


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Tetap berjalan walau game di-pause (agar bisa kembali ke menu)
	layer = 100 # Pastikan efek transisi selalu di atas segalanya (GUI tertinggi)
	
	color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 0) # Warna hitam transparan di awal
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(color_rect)
	
	logo = TextureRect.new()
	logo.texture = load("res://assets/logo/logoGame.png")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.set_anchors_preset(Control.PRESET_FULL_RECT)
	logo.modulate.a = 0.0
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.add_child(logo)


# ==============================================================================
# FUNGSI KUSTOM (Custom Methods)
# ==============================================================================
# Mengubah layar/scene dengan efek layar memudar ke hitam lalu perlahan terang kembali
func change_scene(target_path: String):
	# Aktifkan tangkapan mouse agar pemain tidak bisa mengklik tombol lain secara tidak sengaja saat transisi berlangsung
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var is_level = "Level" in target_path and "Select" not in target_path
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(color_rect, "color:a", 1.0, 0.5) # Layar perlahan gelap total selama 0.5 detik
	if is_level:
		tween.tween_property(logo, "modulate:a", 1.0, 0.5)
	await tween.finished
	
	# Pindah scene saat layar gelap total
	get_tree().change_scene_to_file(target_path)
	
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.tween_property(color_rect, "color:a", 0.0, 0.5) # Layar hitam memudar
	
	if is_level:
		# Jika masuk ke arena, logo ditahan selama 2 detik lalu baru memudar
		var tween3 = create_tween()
		tween3.tween_interval(2.0)
		tween3.tween_property(logo, "modulate:a", 0.0, 0.5)
		await tween3.finished
	else:
		await tween2.finished
		
	# Matikan tangkapan mouse agar pemain bisa kembali bermain
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_finished.emit()
