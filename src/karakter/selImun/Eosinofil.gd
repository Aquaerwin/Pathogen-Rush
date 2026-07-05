extends BaseCell

# ==============================================================================
# SIGNALS
# ==============================================================================
# Sinyal untuk melempar peluru, membawa data posisi, kerusakan, dan tipe menara
signal shoot_bullet(pos, dmg, type)


# ==============================================================================
# @ONREADY VARIABLES
# Referensi ke node internal
# ==============================================================================
@onready var attack_timer = $AttackTimer # Timer untuk mengatur jeda (cooldown) tembakan
@onready var attack_range = $AttackRange # Area sensor untuk mendeteksi kedatangan musuh


# ==============================================================================
# EXPORT VARIABLES
# Pengaturan atribut tembakan via Inspector
# ==============================================================================
@export var damage: int


# ==============================================================================
# PUBLIC VARIABLES
# ==============================================================================
var enemies_in_range = [] # Daftar array untuk mencatat semua musuh yang berada dalam jangkauan
var is_attacking = false # Menandakan apakah menara sedang dalam proses animasi melempar


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	super._ready() # Memanggil pengaturan dasar dari kelas induk (BaseCell)
	
	# Menghubungkan sinyal sensor dengan fungsi lokal
	attack_range.area_entered.connect(_on_enemy_entered)
	attack_range.area_exited.connect(_on_enemy_exited)
	
	# Memberikan sedikit pengacakan variasi jeda tembakan agar tidak terlihat kaku / robotik
	attack_timer.wait_time = randf_range(2.8, 3.2)


func _process(_delta):
	if is_dead: return
	
	# Bersihkan memori array dari musuh yang sudah terlanjur mati/hilang dari arena
	for enemy in enemies_in_range.duplicate():
		if not is_instance_valid(enemy): 
			enemies_in_range.erase(enemy)
			
	# Jika daftar musuh tidak kosong, timer sudah mereset, dan tidak sedang melempar
	if enemies_in_range.size() > 0 and attack_timer.is_stopped() and not is_attacking:
		attack()


# ==============================================================================
# FUNGSI KUSTOM (Custom Methods)
# ==============================================================================
# Mengeksekusi rangkaian animasi dan melempar proyektil tembakan ke depan
func attack():
	is_attacking = true
	if anim: anim.play("attack")
	
	# Tunggu sejenak hingga frame animasi Eosinofil pas berada pada posisi tangan melempar (0.3 detik)
	await get_tree().create_timer(0.3).timeout
	
	# Munculkan peluru jika Eosinofil belum dihancurkan oleh musuh
	if not is_dead: 
		shoot_bullet.emit(global_position + Vector2(40, 0), damage, "eosinofil")
		
	# Tunggu dengan sabar hingga seluruh animasi serang selesai dimainkan
	if anim: await anim.animation_finished
	
	# Kembalikan ke posisi siaga dan mulai hitung mundur cooldown tembakan berikutnya
	if not is_dead:
		if anim: anim.play("idle")
		is_attacking = false
		attack_timer.start()


# ==============================================================================
# FUNGSI RESPON SINYAL (Signal Callbacks)
# ==============================================================================
# Mendata musuh yang memasuki zona jarak tembak
func _on_enemy_entered(area):
	if area.is_in_group("enemy") and not enemies_in_range.has(area): 
		enemies_in_range.append(area)


# Menghapus data musuh yang berhasil keluar dari zona jarak tembak
func _on_enemy_exited(area):
	if enemies_in_range.has(area): 
		enemies_in_range.erase(area)
