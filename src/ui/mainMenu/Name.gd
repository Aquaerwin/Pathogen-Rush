extends ColorRect

# ==============================================================================
# @ONREADY VARIABLES
# ==============================================================================
@onready var panel_window = $PanelWindow
@onready var line_edit = $PanelWindow/VBoxContainer/LineEdit
@onready var btn_oke = $PanelWindow/VBoxContainer/BtnOke
@onready var txt_oke = $PanelWindow/VBoxContainer/BtnOke/TxtOke
@onready var label_judul = $PanelWindow/LabelJudul


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
	line_edit.text_submitted.connect(_on_line_edit_submitted)
	
	# Muat nama pemain yang sudah ada
	line_edit.text = Save.player_name
	
	show_panel()


# ==============================================================================
# FUNGSI KUSTOM (Custom Methods)
# ==============================================================================
# Menampilkan jendela dengan animasi membesar (pop-up)
func show_panel():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel_window, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# Menyembunyikan jendela dengan animasi mengecil lalu dihapus
func hide_panel():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(panel_window, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)


# Memperbarui teks judul UI berdasarkan bahasa aktif
func update_language_ui():
	if Save.current_language == "id":
		label_judul.text = "GANTI NAMA"
		line_edit.placeholder_text = "Masukkan nama baru..."
	else:
		label_judul.text = "CHANGE NAME"
		line_edit.placeholder_text = "Enter new name..."


# Menyimpan nama yang diketik ke sistem Save
func _save_name():
	Save.set_player_name(line_edit.text)


# ==============================================================================
# FUNGSI RESPON SINYAL (Signal Callbacks)
# ==============================================================================
# Dipanggil saat tombol OKE ditekan
func _on_btn_oke_pressed():
	AudioManager.playSfx("click")
	_save_name()
	hide_panel()


# Dipanggil saat tombol Enter ditekan pada keyboard (saat mengetik nama)
func _on_line_edit_submitted(_new_text):
	AudioManager.playSfx("click")
	_save_name()
	hide_panel()
