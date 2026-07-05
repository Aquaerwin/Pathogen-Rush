extends Control

# ==============================================================================
# @ONREADY VARIABLES
# ==============================================================================
@onready var panel_option = $PanelOption
@onready var logo_game = $LogoGame

@onready var btn_mulai = $PanelOption/VBoxContainer/BtnMulai
@onready var txt_mulai = $PanelOption/VBoxContainer/BtnMulai/Txt
@onready var btn_pengaturan = $PanelOption/VBoxContainer/BtnPengaturan
@onready var txt_pengaturan = $PanelOption/VBoxContainer/BtnPengaturan/Txt
@onready var btn_keluar = $PanelOption/VBoxContainer/BtnKeluar
@onready var txt_keluar = $PanelOption/VBoxContainer/BtnKeluar/Txt
@onready var btn_nametag = $TopLeftMenu/BtnNameTag
@onready var txt_name = $TopLeftMenu/BtnNameTag/TxtName
@onready var btn_achive = $TopLeftMenu/BtnAchive


# ==============================================================================
# EXPORT VARIABLES
# ==============================================================================
@export var level_select_scene: PackedScene
@export var quit_scene: PackedScene
@export var settings_scene: PackedScene
@export var name_scene: PackedScene
@export var achive_scene: PackedScene


# ==============================================================================
# PUBLIC VARIABLES
# ==============================================================================
var buttons = []


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	AudioManager.playMusic("ui")
	buttons = [btn_mulai, btn_pengaturan, btn_keluar]
	
	# Fungsi tombol
	btn_mulai.pressed.connect(_on_btn_mulai_pressed)
	btn_keluar.pressed.connect(_on_btn_keluar_pressed)
	btn_pengaturan.pressed.connect(_on_btn_pengaturan_pressed)
	btn_nametag.pressed.connect(_on_btn_nametag_pressed)
	btn_achive.pressed.connect(_on_btn_achive_pressed)
	
	# Hubungkan sinyal bahasa dan nama
	Save.language_changed.connect(update_language_ui)
	Save.name_changed.connect(update_player_name)
	update_language_ui()
	update_player_name(Save.player_name)
	
	# Set kondisi awal (tak terlihat) untuk animasi intro
	logo_game.position.y = -300
	logo_game.modulate.a = 0.0
	panel_option.scale = Vector2.ZERO
	
	for btn in buttons:
		btn.modulate.a = 0.0
		
	# Mulai animasi transisi masuk
	play_intro_animation()
	
	# Matikan fokus panah keyboard untuk profil agar tidak looping vertikal
	btn_nametag.focus_mode = Control.FOCUS_NONE
	btn_achive.focus_mode = Control.FOCUS_NONE
	
	# Buka langsung Level Select jika dipanggil dari layar lain
	if Save.open_level_select:
		Save.open_level_select = false
		var level_select_instance = level_select_scene.instantiate()
		add_child(level_select_instance)


# ==============================================================================
# FUNGSI KUSTOM (Custom Methods)
# ==============================================================================
# Memainkan animasi transisi saat masuk ke Main Menu
func play_intro_animation():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Logo Slide Down & Fade In
	var target_y = 50.0 # Posisi tengah atas
	tween.tween_property(logo_game, "position:y", target_y, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(logo_game, "modulate:a", 1.0, 1.0)
	
	# Panel Scale Popup
	tween.tween_property(panel_option, "scale", Vector2.ONE, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Staggered Button Animasi (berurutan)
	tween.set_parallel(false)
	tween.tween_interval(0.5) # Tunggu panel sebagian muncul
	for btn in buttons:
		tween.tween_property(btn, "modulate:a", 1.0, 0.2)
	
	tween.tween_callback(func():
		btn_mulai.grab_focus()
	)


# Memperbarui teks nama pemain di layar UI
func update_player_name(new_name: String):
	txt_name.text = new_name


# Memperbarui teks tombol berdasarkan bahasa yang dipilih
func update_language_ui():
	if Save.current_language == "id":
		txt_mulai.text = "Mulai"
		txt_pengaturan.text = "Pengaturan"
		txt_keluar.text = "Keluar"
	else:
		txt_mulai.text = "Start"
		txt_pengaturan.text = "Setting"
		txt_keluar.text = "Quit"


# ==============================================================================
# FUNGSI RESPON SINYAL TOMBOL (Signal Callbacks)
# ==============================================================================
# Tombol Keluar
func _on_btn_keluar_pressed():
	AudioManager.playSfx("click")
	var quit_instance = quit_scene.instantiate()
	add_child(quit_instance)


# Tombol Pengaturan
func _on_btn_pengaturan_pressed():
	AudioManager.playSfx("click")
	var settings_instance = settings_scene.instantiate()
	add_child(settings_instance)


# Tombol Mulai
func _on_btn_mulai_pressed():
	AudioManager.playSfx("click")
	var level_select_instance = level_select_scene.instantiate()
	add_child(level_select_instance)


# Tombol Ubah Nama
func _on_btn_nametag_pressed():
	AudioManager.playSfx("click")
	var name_instance = name_scene.instantiate()
	add_child(name_instance)


# Tombol Pencapaian (Achievements)
func _on_btn_achive_pressed():
	AudioManager.playSfx("click")
	var achive_instance = achive_scene.instantiate()
	add_child(achive_instance)
