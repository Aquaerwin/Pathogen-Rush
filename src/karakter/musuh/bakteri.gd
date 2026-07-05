extends BaseEnemy

var is_charging: bool = true # Menandakan apakah bakteri sedang berlari kencang (belum menabrak)
var charge_damage: int = 1000 # Besar kerusakan instan saat pertama kali menabrak


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	# Ambil referensi node yang dibutuhkan oleh skrip induk
	anim = $AnimatedSprite2D
	attack_timer = $AttackTimer
	
	# Memanggil fungsi persiapan dasar dari kelas induk (BaseEnemy)
	super._ready()


# ==============================================================================
# FUNGSI KUSTOM & OVERRIDE (Custom & Overridden Methods)
# ==============================================================================
# Menimpa (override) fungsi tabrakan bawaan induk untuk menambahkan efek menabrak keras
func _on_area_entered(area):
	if is_dead: return
	if area.is_in_group("enemy") or "Bullet" in area.name: return
		
	# Jika menabrak sel / menara
	if area.has_method("take_damage"):
		if is_charging:
			# Efek menabrak pertama kali: Berikan kerusakan besar seketika!
			area.take_damage(charge_damage)
			is_charging = false

			# Kurangi kecepatan lari bakteri (karena helm/pelindungnya hancur)
			normal_speed = 15.0 # Kecepatan jalan normal setelah menabrak
			speed = normal_speed
			
		# Panggil fungsi tabrakan bawaan induk untuk menetapkan target serang
		super._on_area_entered(area)
