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


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	# Memastikan pivot berada di tengah
	panel_window.pivot_offset = panel_window.size / 2.0
	
	# Sembunyikan panel sebelum animasi
	panel_window.scale = Vector2.ZERO
	modulate.a = 0.0
	
	# Muat pengaturan volume terakhir
	slider_music.value = Save.music_volume
	slider_sfx.value = Save.sfx_volume
	
	# Sinkronisasi awal dengan Global
	update_language_ui()
	Save.language_changed.connect(update_language_ui)
	
	# Hubungkan sinyal tombol
	btn_id.pressed.connect(_on_btn_id_pressed)
	btn_eng.pressed.connect(_on_btn_eng_pressed)
	btn_oke.pressed.connect(_on_btn_oke_pressed)
	
	slider_music.value_changed.connect(_on_slider_music_changed)
	slider_sfx.value_changed.connect(_on_slider_sfx_changed)
	
	# Munculkan dengan animasi
	show_panel()

func show_panel():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel_window, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# Menyembunyikan jendela, menghapus dari memori, dan melepas efek pause
func hide_panel():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(panel_window, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func():
		get_tree().paused = false
		queue_free()
	)

# Memperbarui semua teks dalam jendela agar sesuai dengan bahasa terpilih
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


# ==============================================================================
# FUNGSI RESPON SINYAL (Signal Callbacks)
# ==============================================================================
# Mengubah bahasa ke Indonesia
func _on_btn_id_pressed():
	AudioManager.playSfx("click")
	if not mark_id.visible:
		Save.set_language("id")

# Mengubah bahasa ke Inggris
func _on_btn_eng_pressed():
	AudioManager.playSfx("click")
	if not mark_eng.visible:
		Save.set_language("eng")

# Mengatur volume musik (*Background Music*)
func _on_slider_music_changed(value: float):
	Save.music_volume = value
	Save.save_data()
	AudioManager.volume("Music", value)

# Mengatur volume efek suara (SFX)
func _on_slider_sfx_changed(value: float):
	Save.sfx_volume = value
	Save.save_data()
	AudioManager.volume("Sfx", value)

# Melanjutkan permainan (Keluar dari menu)
func _on_btn_oke_pressed():
	AudioManager.playSfx("click")
	hide_panel()
