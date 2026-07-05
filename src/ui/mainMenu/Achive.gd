extends ColorRect

# ==============================================================================
# @ONREADY VARIABLES
# ==============================================================================
@onready var panel_window = $PanelWindow
@onready var btn_oke = $PanelWindow/BtnOke
@onready var txt_oke = $PanelWindow/BtnOke/TxtOke
@onready var label_judul = $PanelWindow/LabelJudul
@onready var grid_container = $PanelWindow/ScrollContainer/GridContainer


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	panel_window.pivot_offset = panel_window.size / 2.0
	panel_window.scale = Vector2.ZERO
	modulate.a = 0.0
	
	update_language_ui()
	Save.language_changed.connect(update_language_ui)
	
	btn_oke.pressed.connect(_on_btn_oke_pressed)
	
	populate_grid()
	show_panel()


# ==============================================================================
# FUNGSI KUSTOM (Custom Methods)
# ==============================================================================
func show_panel():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel_window, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func hide_panel():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(panel_window, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)

func update_language_ui():
	if Save.current_language == "id":
		label_judul.text = "PENCAPAIAN"
	else:
		label_judul.text = "ARCHIVE"

func populate_grid():
	# Hapus semua anak GridContainer jika ada
	for child in grid_container.get_children():
		child.queue_free()
		
	var immune_cells = []
	var pathogens = []
		
	# Kumpulkan dan pisahkan data berdasarkan jenisnya
	for level in InfoData.level_data:
		var unlocked = Save.get("level_" + str(level) + "_cleared")
		# Pengecualian: Level 1 item (tutorial dll) langsung terbuka jika pemain sudah menonton infonya
		if level == 1 and (Save.infoLevel1 or Save.level_1_cleared):
			unlocked = true
			
		for data in InfoData.level_data[level]:
			if data.id == "tutorial":
				continue
				
			var item = {"data": data, "unlocked": unlocked}
			
			# Jika path gambarnya memiliki folder 'musuh', berarti itu patogen
			if "musuh" in data.img:
				pathogens.append(item)
			else:
				immune_cells.append(item)
				
	# Gabungkan array: Pasukan Sel Imun lebih dulu, baru daftar Musuh
	var all_items = immune_cells + pathogens
	
	# Membangun tombol ke dalam GridContainer
	for item in all_items:
		var data = item.data
		var unlocked = item.unlocked
		
		var btn = TextureButton.new()
		btn.custom_minimum_size = Vector2(90, 90)
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		
		if ResourceLoader.exists(data.img):
			btn.texture_normal = load(data.img)
		
		if not unlocked:
			btn.modulate = Color(0, 0, 0, 1) # Hitam siluet
			btn.disabled = true
		else:
			btn.pressed.connect(func(): _on_character_clicked(data))
			
		grid_container.add_child(btn)

func _on_character_clicked(data: Dictionary):
	AudioManager.playSfx("click")
	var info_scene = load("res://src/ui/mainMenu/Info.tscn")
	if info_scene:
		var info = info_scene.instantiate()
		info.info_pages = [data] # Hanya tampilkan karakter ini
		add_child(info)


# ==============================================================================
# FUNGSI RESPON SINYAL (Signal Callbacks)
# ==============================================================================
func _on_btn_oke_pressed():
	AudioManager.playSfx("click")
	hide_panel()
