extends BaseEnemy

# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	# Ambil referensi node yang dibutuhkan oleh skrip induk (BaseEnemy)
	anim = $AnimatedSprite2D
	attack_timer = $AttackTimer
	
	# Memanggil fungsi persiapan dasar dari kelas induk
	# Catatan: Virus adalah musuh dasar. Semua fungsi pergerakan, deteksi sel, 
	# menerima damage, dan mati sudah ditangani secara otomatis di BaseEnemy.gd!
	super._ready()
