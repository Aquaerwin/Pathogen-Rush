extends ColorRect

# ==============================================================================
# SIGNALS
# ==============================================================================
@warning_ignore("unused_signal")
signal menu_pressed
@warning_ignore("unused_signal")
signal retry_pressed


# ==============================================================================
# @ONREADY VARIABLES
# ==============================================================================
@onready var panel_window = $PanelWindow
@onready var slider_music = $PanelWindow/SliderMusic
@onready var slider_sfx = $PanelWindow/SliderSfx
@onready var btn_id = $PanelWindow/BtnID
@onready var mark_id = $PanelWindow/BtnID/Mark
@onready var btn_eng = $PanelWindow/BtnENG
@onready var mark_eng = $PanelWindow/BtnENG/Mark
@onready var btn_oke = $PanelWindow/BtnOke
@onready var txt_oke = $PanelWindow/BtnOke/TxtOke
@onready var label_judul = $PanelWindow/LabelJudul
@onready var label_musik = $PanelWindow/LabelMusik
@onready var label_sfx = $PanelWindow/LabelSfx
@onready var label_id = $PanelWindow/LabelID
@onready var label_eng = $PanelWindow/LabelENG
@onready var btn_menu = $PanelWindow/HBox/BtnMenu
@onready var btn_retry = $PanelWindow/HBox/BtnRetry


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	z_index = 4000
	
	# Memastikan pivot berada di tengah untuk animasi yang rapi
	panel_window.pivot_offset = panel_window.size / 2.0
	
	# Sembunyikan panel sebelum animasi dimulai
	panel_window.scale = Vector2.ZERO
	modulate.a = 0.0
	
	# Muat pengaturan volume terakhir dari Save data
	slider_music.value = Save.music_volume
	slider_sfx.value = Save.sfx_volume
	
	# Sinkronisasi awal dengan pengaturan bahasa Global
	update_language_ui()
	Save.language_changed.connect(update_language_ui)
	
	# Hubungkan sinyal interaksi ke fungsi lokal
	btn_id.pressed.connect(_on_btn_id_pressed)
	btn_eng.pressed.connect(_on_btn_eng_pressed)
	btn_oke.pressed.connect(_on_btn_oke_pressed)
	
	slider_music.value_changed.connect(_on_slider_music_changed)
	slider_sfx.value_changed.connect(_on_slider_sfx_changed)
	
	# Penyesuaian bahasa teks khusus tombol menu pause
	btn_menu.get_node("Label").text = "Main Menu" if Save.current_language == "id" else "Main Menu"
	btn_retry.get_node("Label").text = "Ulang Level" if Save.current_language == "id" else "Retry"
	
	btn_menu.pressed.connect(func(): 
		AudioManager.playSfx("click")
		menu_pressed.emit()
	)
	
	btn_retry.pressed.connect(func(): 
		AudioManager.playSfx("click")
		retry_pressed.emit()
	)
	
	# Menghentikan semua proses game di latar belakang
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	# Mulai animasi transisi masuk
	show_panel()



# Menampilkan jendela dengan animasi membesar
func show_panel():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel_window, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# Menyembunyikan jendela pop-up, menghapus memori, dan melepaskan pause
func hide_panel():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(panel_window, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func():
		get_tree().paused = false
		queue_free()
	)



# Dipanggil saat tombol bahasa Indonesia ditekan
func _on_btn_id_pressed():
	AudioManager.playSfx("click")
	if not mark_id.visible:
		Save.set_language("id")


# Dipanggil saat tombol bahasa Inggris ditekan
func _on_btn_eng_pressed():
	AudioManager.playSfx("click")
	if not mark_eng.visible:
		Save.set_language("eng")


# Memperbarui UI teks berdasarkan bahasa terpilih
func update_language_ui():
	if Save.current_language == "id":
		mark_id.visible = true
		mark_eng.visible = false
		label_judul.text = "Pengaturan"
		label_musik.text = "Musik"
		label_sfx.text = "Efek Suara"
		txt_oke.text = "Lanjut"
	else:
		mark_id.visible = false
		mark_eng.visible = true
		label_judul.text = "Setting"
		label_musik.text = "Music"
		label_sfx.text = "SFX"
		txt_oke.text = "Resume"


# Mengatur slider volume musik
func _on_slider_music_changed(value: float):
	Save.music_volume = value
	Save.save_data()
	AudioManager.volume("Music", value)


# Mengatur slider volume suara efek
func _on_slider_sfx_changed(value: float):
	Save.sfx_volume = value
	Save.save_data()
	AudioManager.volume("Sfx", value)


# Melanjutkan permainan (Keluar dari menu pause)
func _on_btn_oke_pressed():
	AudioManager.playSfx("click")
	hide_panel()
