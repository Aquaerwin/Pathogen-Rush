extends ColorRect

# @ONREADY VARIABLES
@onready var panel_window = $PanelWindow
@onready var label_judul = $PanelWindow/LabelJudul
@onready var btn_ya = $PanelWindow/HBoxContainer/BtnYa
@onready var txt_ya = $PanelWindow/HBoxContainer/BtnYa/TxtYa
@onready var btn_tidak = $PanelWindow/HBoxContainer/BtnTidak
@onready var txt_tidak = $PanelWindow/HBoxContainer/BtnTidak/TxtTidak


# FUNGSI BAWAAN GODOT (Built-in Methods)
func _ready():
	# Memastikan pivot berada di tengah agar animasi pop up dari tengah
	panel_window.pivot_offset = panel_window.size / 2.0
	
	# Sembunyikan panel sebelum animasi dimulai
	panel_window.scale = Vector2.ZERO
	modulate.a = 0.0
	
	# Sinkronisasi awal dengan pengaturan bahasa Global
	update_language_ui()
	Save.language_changed.connect(update_language_ui)
	
	# Hubungkan sinyal interaksi ke fungsi lokal
	btn_ya.pressed.connect(_on_btn_ya_pressed)
	btn_tidak.pressed.connect(_on_btn_tidak_pressed)
	
	# Memulai animasi kemunculan
	show_panel()


# FUNGSI KUSTOM (Custom Methods)
# Menampilkan jendela konfirmasi dengan efek pop-up
func show_panel():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel_window, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# Menyembunyikan jendela, dan mengambil tindakan sesuai parameter `quit_game`
func hide_panel(quit_game: bool):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(panel_window, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	# Jika memilih "YA", matikan mesin Godot (keluar ke desktop)
	if quit_game:
		tween.chain().tween_callback(func(): get_tree().quit())
	else:
		# Jika "TIDAK", cukup hancurkan jendela peringatan ini
		tween.chain().tween_callback(queue_free)


# Memperbarui teks pada jendela konfirmasi sesuai dengan bahasa yang dipilih
func update_language_ui():
	if Save.current_language == "id":
		label_judul.text = "KELUAR ?"
		txt_ya.text = "YA"
		txt_tidak.text = "TIDAK"
	else:
		label_judul.text = "QUIT ?"
		txt_ya.text = "YES"
		txt_tidak.text = "NO"


# FUNGSI RESPON SINYAL (Signal Callbacks)
# Dieksekusi ketika pemain menekan tombol YA
func _on_btn_ya_pressed():
	AudioManager.playSfx("click")
	hide_panel(true)


# Dieksekusi ketika pemain menekan tombol TIDAK
func _on_btn_tidak_pressed():
	AudioManager.playSfx("click")
	hide_panel(false)
