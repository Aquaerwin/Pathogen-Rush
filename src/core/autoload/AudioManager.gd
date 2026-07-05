extends Node

const sfxSize := 10 # Membatasi suara efek yang bisa diputar bersamaan

#Preload semua Efek Suara yang dibutuhkan
var sfx := {
	"click": preload("res://assets/audio/button-click.wav"),
	"plant": preload("res://assets/audio/blop.wav"),
	"shoot": preload("res://assets/audio/shot.wav"),
	"hit": preload("res://assets/audio/splash.wav"),
	"bite": preload("res://assets/audio/bite.wav"),
	"explode": preload("res://assets/audio/explosion.wav"),
	"collect": preload("res://assets/audio/collect.wav"),
	"win": preload("res://assets/audio/win.wav"),
	"lose": preload("res://assets/audio/lose.mp3"),
	"finalwave": preload("res://assets/audio/finalwave.wav")
}

# Preload Musik dalam game
var bgm := {
	"ui": preload("res://assets/audio/BgmUI.wav"),
	"battle": preload("res://assets/audio/Battle.wav")
}


var availPlay: Array[AudioStreamPlayer] = [] # Daftar yang sedang tidak diputar
var musikPlay: AudioStreamPlayer # Pemutar khusus untuk musik



func _ready(): # fungsi bawaan godot
	process_mode = Node.PROCESS_MODE_ALWAYS# Audio selalu hidup walau game sedang di-pause

	# Mengambil nilai pengaturan volume yang sudah di simpan
	volume("Music", Save.music_volume)
	volume("Sfx", Save.sfx_volume)

	# Siapkan pemutar Musik
	musikPlay = _create_player("Music")

	# Siapkan tempat pemutar SFX agar tidak memberatkan memori
	for i in sfxSize:
		var player := _create_player("Sfx")
		player.finished.connect(func(): _return_player(player))
		availPlay.append(player)



# Membuat AudioStreamPlayer baru
func _create_player(bus: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = bus
	add_child(player)
	return player



# Mengembalikan efek suara yang sudah diputar ke penyimpanan, agar dapat diputar lagi
func _return_player(player: AudioStreamPlayer):
	if not availPlay.has(player):
		availPlay.append(player)


# Mengubah volume untuk Bus tertentu (skala 0-100)
func volume(bus_name: String, value: float):
	var idx := AudioServer.get_bus_index(bus_name)

	if idx == -1: return

	# Jika volume sangat kecil (di bawah 1), matikan total (Mute)
	AudioServer.set_bus_mute(idx, value <= 0.01)

	if value > 0.01:
		AudioServer.set_bus_volume_db(idx, linear_to_db(value / 100.0))



# Memutar Efek Suara (SFX)
func playSfx(sound_name: String, random_pitch := false):
	if availPlay.is_empty(): return

	var stream: AudioStream = sfx.get(sound_name)
	if stream == null: return

	var player: AudioStreamPlayer = availPlay.pop_front()
	player.stream = stream
	player.pitch_scale = randf_range(0.8, 1.2) if random_pitch else 1.0
	player.play()



# Memutar Musik Latar (BGM)
func playMusic(sound_name: String):
	var stream: AudioStream = bgm.get(sound_name)
	if stream == null: return

	# Jangan ulangi jika musik yang sama sedang diputar
	if musikPlay.stream == stream and musikPlay.playing: return

	musikPlay.stream = stream
	musikPlay.play()



# Menghentikan BGM
func stopMusic():
	musikPlay.stop()
