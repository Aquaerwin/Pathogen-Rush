extends ColorRect

@onready var panel_window = $PanelWindow
@onready var img_karakter = $PanelWindow/ImgKarakter
@onready var lbl_judul = $PanelWindow/LblJudul
@onready var txt_deskripsi = $PanelWindow/TxtDeskripsi
@onready var btn_next = $PanelWindow/BtnNext if $PanelWindow.has_node("BtnNext") else null
@onready var lbl_next = $PanelWindow/BtnNext/LblNext if btn_next and btn_next.has_node("LblNext") else null

var current_level: int = 1
var page_index: int = 0
var info_pages = []

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Biar bisa jalan meski game di-pause
	panel_window.pivot_offset = panel_window.size / 2.0
	panel_window.scale = Vector2.ZERO
	modulate.a = 0.0
	
	if btn_next:
		btn_next.pressed.connect(_on_btn_next)
	Save.language_changed.connect(update_ui)
	
	if info_pages.is_empty():
		setup_info()
	else:
		page_index = 0
		update_ui()
	
	show_panel()

func setup_info():
	if InfoData.level_data.has(current_level):
		info_pages = InfoData.level_data[current_level]
	else:
		info_pages = []
	
	page_index = 0
	update_ui()

func show_panel():
	get_tree().paused = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel_window, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func hide_panel():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(panel_window, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func(): 
		get_tree().paused = false
		queue_free()
	)

func update_ui():
	if info_pages.is_empty():
		hide_panel()
		return
		
	var data = info_pages[page_index]
	
	if ResourceLoader.exists(data.img):
		img_karakter.texture = load(data.img)
	else:
		img_karakter.texture = null
		
	if Save.current_language == "id":
		lbl_judul.text = data.title_id
		txt_deskripsi.text = data.desc_id
		if lbl_next: lbl_next.text = "MULAI" if page_index == info_pages.size() - 1 else "LANJUT"
	else:
		lbl_judul.text = data.title_en
		txt_deskripsi.text = data.desc_en
		if lbl_next: lbl_next.text = "START" if page_index == info_pages.size() - 1 else "NEXT"

func _on_btn_next():
	AudioManager.playSfx("click")
	if page_index < info_pages.size() - 1:
		page_index += 1
		update_ui()
	else:
		hide_panel()

# Memungkinkan pemain menekan di mana saja pada layar (ColorRect) untuk lanjut
func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_btn_next()
