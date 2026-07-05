extends Control

# ==============================================================================
# @ONREADY & PUBLIC VARIABLES
# ==============================================================================
@onready var logo_kampus = $LogoKampus
@onready var logo_godot = $LogoGodot

var tween: Tween


# ==============================================================================
# FUNGSI BAWAAN GODOT (Built-in Methods)
# ==============================================================================
func _ready():
	# Memastikan logo tidak terlihat saat layar dimuat pertama kali
	logo_kampus.modulate.a = 0.0
	logo_godot.modulate.a = 0.0
	
	# Memulai urutan animasi
	start_load()


# ==============================================================================
# FUNGSI KUSTOM (Custom Methods)
# ==============================================================================
# Mengeksekusi urutan animasi logo kampus dan godot
func start_load():
	tween = create_tween()
	
	# Logo Godot: Muncul lalu menghilang
	tween.tween_property(logo_godot, "modulate:a", 1.0, 1.0).from(0.0)
	tween.tween_interval(1.5)
	tween.tween_property(logo_godot, "modulate:a", 0.0, 1.0)
	
	# Logo Kampus: Muncul lalu menghilang
	tween.tween_property(logo_kampus, "modulate:a", 1.0, 1.0).from(0.0) # Fade In
	tween.tween_interval(1.5) # Jeda waktu
	tween.tween_property(logo_kampus, "modulate:a", 0.0, 1.0) # Fade Out
	
	# Setelah semuanya selesai, pindah ke layar Main Menu
	tween.tween_callback(go_to_main_menu)


# Mengeksekusi perpindahan transisi layar
func go_to_main_menu():
	SceneTransition.change_scene("res://src/ui/mainMenu/MainMenu.tscn")
