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
@onready var panel = $Panel
@onready var lbl_title = $Panel/Title
@onready var btn_menu = $Panel/HBox/BtnMenu
@onready var btn_retry = $Panel/HBox/BtnRetry


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	z_index = 4000 # Pastikan popup selalu berada di lapisan paling atas
	
	# Penyesuaian teks berdasarkan bahasa
	if Save.current_language == "eng":
		lbl_title.text = "YOU LOSE"
		btn_menu.get_node("Label").text = "Main Menu"
		btn_retry.get_node("Label").text = "Retry"
	
	# Hubungkan sinyal tombol ke pancaran sinyal lokal
	btn_menu.pressed.connect(func(): 
		AudioManager.playSfx("click")
		menu_pressed.emit()
	)
	
	btn_retry.pressed.connect(func(): 
		AudioManager.playSfx("click")
		retry_pressed.emit()
	)
	
	# Persiapan animasi
	modulate.a = 0.0
	panel.scale = Vector2.ZERO
	
	# Mainkan efek transisi pop-up
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
