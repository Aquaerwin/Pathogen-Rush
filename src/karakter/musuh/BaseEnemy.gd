class_name BaseEnemy extends Area2D

# ==============================================================================
# SIGNALS
# ==============================================================================
signal base_reached(node) # Dipancarkan saat musuh berhasil menyentuh garis finish
signal on_death(node) # Dipancarkan saat musuh mati (darah habis)


# ==============================================================================
# EXPORT VARIABLES
# Atribut yang bisa disesuaikan via Inspector
# ==============================================================================
@export var hp: int # Total darah musuh
@export var normal_speed: float # Kecepatan jalan normal
@export var attack_damage: int # Besar serangan (gigitan) ke menara


# ==============================================================================
# PUBLIC VARIABLES
# Variabel yang bisa diakses oleh kelas lain
# ==============================================================================
var speed: float # Kecepatan saat ini (bisa berkurang jika terkena slow)
var is_dead: bool = false # Status apakah musuh sudah mati
var target_cell: Node2D = null # Sel/Menara yang sedang diserang
var anim: AnimatedSprite2D # Referensi animasi tubuh
var shadow: AnimatedSprite2D # Referensi animasi bayangan
var attack_timer: Timer # Timer penentu jeda antar gigitan


# ==============================================================================
# PRIVATE VARIABLES
# Variabel internal yang digunakan di dalam skrip ini saja
# ==============================================================================
var slow_timer: Timer # Timer khusus untuk menghitung durasi efek melambat


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	add_to_group("enemy")
	speed = normal_speed
	
	# Membuat dan memasang timer khusus untuk efek serangan pelambat
	slow_timer = Timer.new()
	slow_timer.one_shot = true
	slow_timer.timeout.connect(_on_slow_timeout)
	add_child(slow_timer)
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	if attack_timer:
		attack_timer.timeout.connect(_on_attack)


func _process(delta):
	if is_dead: return
	
	# Jika musuh sedang menempel di menara
	if target_cell and is_instance_valid(target_cell):
		if anim and anim.animation != "attack":
			anim.play("attack")
			if shadow: shadow.play("attack")
			if attack_timer and attack_timer.is_stopped(): attack_timer.start()
	else:
		# Jika jalanan di depan kosong, jalan terus
		target_cell = null
		if attack_timer: attack_timer.stop()
		
		if anim and anim.animation != "walk":
			anim.play("walk")
			if shadow: shadow.play("walk")
			
		position.x -= speed * delta # Bergerak ke arah kiri
		
		# Deteksi apakah musuh sudah sampai di markas (ujung kiri)
		if position.x < 80:
			base_reached.emit(self)
			set_process(false) # Hentikan pergerakan otomatisnya


# ==============================================================================
# FUNGSI KUSTOM (Custom Methods)
# ==============================================================================
# Memberikan efek melambat pada musuh dengan persentase tertentu
func apply_slow(slow_percent: float, duration: float):
	if is_dead: return
	speed = normal_speed * (1.0 - slow_percent)
	slow_timer.start(duration)


# Mengurangi HP musuh saat diserang
func take_damage(amount: int):
	if is_dead: return
	hp -= amount
	if hp <= 0: die()


# Menjalankan proses kematian musuh
func die():
	is_dead = true
	if attack_timer: attack_timer.stop()
	if anim: anim.play("dead")
	if shadow: shadow.play("dead")
	
	# Efek transparan perlahan sebelum lenyap dari arena
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 1.0)
	tw.tween_callback(queue_free)
	
	on_death.emit(self)


# ==============================================================================
# FUNGSI RESPON SINYAL (Signal Callbacks)
# ==============================================================================
# Mengembalikan kecepatan musuh kembali normal setelah durasi efek slow habis
func _on_slow_timeout():
	if is_dead: return
	speed = normal_speed


# Mengeksekusi serangan gigitan musuh ke menara
func _on_attack():
	if is_dead: return
	if is_instance_valid(target_cell) and target_cell.has_method("take_damage"):
		AudioManager.playSfx("bite")
		target_cell.take_damage(attack_damage)
	else:
		target_cell = null
		if anim: anim.play("walk")
		if shadow: shadow.play("walk")
		if attack_timer: attack_timer.stop()


# Dipanggil saat ada area lain yang menyentuh musuh ini
func _on_area_entered(area):
	if is_dead: return
	if area.is_in_group("enemy") or "Bullet" in area.name: return
	
	if area.has_method("take_damage"):
		target_cell = area # Menjadikan penabrak tersebut sebagai target serang


# Dipanggil saat area yang disentuh pergi atau dihancurkan
func _on_area_exited(area):
	if target_cell == area:
		target_cell = null
