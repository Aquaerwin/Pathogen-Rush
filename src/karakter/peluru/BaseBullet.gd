class_name BaseBullet extends Area2D

# ==============================================================================
# EXPORT VARIABLES
# Variabel ini disembunyikan dari Inspector karena akan selalu diisi otomatis oleh Menara
var damage: int


# ==============================================================================
# PUBLIC VARIABLES
# ==============================================================================
var speed: float = 400.0 # Kecepatan laju peluru
var is_exploding: bool = false # Status apakah peluru sedang dalam animasi hancur
var anim: AnimatedSprite2D # Referensi ke node animasi peluru


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	# Berikan sedikit variasi kecepatan agar tembakan tidak terlihat robotik
	speed = randf_range(350.0, 450.0)
	anim = get_node_or_null("AnimatedSprite2D")
	
	area_entered.connect(_on_area_entered)
	
	# Hapus peluru dari memori otomatis jika keluar dari layar (untuk optimasi game)
	var vis = get_node_or_null("VisibleOnScreenNotifier2D")
	if vis: vis.screen_exited.connect(queue_free)


func _process(delta):
	# Terus bergerak lurus ke kanan selama belum menabrak sesuatu
	if not is_exploding: 
		position.x += speed * delta


# ==============================================================================
# FUNGSI RESPON SINYAL (Signal Callbacks)
# ==============================================================================
# Dipanggil saat peluru menabrak sesuatu
func _on_area_entered(area):
	if is_exploding: return
	
	# Pastikan yang ditabrak adalah musuh dan memiliki fungsi menerima serangan
	if area.is_in_group("enemy") and area.has_method("take_damage"):
		is_exploding = true
		AudioManager.playSfx("hit", true)
		
		# Paskan posisi ledakan agar persis berada di tubuh musuh yang ditabrak
		global_position = area.global_position
		area.take_damage(damage) # Beri kerusakan pada musuh
		
		# Mainkan animasi hancur berkeping-keping (lendir muncrat)
		if anim:
			anim.play("explode")
			await anim.animation_finished
			
		queue_free() # Lenyapkan peluru secara permanen
