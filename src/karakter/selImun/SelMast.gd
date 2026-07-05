extends BaseCell

# ==============================================================================
# EXPORT VARIABLES
# Pengaturan daya ledak via Inspector
# ==============================================================================
@export var damage: int # Besar kerusakan ranjau saat meledak
@export var explode_radius: float # Radius jarak jangkuan ledakan


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	super._ready() # Memanggil pengaturan dasar dari kelas induk (BaseCell)
	
	# Hubungkan deteksi area dengan fungsi pemicu ledakan (Sel Mast berfungsi sebagai ranjau darat)
	area_entered.connect(_on_enemy_entered)


# ==============================================================================
# FUNGSI KUSTOM (Custom Methods)
# ==============================================================================
# Menimpa (override) fungsi menerima kerusakan dari kelas induk (BaseCell)
# Agar saat ranjau ini diserang atau ditabrak, ia langsung membalas dengan meledak!
func take_damage(_amount: int):
	if is_dead: return
	explode()


# Mengeksekusi ledakan ranjau, memberikan damage besar dan efek slow ke musuh di sekitarnya
func explode():
	if is_dead: return
	is_dead = true # Tandai mati seketika agar tidak meledak berkali-kali
	
	AudioManager.playSfx("explode")
	var all_viruses = get_tree().get_nodes_in_group("enemy")
	
	for v in all_viruses:
		# Jika musuh valid dan berada tepat di dalam zona radius ledakan
		if is_instance_valid(v) and v.global_position.distance_to(global_position) <= explode_radius:
			if v.has_method("take_damage"): 
				v.take_damage(damage) # Beri damage raksasa
	
	# Mainkan animasi hancur berantakan setelah meledak
	if anim: 
		anim.play("dead")
		await anim.animation_finished
		
	# Lapor ke manajer grid bahwa petak ini sudah kosong dan bisa ditanami lagi
	on_death.emit(self)
	queue_free()


# ==============================================================================
# FUNGSI RESPON SINYAL (Signal Callbacks)
# ==============================================================================
# Dipanggil otomatis saat ada musuh yang menginjak/menyentuh Sel Mast
func _on_enemy_entered(area):
	if is_dead: return
	if area.is_in_group("enemy"):
		explode() # Langsung meledak seketika saat terinjak!
