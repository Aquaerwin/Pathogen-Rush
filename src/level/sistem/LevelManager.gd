extends Node2D

# ==============================================================================
# ENUMS & CONSTANTS
# ==============================================================================
# Data kemenangan terpusat untuk membuka fitur baru di level selanjutnya
const LEVEL_DATA = {
	1: {"unlock_var": "level_1_cleared", "reward_img": "cardLevel2.png", "msg": "Sel Epitel terbuka"},
	2: {"unlock_var": "level_2_cleared", "reward_img": "cardLevel3.png", "msg": "Sel Mast terbuka"},
	3: {"unlock_var": "level_3_cleared", "reward_img": "cardLevel4.png", "msg": "Sel NK terbuka"},
	4: {"unlock_var": "level_4_cleared", "reward_img": "cardLevel5.png", "msg": "Fagosit Bomb terbuka"},
	5: {"unlock_var": "level_5_cleared", "reward_img": "", "msg": "Kamu Menang Seluruh Game!"}
}


# ==============================================================================
# @ONREADY VARIABLES
# Referensi langsung ke node anak (children) saat game dimulai
# ==============================================================================
@onready var arena_tilemap = get_node_or_null("ArenaTileMap")
@onready var wave_manager = get_node_or_null("WaveManager")
@onready var placement_manager = get_node_or_null("PlacementManager")
@onready var drop_timer = $dropTimer
@onready var ui_layer = $uiLayer
@onready var entities_layer = $EntitiesLayer
@onready var base_area = $BaseArea


# ==============================================================================
# EXPORT VARIABLES
# Pengaturan level yang bisa disesuaikan di Inspector Godot
# ==============================================================================
@export var current_level: int = 1 # Menandakan level ke berapa yang sedang dimainkan
@export var energi: int = 50 # Mata uang dasar (untuk menanam Mitokondria)
@export var atp: int = 25 # Mata uang lanjutan (untuk menanam sel imun)
@export var game_time: float = 180.0 # Total waktu permainan (contoh: 3 menit)
@export var item_drop_scene: PackedScene
@export var nk_bullet_scene: PackedScene
@export var eosinofil_bullet_scene: PackedScene


# ==============================================================================
# PUBLIC/GLOBAL VARIABLES
# Variabel yang bebas diakses dari mana saja
# ==============================================================================
var time_elapsed: float = 0.0 # Penghitung waktu yang sudah berjalan
var is_game_over: bool = false # Status apakah permainan sudah selesai (menang/kalah)
var is_handling_defeat: bool = false # Mencegah kode kekalahan dieksekusi berulang kali


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	get_tree().paused = true # Tahan permainan agar tidak jalan saat transisi
	
	# Menghubungkan WaveManager ke sistem utama
	if wave_manager and wave_manager.get_script() != null:
		wave_manager.arena_tilemap = arena_tilemap
		wave_manager.entities_layer = entities_layer
		wave_manager.level_node = self
		wave_manager.on_virus_spawned.connect(_on_virus_spawned)
		
	# Menghubungkan PlacementManager ke sistem utama
	if placement_manager and placement_manager.get_script() != null:
		placement_manager.arena_tilemap = arena_tilemap
		placement_manager.entities_layer = entities_layer
		placement_manager.level_node = self

	update_economy_ui()
	
	# Memulai timer hujan energi dari langit
	if drop_timer: 
		drop_timer.wait_time = 7.0 
		drop_timer.timeout.connect(spawn_drop_energi)
		drop_timer.start()
		
	# Tombol pengaturan / pause
	if ui_layer.btn_set: 
		ui_layer.btn_set.pressed.connect(_on_btn_set_pressed)
		
	# Menghubungkan klik kartu UI dengan PlacementManager secara otomatis
	if placement_manager and ui_layer.get("cards") != null:
		for tower_id in ui_layer.cards:
			var btn = ui_layer.cards[tower_id]
			if btn and btn.has_signal("pressed"):
				btn.pressed.connect(func(): 
					AudioManager.playSfx("click")
					if placement_manager.tower_data.has(tower_id) and placement_manager.tower_data[tower_id].ready:
						placement_manager.selected_tower = tower_id
						update_selection()
				)

	# Mendeteksi musuh yang berhasil menyentuh garis finish
	if base_area:
		base_area.area_entered.connect(_on_base_area_entered)
		
	# Tunggu animasi transisi layar dan logo selesai
	if SceneTransition.has_signal("transition_finished"):
		await SceneTransition.transition_finished
		
	# Jeda 1 detik santai sebelum memunculkan popup
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_interval(1.0)
	await tw.finished
		
	# Menampilkan Info/Tutorial jika belum pernah dilihat
	var info_var = "infoLevel" + str(current_level)
	if Save.get(info_var) == false:
		var info_scene = load("res://src/ui/mainMenu/Info.tscn")
		if info_scene:
			var info_instance = info_scene.instantiate()
			info_instance.tutorial_key = current_level
			# Masukkan ke ui_layer agar berada di atas segalanya
			ui_layer.add_child(info_instance)
			Save.set(info_var, true)
			Save.save_data()
			# Tunggu pemain menutup popup InfoData
			await info_instance.tree_exited
			
	# Lepas jeda dan mulai permainan!
	get_tree().paused = false
	AudioManager.playMusic("battle")


