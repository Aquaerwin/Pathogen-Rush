extends Area2D

# ==============================================================================
# SIGNALS
# ==============================================================================
# Sinyal yang dipancarkan saat daun/koin ini berhasil diklik pemain
signal collected(type)


# ==============================================================================
# PUBLIC VARIABLES
# ==============================================================================
var type: String = "energi" # Jenis item: "energi" (daun) atau "atp" (koin)
var fall_speed: float = 60.0 # Kecepatan jatuh (khusus untuk daun energi)
var target_y: float = 600.0 # Titik akhir (lantai) tempat berhentinya daun/koin
var target_x: float = 0.0 # Titik horizontal jatuhnya koin ATP
var is_collected: bool = false # Penanda apakah item sudah disedot/diambil pemain


# ==============================================================================
# EXPORT VARIABLES
# ==============================================================================
@export var tex_energi: Texture2D
@export var tex_atp: Texture2D


# ==============================================================================
# @ONREADY VARIABLES
# ==============================================================================
@onready var sprite = $Sprite2D # Gambar visual daun/koin

# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	# Atur gambar sesuai tipe ("energi" = daun, selain itu = ATP)
	sprite.texture = tex_energi if type == "energi" else tex_atp
	
	# Hubungkan fungsi klik mouse pada area item ini
	input_event.connect(_on_input_event)
	
	# Mulai animasi jatuh otomatis (Menggunakan sistem Tween murni dari Godot)
	var tween = create_tween()
	
	if type == "energi":
		# DAUN JATUH: Jatuh lurus ke bawah perlahan dari langit
		var durasi_jatuh = (target_y - position.y) / fall_speed
		if durasi_jatuh > 0:
			tween.tween_property(self, "position:y", target_y, durasi_jatuh)
	else:
		# KOIN ATP (Dari Mitokondria): Terpental melengkung seperti koin jatuh
		# Geser X ke samping selama 0.4 detik
		tween.tween_property(self, "position:x", target_x, 0.4).set_ease(Tween.EASE_OUT)
		
		# Bersamaan dengan geser X, pental ke Atas (Y berkurang 30) lalu jatuh ke Bawah (target_y)
		tween.parallel().tween_property(self, "position:y", position.y - 30, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(self, "position:y", target_y, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

# ==============================================================================
# FUNGSI RESPON SINYAL (Signal Callbacks)
# ==============================================================================
# Dipanggil saat pemain mengklik / menyentuh item
func _on_input_event(_viewport, event, _shape_idx):
	if is_collected: return # Kalau sudah diklik, abaikan klik selanjutnya
	
	# Jika pemain mengklik menggunakan tombol kiri Mouse atau men-tap layar
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_collected = true
		collected.emit(type) # Beri tahu Level untuk menambah saldo!
		
		# Animasi terbang tersedot ke atas secara singkat lalu menghilang
		var tween = create_tween().set_parallel(true)
		tween.tween_property(self, "position:y", position.y - 50, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
		
		# Setelah animasi pudar selesai, lenyap dari dunia
		tween.chain().tween_callback(queue_free)
