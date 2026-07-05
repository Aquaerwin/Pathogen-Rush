extends Control

# ==============================================================================
# @ONREADY VARIABLES
# ==============================================================================
@onready var scroll_container = $ScrollContainer
@onready var card_container = $ScrollContainer/HBoxContainer
@onready var btn_tutup = $BtnTutup


# ==============================================================================
# EXPORT VARIABLES
# ==============================================================================
@export var gambarLevelKunci: Texture2D
@export var gambarLevel1: Texture2D
@export var gambarLevel2: Texture2D
@export var gambarLevel3: Texture2D
@export var gambarLevel4: Texture2D
@export var gambarLevel5: Texture2D


# ==============================================================================
# PUBLIC VARIABLES
# ==============================================================================
var warning_label: Label


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.3)
	
	btn_tutup.pressed.connect(queue_free)
	
	# Setup warning label (pesan error jika level masih terkunci)
	warning_label = Label.new()
	warning_label.add_theme_font_size_override("font_size", 40)
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	warning_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	warning_label.modulate.a = 0.0
	warning_label.z_index = 100
	add_child(warning_label)
	
	# Konfigurasi Kartu Level
	if card_container:
		var cards = card_container.get_children()
		for i in range(cards.size()):
			var card = cards[i]
			card.pressed.connect(_on_card_pressed.bind(i))
			card.texture_normal = gambarLevelKunci
		
		# Override Level 1 (Selalu terbuka)
		if cards.size() > 0:
			cards[0].texture_normal = gambarLevel1
		
		# Override Level 2
		if cards.size() > 1 and Save.level_1_cleared:
			cards[1].texture_normal = gambarLevel2
			
		# Override Level 3
		if cards.size() > 2 and Save.level_2_cleared:
			cards[2].texture_normal = gambarLevel3
			
		# Override Level 4
		if cards.size() > 3 and Save.level_3_cleared:
			cards[3].texture_normal = gambarLevel4

		# Override Level 5
		if cards.size() > 4 and Save.level_4_cleared:
			cards[4].texture_normal = gambarLevel5


# Mendeteksi input navigasi menggunakan keyboard
func _input(event):
	if scroll_container:
		if event.is_action_pressed("ui_left", true):
			scroll_container.scroll_horizontal -= 50
		elif event.is_action_pressed("ui_right", true):
			scroll_container.scroll_horizontal += 50


# ==============================================================================
# FUNGSI RESPON SINYAL (Signal Callbacks)
# ==============================================================================
# Dipanggil saat pemain memilih salah satu kartu level
func _on_card_pressed(index: int):
	if index == 0:
		SceneTransition.change_scene("res://src/level/stage/Level1.tscn")
	elif index == 1 and Save.level_1_cleared:
		SceneTransition.change_scene("res://src/level/stage/Level2.tscn")
	elif index == 2 and Save.level_2_cleared:
		SceneTransition.change_scene("res://src/level/stage/Level3.tscn")
	elif index == 3 and Save.level_3_cleared:
		SceneTransition.change_scene("res://src/level/stage/Level4.tscn")
	elif index == 4 and Save.level_4_cleared:
		SceneTransition.change_scene("res://src/level/stage/Level5.tscn")
	else:
		# Tampilkan peringatan jika belum terbuka
		warning_label.text = "LEVEL BELUM TERBUKA\nSELESAIKAN LEVEL SEBELUMNYA" if Save.current_language == "id" else "LEVEL LOCKED\nCOMPLETE PREVIOUS LEVEL"
		var tw = create_tween()
		warning_label.modulate.a = 1.0
		tw.tween_property(warning_label, "modulate:a", 0.0, 1.5).set_delay(1.5)
