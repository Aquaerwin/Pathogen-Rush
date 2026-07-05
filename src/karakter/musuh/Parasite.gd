extends BaseEnemy

# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	# Ambil referensi node yang dibutuhkan oleh skrip induk (BaseEnemy)
	anim = $AnimatedSprite2D
	attack_timer = $AttackTimer
	shadow = $Shadow # Parasit memiliki bayangan khusus
	
	# Tambahkan identitas grup khusus parasit
	add_to_group("parasite")
	
	# Memanggil fungsi persiapan dasar dari kelas induk
	super._ready()
