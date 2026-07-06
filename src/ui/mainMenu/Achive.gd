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
	for key in InfoData.tutorial_data:
		var unlocked = false
		if str(key) == "energi":
			unlocked = Save.get("info_energi")
		else:
			unlocked = Save.get("level_" + str(key) + "_cleared")
			# Pengecualian: Level 1 item (tutorial dll) langsung terbuka jika pemain sudah menonton infonya
			if str(key) == "1" and (Save.get("infoLevel1") or Save.get("level_1_cleared")):
				unlocked = true
			
		var current_item_pages = []
		var current_img = ""
		
		for data in InfoData.tutorial_data[key]:
			if data.id == "tutorial":
				continue
				
			if current_img == "" or current_img != data.img:
				if current_item_pages.size() > 0:
					var item = {"pages": current_item_pages, "data": current_item_pages[0], "unlocked": unlocked}
					if "musuh" in current_item_pages[0].img:
						pathogens.append(item)
					else:
						immune_cells.append(item)
				
				current_img = data.img
				current_item_pages = [data]
			else:
				current_item_pages.append(data)
				
		if current_item_pages.size() > 0:
			var item = {"pages": current_item_pages, "data": current_item_pages[0], "unlocked": unlocked}
			if "musuh" in current_item_pages[0].img:
				pathogens.append(item)
			else:
				immune_cells.append(item)
				
	# Memasukkan musuh dari enemy_data
	for e_key in InfoData.enemy_data:
		var data = InfoData.enemy_data[e_key]
		var unlocked = Save.get("info_enemy_" + str(e_key))
		# Konversi null jadi false untuk keamanan
		if unlocked == null: unlocked = false
		
		var item = {"pages": [data], "data": data, "unlocked": unlocked}
		pathogens.append(item)
				
	# Gabungkan array: Pasukan Sel Imun lebih dulu, baru daftar Musuh
	var all_items = immune_cells + pathogens
	
	# Membangun tombol ke dalam GridContainer
	for item in all_items:
		var data = item.data
		var pages = item.pages
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
			btn.pressed.connect(func(): _on_character_clicked(pages))
			
		grid_container.add_child(btn)

func _on_character_clicked(pages: Array):
	AudioManager.playSfx("click")
	var info_scene = load("res://src/ui/mainMenu/Info.tscn")
	if info_scene:
		var info = info_scene.instantiate()
		info.info_pages = pages # Tampilkan semua halaman dari karakter ini
		add_child(info)


# ==============================================================================
# FUNGSI RESPON SINYAL (Signal Callbacks)
# ==============================================================================
func _on_btn_oke_pressed():
	AudioManager.playSfx("click")
	hide_panel()
