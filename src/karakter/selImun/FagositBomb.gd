extends BaseCell

# ==============================================================================
# EXPORT VARIABLES
# Pengaturan daya ledak via Inspector
# ==============================================================================
@export var damage: int # Besar kerusakan mematikan (instant kill)
@export var explode_radius: float # Radius seberapa jauh ledakan menjangkau musuh


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	super._ready() # Panggil pengaturan persiapan dasar dari kelas induk
	
	# Langsung mainkan animasi bersiap meledak saat pertama diletakkan
	if anim: anim.play("explode")
	
	# Atur pewaktu: Bom akan meledak otomatis tepat 1 detik setelah ditanam
	get_tree().create_timer(1.0).timeout.connect(explode)


# ==============================================================================
# FUNGSI KUSTOM (Custom Methods)
# ==============================================================================
# Menimpa (override) fungsi kerusakan: jika bom ini digigit/ditabrak sebelum
# 1 detik meledak otomatis, bom ini akan membalas dengan meledak seketika!
func take_damage(_amount: int):
	if is_dead: return
	explode()


# Mengeksekusi efek ledakan area dan menghancurkan musuh di sekitarnya
func explode():
	if is_dead: return
	is_dead = true # Tandai mati agar kode ini tidak dieksekusi berulang kali
	
	AudioManager.playSfx("explode")
	
	# Kumpulkan semua daftar musuh yang sedang berada di arena
	var enemies = get_tree().get_nodes_in_group("enemy")
	for v in enemies:
		# Jika musuh valid dan berada tepat di dalam zona radius ledakan
		if is_instance_valid(v) and v.global_position.distance_to(global_position) <= explode_radius:
			if v.has_method("take_damage"): 
				v.take_damage(damage) # Hajar musuh dengan damage raksasa
			
	# Beri tahu manajer bahwa kotak grid ini sudah kosong kembali
	on_death.emit(self)
	queue_free() # Lenyapkan sisa bom dari layar
