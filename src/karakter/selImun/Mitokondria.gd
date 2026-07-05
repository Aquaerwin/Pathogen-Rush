extends BaseCell

# ==============================================================================
# SIGNALS
# ==============================================================================
# Sinyal yang dipancarkan saat Mitokondria berhasil memproduksi molekul ATP (Uang)
signal spawn_atp(pos)


# ==============================================================================
# @ONREADY VARIABLES
# ==============================================================================
@onready var spawn_timer = $SpawnTimer # Timer jeda untuk memproduksi ATP secara berkala


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	super._ready() # Memanggil pengaturan dasar dari kelas induk (BaseCell)
	
	# Menghubungkan waktu habis timer dengan fungsi produksi
	spawn_timer.timeout.connect(_on_spawn_timeout)


# ==============================================================================
# FUNGSI RESPON SINYAL (Signal Callbacks)
# ==============================================================================
# Mengeksekusi penciptaan uang (ATP) setiap kali pewaktu habis
func _on_spawn_timeout():
	# Pastikan Mitokondria masih hidup dan bernapas sebelum melempar uang
	if hp > 0 and not is_dead:
		
		# Tentukan posisi jatuhnya ATP sedikit melenceng agar terlihat natural
		var random_offset = Vector2(randf_range(-15, 15), randf_range(0, 15))
		spawn_atp.emit(global_position + random_offset)