func _process(delta):
	if is_game_over: return
	
	time_elapsed += delta
	ui_layer.update_progress(time_elapsed, game_time)
	
	# Jika waktu habis, periksa apakah masih ada musuh yang tersisa di layar
	if time_elapsed >= game_time:
		if wave_manager: wave_manager.stop_spawning()
		var viruses = get_tree().get_nodes_in_group("enemy")
		var old_viruses = get_tree().get_nodes_in_group("virus")
		if viruses.size() == 0 and old_viruses.size() == 0:
			game_over(true) # Pemain menang!


# ==============================================================================
# FUNGSI KUSTOM (Custom Methods)
# ==============================================================================
# Memperbarui tampilan bingkai kartu yang sedang dipilih
func update_selection():
	if placement_manager:
		ui_layer.update_selection(placement_manager.selected_tower)


# Memperbarui teks uang di layar
func update_economy_ui():
	ui_layer.update_economy_ui(energi, atp)


# Memunculkan item energi dari langit secara acak
func spawn_drop_energi():
	if is_game_over: return
	
	if Save.get("info_energi") == false:
		var info_scene = load("res://src/ui/mainMenu/Info.tscn")
		if info_scene:
			var info_instance = info_scene.instantiate()
			info_instance.tutorial_key = "energi"
			ui_layer.add_child(info_instance)
			Save.set("info_energi", true)
			Save.save_data()
			
	var drop = item_drop_scene.instantiate()
	drop.type = "energi"
	drop.position = Vector2(randf_range(150, 1100), -50)
	drop.target_y = randf_range(200, 600)
	drop.collected.connect(_on_item_collected)
	ui_layer.add_child(drop)


# Mengakhiri permainan dan memunculkan pop-up kemenangan/kekalahan
func game_over(win: bool):
	if is_game_over: return
	is_game_over = true
	
	if win and LEVEL_DATA.has(current_level):
		AudioManager.playSfx("win")
		var data = LEVEL_DATA[current_level]
		Save.set(data.unlock_var, true) # Simpan progress ke sistem Save
		Save.save_data() # Simpan permanen ke penyimpanan
		ui_layer.show_win_popup("res://assets/background/" + data.reward_img, data.msg)
	elif not win:
		AudioManager.playSfx("lose")
		ui_layer.show_lose_popup()


# Animasi khusus ketika musuh berhasil masuk ke markas dan game over
func trigger_defeat_sequence(virus_node):
	if is_game_over or is_handling_defeat: return
	is_handling_defeat = true
	
	if wave_manager: wave_manager.stop_spawning()
	if drop_timer: drop_timer.stop()
	
	get_tree().paused = true # Hentikan seluruh pergerakan di layar
	
	# Pengecualian: Biarkan virus pemenang tetap bergerak menembus markas
	if is_instance_valid(virus_node):
		virus_node.process_mode = Node.PROCESS_MODE_ALWAYS
		virus_node.set_process(false)
		
		if "anim" in virus_node:
			virus_node.anim.play("walk")
			virus_node.anim.speed_scale = 4.0
			
		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(virus_node, "position", Vector2(0, 360), 0.6)
		await tween.finished
		
		if is_instance_valid(virus_node):
			virus_node.queue_free()
			
	game_over(false)


# ==============================================================================
# FUNGSI RESPON SINYAL (Signal Callbacks)
# ==============================================================================
# Dipanggil saat Mitokondria memproduksi ATP
func _on_spawn_atp(pos: Vector2):
	if is_game_over: return
	var drop = item_drop_scene.instantiate()
	drop.type = "atp"
	drop.position = pos
	drop.target_x = pos.x + randf_range(-40.0, 40.0)
	drop.target_y = pos.y + randf_range(-10.0, 40.0)
	drop.collected.connect(_on_item_collected)
	ui_layer.add_child(drop)


# Dipanggil saat Eosinofil atau Sel NK menembak peluru
func _on_shoot_bullet(pos: Vector2, dmg: int, type: String = "eosinofil"):
	if is_game_over: return
	AudioManager.playSfx("shoot", true)
	var bullet_scene = nk_bullet_scene if type == "nk" else eosinofil_bullet_scene
	var bullet = bullet_scene.instantiate()
	bullet.position = pos
	bullet.damage = dmg
	entities_layer.add_child(bullet)


# Dipanggil saat pemain menyentuh energi/ATP
func _on_item_collected(type: String):
	AudioManager.playSfx("collect")
	if type == "energi": energi += 25
	elif type == "atp": atp += 25
	update_economy_ui()


# Dipanggil saat WaveManager memunculkan virus baru
func _on_virus_spawned(virus_node):
	virus_node.base_reached.connect(_on_base_reached)


# Dipanggil jika ada objek (musuh) menabrak area deteksi markas
func _on_base_area_entered(area):
	if area.is_in_group("enemy") or area.is_in_group("virus"):
		trigger_defeat_sequence(area)


# Dipanggil dari sinyal virus ketika koordinat X mereka mencapai batas tertentu
func _on_base_reached(virus_node):
	trigger_defeat_sequence(virus_node)


# Dipanggil ketika tombol pause (gir) ditekan
func _on_btn_set_pressed():
	get_tree().paused = true
	ui_layer.show_pause_popup()
