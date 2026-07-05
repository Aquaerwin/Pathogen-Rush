extends CanvasLayer

# ==============================================================================
# @ONREADY VARIABLES
# ==============================================================================
@onready var lbl_energi = $bgEnergi/LabelEnergi # Teks jumlah daun Energi
@onready var lbl_atp = $bgATP/LabelATP # Teks jumlah koin ATP
@onready var progress_slider = $Progress # Bar penanda waktu kedatangan musuh
@onready var btn_set = $btnSet # Tombol pengaturan (Pause)

# Kumpulkan referensi kartu/tombol menara ke dalam Dictionary
@onready var cards = {
	"mito": get_node_or_null("bgMito"),
	"eosinofil": get_node_or_null("bgEosinofil"),
	"epitel": get_node_or_null("bgEpitel"),
	"mast": get_node_or_null("bgMast"),
	"nk": get_node_or_null("bgNK"),
	"fagosit_bomb": get_node_or_null("bgFagosit")
}


# ==============================================================================
# EXPORT VARIABLES
# ==============================================================================
@export var pause_popup_scene: PackedScene
@export var win_popup_scene: PackedScene
@export var lose_popup_scene: PackedScene


# ==============================================================================
# PUBLIC VARIABLES
# ==============================================================================
var pause_popup: Node
var win_popup: Node
var lose_popup: Node


# ==============================================================================
# FUNGSI PEMBARUAN TAMPILAN (UI Updates)
# ==============================================================================
# Memperbarui teks jumlah Energi dan ATP
func update_economy_ui(energi: int, atp: int):
	if lbl_energi: lbl_energi.text = str(energi)
	if lbl_atp: lbl_atp.text = str(atp)

# Memberikan efek visual kegelapan (dim) pada kartu yang dipilih
func update_selection(selected_tower: String):
	# Loop dinamis: Jika ID cocok, ubah warnanya jadi gelap
	for id in cards:
		if cards[id]: 
			cards[id].self_modulate = Color(0.5, 0.5, 0.5, 1) if selected_tower == id else Color.WHITE


# ==============================================================================
# EFEK VISUAL COOLDOWN KARTU
# ==============================================================================
# Menampilkan animasi cooldown berputar / turun pada kartu yang baru saja diletakkan
func start_cooldown(tower: String, duration: float):
	if not cards.has(tower) or cards[tower] == null: return
	
	var btn = cards[tower]
	var inner = null
	var cd = null
	
	# Mapping ID dari scene
	if tower == "mito":
		inner = btn.get_node_or_null("BtnCardMito")
		cd = btn.get_node_or_null("BtnCardMito/Cooldown")
	elif tower == "eosinofil":
		inner = btn.get_node_or_null("BtnCardEosinofil")
		cd = btn.get_node_or_null("BtnCardEosinofil/Cooldown")
	elif tower == "epitel":
		inner = btn.get_node_or_null("BtnCardEpitel")
		cd = btn.get_node_or_null("BtnCardEpitel/Cooldown")
	elif tower == "mast":
		inner = btn.get_node_or_null("BtnCardMast")
		cd = btn.get_node_or_null("BtnCardMast/Cooldown")
	elif tower == "nk":
		inner = btn.get_node_or_null("BtnCardNK")
		cd = btn.get_node_or_null("BtnCardNK/Cooldown")
	elif tower == "fagosit_bomb":
		inner = btn.get_node_or_null("BtnCardFagosit")
		cd = btn.get_node_or_null("BtnCardFagosit/Cooldown")
		
	if inner and cd:
		cd.visible = true
		cd.size = inner.size
		cd.position = Vector2.ZERO
		var tw = create_tween()
		tw.tween_property(cd, "size:y", 0.0, duration)
		tw.chain().tween_callback(func(): cd.visible = false)

# ==============================================================================
# FUNGSI PROGRESS BAR KEDATANGAN MUSUH
# ==============================================================================
# Memperbarui bar slider di atas layar yang menandakan waktu gelombang
func update_progress(time_elapsed: float, game_time: float):
	if progress_slider:
		# Angka 33.0 adalah detik di mana musuh pertama mulai keluar
		if time_elapsed >= 33.0:
			progress_slider.max_value = game_time - 33.0
			progress_slider.value = time_elapsed - 33.0
		else:
			progress_slider.value = 0


# ==============================================================================
# FUNGSI BANTUAN (Helper Methods)
# ==============================================================================
# Mengambil path dari level yang saat ini sedang dimainkan
func _get_current_level_path() -> String:
	return get_tree().current_scene.scene_file_path


# ==============================================================================
# FUNGSI POPUP WINDOWS
# ==============================================================================
# Memunculkan jendela Pause saat tombol gir ditekan
func show_pause_popup():
	pause_popup = pause_popup_scene.instantiate()
	add_child(pause_popup)
	pause_popup.menu_pressed.connect(func(): 
		get_tree().paused = false
		SceneTransition.change_scene("res://src/ui/mainMenu/MainMenu.tscn")
	)
	pause_popup.retry_pressed.connect(func(): 
		get_tree().paused = false
		SceneTransition.change_scene(_get_current_level_path())
	)

# Memunculkan jendela Kemenangan
func show_win_popup(reward_image: String = "res://assets/backgrounds/cardLevel2.png", subtitle: String = "Sel baru terbuka"):
	win_popup = win_popup_scene.instantiate()
	add_child(win_popup)
	win_popup.process_mode = Node.PROCESS_MODE_ALWAYS # Biarkan UI ini kebal dari sistem Pause game
	
	if win_popup.has_method("set_reward"):
		win_popup.set_reward(reward_image, subtitle)
		
	win_popup.menu_pressed.connect(func(): 
		get_tree().paused = false
		SceneTransition.change_scene("res://src/ui/mainMenu/MainMenu.tscn")
	)
	win_popup.next_pressed.connect(func(): 
		get_tree().paused = false
		Save.open_level_select = true
		Save.auto_scroll_to_level = 1
		SceneTransition.change_scene("res://src/ui/mainMenu/MainMenu.tscn")
	)
	win_popup.retry_pressed.connect(func(): 
		get_tree().paused = false
		SceneTransition.change_scene(_get_current_level_path())
	)

# Memunculkan jendela Kekalahan
func show_lose_popup():
	lose_popup = lose_popup_scene.instantiate()
	add_child(lose_popup)
	lose_popup.process_mode = Node.PROCESS_MODE_ALWAYS # Biarkan UI ini kebal dari sistem Pause game
	
	lose_popup.menu_pressed.connect(func(): 
		get_tree().paused = false
		SceneTransition.change_scene("res://src/ui/mainMenu/MainMenu.tscn")
	)
	lose_popup.retry_pressed.connect(func(): 
		get_tree().paused = false
		SceneTransition.change_scene(_get_current_level_path())
	)
