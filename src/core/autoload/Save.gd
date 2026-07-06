extends Node

const SAVE_PATH = "user://savegame.cfg"

# ==============================================================================
# SIGNALS
# ==============================================================================
signal language_changed
signal name_changed


# ==============================================================================
# PUBLIC VARIABLES
# ==============================================================================
var current_language: String = "id" # Pengaturan bahasa: "id" atau "eng"
var player_name: String = "User123" # Nama pemain

# Pengaturan Suara
var music_volume: float = 50.0
var sfx_volume: float = 50.0

# Status Kemajuan Level (Terkunci/Terbuka)
var level_1_cleared: bool = false
var level_2_cleared: bool = false
var level_3_cleared: bool = false
var level_4_cleared: bool = false
var level_5_cleared: bool = false

# Status Penayangan Info/Tutorial per Level
var infoLevel1: bool = false
var infoLevel2: bool = false
var infoLevel3: bool = false
var infoLevel4: bool = false
var infoLevel5: bool = false
var info_energi: bool = false

# Status Penayangan Info Patogen Baru
var info_enemy_virus: bool = false
var info_enemy_bakteri: bool = false
var info_enemy_parasite: bool = false

# Navigasi Antarmuka
var open_level_select: bool = false
var auto_scroll_to_level: int = 0


# ==============================================================================
# FUNGSI KUSTOM (Custom Methods)
# ==============================================================================
func _ready():
	load_data()

# Menyimpan semua data saat ini ke dalam memori perangkat (permanen)
func save_data():
	var config = ConfigFile.new()
	
	# Simpan Pengaturan Dasar
	config.set_value("Settings", "language", current_language)
	config.set_value("Settings", "player_name", player_name)
	config.set_value("Settings", "music_volume", music_volume)
	config.set_value("Settings", "sfx_volume", sfx_volume)
	
	# Simpan Status Buka/Kunci Level
	config.set_value("Levels", "level_1_cleared", level_1_cleared)
	config.set_value("Levels", "level_2_cleared", level_2_cleared)
	config.set_value("Levels", "level_3_cleared", level_3_cleared)
	config.set_value("Levels", "level_4_cleared", level_4_cleared)
	config.set_value("Levels", "level_5_cleared", level_5_cleared)
	
	# Simpan Status Info/Tutorial
	config.set_value("Tutorials", "infoLevel1", infoLevel1)
	config.set_value("Tutorials", "infoLevel2", infoLevel2)
	config.set_value("Tutorials", "infoLevel3", infoLevel3)
	config.set_value("Tutorials", "infoLevel4", infoLevel4)
	config.set_value("Tutorials", "infoLevel5", infoLevel5)
	config.set_value("Tutorials", "info_energi", info_energi)
	
	config.set_value("Tutorials", "info_enemy_virus", info_enemy_virus)
	config.set_value("Tutorials", "info_enemy_bakteri", info_enemy_bakteri)
	config.set_value("Tutorials", "info_enemy_parasite", info_enemy_parasite)
	
	# Eksekusi penyimpanan ke file
	config.save(SAVE_PATH)

# Memuat data dari memori perangkat ke dalam game
func load_data():
	var config = ConfigFile.new()
	
	# Jika file save belum ada, abaikan (gunakan nilai bawaan)
	if config.load(SAVE_PATH) != OK:
		return
		
	# Muat Pengaturan Dasar
	current_language = config.get_value("Settings", "language", "id")
	player_name = config.get_value("Settings", "player_name", "User123")
	music_volume = config.get_value("Settings", "music_volume", 50.0)
	sfx_volume = config.get_value("Settings", "sfx_volume", 50.0)
	
	# Muat Status Buka/Kunci Level
	level_1_cleared = config.get_value("Levels", "level_1_cleared", false)
	level_2_cleared = config.get_value("Levels", "level_2_cleared", false)
	level_3_cleared = config.get_value("Levels", "level_3_cleared", false)
	level_4_cleared = config.get_value("Levels", "level_4_cleared", false)
	level_5_cleared = config.get_value("Levels", "level_5_cleared", false)
	
	# Muat Status Info/Tutorial
	infoLevel1 = config.get_value("Tutorials", "infoLevel1", false)
	infoLevel2 = config.get_value("Tutorials", "infoLevel2", false)
	infoLevel3 = config.get_value("Tutorials", "infoLevel3", false)
	infoLevel4 = config.get_value("Tutorials", "infoLevel4", false)
	infoLevel5 = config.get_value("Tutorials", "infoLevel5", false)
	info_energi = config.get_value("Tutorials", "info_energi", false)
	
	info_enemy_virus = config.get_value("Tutorials", "info_enemy_virus", false)
	info_enemy_bakteri = config.get_value("Tutorials", "info_enemy_bakteri", false)
	info_enemy_parasite = config.get_value("Tutorials", "info_enemy_parasite", false)

# Mengubah pengaturan bahasa global dan memancarkan sinyal agar semua UI memperbarui teksnya
func set_language(lang: String):
	if current_language != lang:
		current_language = lang
		language_changed.emit()
		save_data()


# Menyimpan nama pemain dengan batasan karakter tertentu
func set_player_name(new_name: String):
	# Hapus spasi berlebih di awal atau akhir teks
	var clean_name = new_name.strip_edges()
	
	if clean_name.length() > 0 and clean_name != player_name:
		# Batasi panjang nama maksimal 12 karakter
		if clean_name.length() > 12:
			clean_name = clean_name.substr(0, 12)
			
		player_name = clean_name
		name_changed.emit(player_name)
		save_data()
