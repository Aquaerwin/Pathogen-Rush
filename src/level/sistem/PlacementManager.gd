extends Node

# ==============================================================================
# EXPORT VARIABLES
# Pengaturan yang bisa diubah via Inspector
# ==============================================================================
@export var level_node: Node # Referensi ke skrip LevelManager utama
@export var entities_layer: Node # Lapisan tempat memunculkan sel/menara
@export var grid_cols: int = 9 # Jumlah kotak menyamping (kolom arena)
@export var grid_rows: int = 5 # Jumlah kotak menurun (baris arena)
@export var selMito: PackedScene
@export var selEosinofil: PackedScene
@export var selEpitel: PackedScene
@export var selMast: PackedScene
@export var selNk: PackedScene
@export var selFagosit: PackedScene

# ==============================================================================
# PUBLIC VARIABLES
# Variabel yang bisa diakses oleh kelas/node lain
# ==============================================================================
var arena_tilemap # Peta grid tempat kita bisa menanam sel
var occupied_cells = {} # Kamus untuk mencatat koordinat grid yang sudah terisi
var selected_tower: String = "" # Menyimpan ID menara yang sedang diklik pemain

# Kamus utama berisi data statis dan referensi adegan menara
@onready var tower_data = {
	"mito": {"cost": 50, "type": "energi", "cd": 5.0, "scene": selMito, "ready": true},
	"eosinofil": {"cost": 75, "type": "atp", "cd": 5.0, "scene": selEosinofil, "ready": true},
	"epitel": {"cost": 75, "type": "atp", "cd": 15.0, "scene": selEpitel, "ready": true},
	"mast": {"cost": 50, "type": "atp", "cd": 15.0, "scene": selMast, "ready": true},
	"nk": {"cost": 125, "type": "atp", "cd": 12.0, "scene": selNk, "ready": true},
	"fagosit_bomb": {"cost": 125, "type": "atp", "cd": 20.0, "scene": selFagosit, "ready": true}
}


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in)
# ==============================================================================
func _ready():
	# Dinamis ekstrak harga dan cooldown dari Inspector masing-masing menara
	for key in tower_data.keys():
		var temp_instance = tower_data[key]["scene"].instantiate()
		tower_data[key]["cost"] = temp_instance.cost
		tower_data[key]["cd"] = temp_instance.cooldown_tanam
		temp_instance.free()


func _unhandled_input(event):
	if level_node and level_node.is_game_over: return
	if not arena_tilemap or not entities_layer: return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_tower == "" or not tower_data.has(selected_tower): return
		var pos = event.position
		if pos.y < 120 or pos.x < 100: return # Mencegah penanaman di area UI layar
		
		# Konversi klik layar menjadi koordinat kotak (grid)
		var local_mouse_pos = arena_tilemap.to_local(pos)
		var grid_pos = arena_tilemap.local_to_map(local_mouse_pos)
		
		# Validasi apakah klik berada di dalam batas arena
		if grid_pos.x < 0 or grid_pos.x >= grid_cols or grid_pos.y < 0 or grid_pos.y >= grid_rows:
			return 
			
		# Cegah penanaman jika kotak sudah terisi menara lain
		if occupied_cells.has(grid_pos) and occupied_cells[grid_pos] == true:
			return
			
		# Paskan posisi menara persis di tengah kotak
		var snapped_local = arena_tilemap.map_to_local(grid_pos)
		var snapped_global = arena_tilemap.to_global(snapped_local)
		
		var t_data = tower_data[selected_tower]
		var currency_amount = level_node.get(t_data.type)
		
		# Cek apakah uang cukup dan cooldown sudah selesai
		if t_data.ready and currency_amount >= t_data.cost:
			level_node.set(t_data.type, currency_amount - t_data.cost) # Kurangi uang pemain
			AudioManager.playSfx("plant")
			spawn_tower(selected_tower, snapped_global, grid_pos)
			
			occupied_cells[grid_pos] = true # Tandai kotak telah terisi
			t_data.ready = false
			
			if level_node.ui_layer.has_method("start_cooldown"):
				level_node.ui_layer.start_cooldown(selected_tower, t_data.cd)
			
			var cur_tower = selected_tower
			get_tree().create_timer(t_data.cd).timeout.connect(func(): tower_data[cur_tower].ready = true)
			
			selected_tower = "" # Hilangkan pilihan agar pemain tidak menanam beruntun tanpa klik lagi
			if level_node.has_method("update_selection"):
				level_node.update_selection()
			
			level_node.update_economy_ui()


# ==============================================================================
# FUNGSI KUSTOM (Custom Methods)
# ==============================================================================
# Memunculkan entitas menara ke dalam arena dan menghubungkan sinyalnya
func spawn_tower(tower_id: String, pos: Vector2, grid_pos: Vector2i):
	var tower = tower_data[tower_id].scene.instantiate()
	tower.position = pos
	tower.on_death.connect(func(_node): occupied_cells[grid_pos] = false) # Kosongkan kotak grid jika menara mati
	
	if tower.has_signal("shoot_bullet"):
		tower.shoot_bullet.connect(level_node._on_shoot_bullet)
	if tower.has_signal("spawn_atp"):
		tower.spawn_atp.connect(level_node._on_spawn_atp)
		
	entities_layer.add_child(tower)
