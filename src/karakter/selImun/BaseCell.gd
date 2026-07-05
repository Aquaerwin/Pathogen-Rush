class_name BaseCell extends Area2D

# ==============================================================================
# SIGNALS
# ==============================================================================
# Sinyal yang dipancarkan ke sistem saat sel ini hancur
signal on_death(node)


# ==============================================================================
# EXPORT VARIABLES
# Pengaturan atribut dasar yang bisa diubah via Inspector
# ==============================================================================
@export var hp: int # Darah saat ini
@export var max_hp: int # Darah maksimal
@export var cost: int # Harga untuk menanam sel ini
@export var cooldown_tanam: float # Waktu jeda sebelum bisa menanam sel ini lagi


# ==============================================================================
# PUBLIC VARIABLES
# Variabel yang bisa diakses oleh kelas/node lain
# ==============================================================================
var is_dead: bool = false # Status apakah sel ini sudah mati
var anim: AnimatedSprite2D # Referensi ke node animasi sel


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	add_to_group("cell")
	anim = get_node_or_null("AnimatedSprite2D")


# ==============================================================================
# FUNGSI KUSTOM (Custom Methods)
# ==============================================================================
# Mengurangi darah (HP) sel saat diserang oleh musuh
func take_damage(amount: int):
	if is_dead: return
	hp -= amount
	if hp <= 0: die()


# Menjalankan proses kematian sel, mematikan fungsi internal, dan menghapusnya
func die():
	is_dead = true
	
	# Matikan timer internal jika ada (untuk mencegah error setelah mati)
	var spawn_timer = get_node_or_null("SpawnTimer")
	var attack_timer = get_node_or_null("AttackTimer")
	if spawn_timer: spawn_timer.stop()
	if attack_timer: attack_timer.stop()
	
	# Putar animasi hancur sebelum menghilang dari arena
	if anim: 
		anim.play("dead")
		await anim.animation_finished
		
	on_death.emit(self)
	queue_free() # Hapus sel dari layar permainan
