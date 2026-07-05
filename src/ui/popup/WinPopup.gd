extends ColorRect

# ==============================================================================
# SIGNALS
# ==============================================================================
@warning_ignore("unused_signal")
signal menu_pressed
@warning_ignore("unused_signal")
signal next_pressed
@warning_ignore("unused_signal")
signal retry_pressed


# ==============================================================================
# @ONREADY VARIABLES
# ==============================================================================
@onready var panel = $Panel
@onready var lbl_title = $Panel/Title
@onready var lbl_sub = $Panel/Subtitle
@onready var reward_texture = $Panel/RewardTexture
@onready var btn_menu = $Panel/HBox/BtnMenu
@onready var btn_next = $Panel/HBox/BtnNext
@onready var btn_retry = $Panel/HBox/BtnRetry


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	z_index = 4000 # Pastikan selalu di atas
	
	# Penyesuaian bahasa
	if Save.current_language == "eng":
		lbl_title.text = "YOU WIN"
		lbl_sub.text = "New cell unlocked"
		btn_next.get_node("Label").text = "Next"
		btn_retry.get_node("Label").text = "Retry"
	
	# Hubungkan sinyal tombol
	btn_menu.pressed.connect(func(): 
		AudioManager.playSfx("click")
		menu_pressed.emit()
	)
	
	btn_next.pressed.connect(func(): 
		AudioManager.playSfx("click")
		next_pressed.emit()
	)
	
	btn_retry.pressed.connect(func(): 
		AudioManager.playSfx("click")
		retry_pressed.emit()
	)
	
	# Persiapan animasi masuk (fade in & pop up)
	modulate.a = 0.0
	panel.scale = Vector2.ZERO
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)



# Mengatur teks dan gambar hadiah (reward) kemenangan
func set_reward(image_path: String, text: String = ""):
	if text != "":
		lbl_sub.text = text
	
	if reward_texture:
		if image_path == "" or image_path == "res://assets/background/":
			reward_texture.hide()
		else:
			reward_texture.show()
			reward_texture.texture = load(image_path)
