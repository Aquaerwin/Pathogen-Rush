extends Node

# ==============================================================================
# SIGNALS
# ==============================================================================
# Sinyal yang dipancarkan ketika musuh baru muncul (di-spawn)
signal on_virus_spawned(virus_node)

# ==============================================================================
# EXPORT VARIABLES
# Pengaturan yang bisa diubah via Inspector
# ==============================================================================
@export var entities_layer: Node # Lapisan tempat memunculkan musuh
@export var level_node: Node # Referensi ke skrip LevelManager utama
@export var grid_rows: int = 5 # Jumlah jalur baris yang bisa dilalui musuh
@export var allowed_enemies: Array[String] = ["virus"] # Jenis musuh dasar
@export var initial_spawn_delay: float = 35.0 # Waktu jeda sebelum musuh pertama muncul
@export var min_spawn_time: float = 4.0 # Batas tercepat antar kemunculan musuh
@export var spawn_interval_decrease: float = 0.5 # Pengurangan waktu jeda spawn agar makin susah
@export var normal_spawn_time: float = 10.0 # Waktu normal jeda spawn
@export var bakteri_scene: PackedScene
@export var parasite_scene: PackedScene
@export var virus_scene: PackedScene

# ==============================================================================
# PUBLIC VARIABLES
# Variabel yang bisa diakses oleh kelas/node lain
# ==============================================================================
var arena_tilemap # Referensi ke peta grid (jalur lintasan)
var current_phase: int = 0
var next_spawn_time: float = 0.0
var current_interval: float = 0.0
var spawning_stopped: bool = false
var next_bakteri_time: float = 0.0
var next_parasite_time: float = 0.0
var last_spawned_row: int = -1


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in)
# ==============================================================================
func _ready():
	next_spawn_time = initial_spawn_delay
	current_interval = normal_spawn_time
	next_bakteri_time = initial_spawn_delay + 25.0
	next_parasite_time = initial_spawn_delay + 50.0
	
	if level_node and "current_level" in level_node:
		if level_node.current_level >= 3:
			allowed_enemies = ["virus"] # Bakteri akan ditangani oleh timer terpisah


func _process(_delta):
	if spawning_stopped: return
	if level_node == null or level_node.is_game_over: return
	
	var elapsed = level_node.time_elapsed
	var total_time = level_node.game_time
	
	if not arena_tilemap or not entities_layer:
		return
		
	var current_level = 1
	if level_node and "current_level" in level_node:
		current_level = level_node.current_level
		
	# Gelombang Final (5 detik sebelum waktu level habis)
	if elapsed >= (total_time - 5.0):
		if current_phase <= 2:
			current_phase = 3
			AudioManager.playSfx("finalwave")
			spawn_enemies(12, ["virus"]) # Serangan brutal di ujung waktu!
			stop_spawning()
		return
		
	# Logika khusus kemunculan Bakteri (Level 3 ke atas)
	if current_level >= 3 and elapsed >= next_bakteri_time:
		spawn_enemies(1, ["bakteri"])
		next_bakteri_time = elapsed + 25.0

	# Logika khusus kemunculan Parasit (Level 5)
	if current_level >= 5 and elapsed >= next_parasite_time:
		spawn_enemies(1, ["parasite"])
		next_parasite_time = elapsed + 40.0
		
	# Pengecekan spawn musuh reguler (berkala)
	if elapsed >= next_spawn_time:
		var max_spawns = 1
		
		if current_level >= 2:
			# LEVEL 2 & 3+: Punya sistem perpindahan fase tingkat kesulitan
			if elapsed < (total_time * 0.5):
				if current_phase == 0:
					current_phase = 1
					current_interval = normal_spawn_time
				max_spawns = 1
			else:
				if current_phase == 1:
					current_phase = 2
					current_interval = normal_spawn_time # Reset interval untuk serangan ganda
				max_spawns = 2
		else:
			# LEVEL 1: Tempo lebih santai
			if current_phase == 0:
				current_phase = 1
				current_interval = 14.0 # Jeda 14 detik khusus level 1
			max_spawns = 1
		
		spawn_enemies(max_spawns, allowed_enemies)
		next_spawn_time = elapsed + current_interval
		
		# Kurangi jeda spawn sedikit demi sedikit agar makin menantang
		# Gunakan min_spawn_time dari Inspector agar lebih dinamis per-level
		current_interval = max(min_spawn_time, current_interval - spawn_interval_decrease)


# ==============================================================================
# FUNGSI KUSTOM (Custom Methods)
# ==============================================================================
# Memilih jenis musuh, menentukan titik kordinat, dan memunculkannya
func spawn_enemies(count: int, enemy_types: Array):
	for i in range(count):
		var enemy_type = enemy_types[randi() % enemy_types.size()]
		var v = null
		
		# --- POPUP INFO MUSUH BARU (REAL-TIME) ---
		var info_var = "info_enemy_" + enemy_type
		if Save.get(info_var) == false:
			var info_scene = load("res://src/ui/mainMenu/Info.tscn")
			if info_scene and InfoData.enemy_data.has(enemy_type):
				var info_instance = info_scene.instantiate()
				# Kirim hanya data spesifik patogen ini
				info_instance.info_pages = [InfoData.enemy_data[enemy_type]]
				
				if level_node and level_node.has_node("uiLayer"):
					level_node.get_node("uiLayer").add_child(info_instance)
					
				Save.set(info_var, true)
				Save.save_data()
		# -----------------------------------------
		
		if enemy_type == "bakteri": 
			v = bakteri_scene.instantiate()
		elif enemy_type == "parasite": 
			v = parasite_scene.instantiate()
		else: 
			v = virus_scene.instantiate()
			
		var random_row = randi_range(0, grid_rows - 1)
		
		# Anti-Clumping: Cegah muncul di baris yang sama persis secara berurutan
		if random_row == last_spawned_row:
			random_row = (random_row + randi_range(1, grid_rows - 1)) % grid_rows
		last_spawned_row = random_row
		
		var local_pos = arena_tilemap.map_to_local(Vector2i(0, random_row))
		var spawn_y = arena_tilemap.to_global(local_pos).y
		
		# Variasi posisi X agar musuh tidak saling tindih lurus jika spawn ganda
		var offset_x = randf_range(0, 150) if count > 1 else 0.0
		v.position = Vector2(1300 + offset_x, spawn_y)
		
		on_virus_spawned.emit(v)
		entities_layer.add_child(v)


# Menghentikan paksa seluruh aktivitas spawn
func stop_spawning():
	spawning_stopped = true
