class_name Settings extends CascadeV3

@export var master_slider: HSlider
@export var music_slider: HSlider
@export var sfx_slider: HSlider

const CONFIG_PATH = "user://keybinds.cfg"

func _ready() -> void {
	super()
	_load_audio()
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
}

func _on_master_changed(value: float) -> void {
	if value <= -20.0 {value = -80.0}
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	_save_audio()
}

func _on_music_changed(value: float) -> void {
	if value <= -20.0 {value = -80.0}
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	_save_audio()
}

func _on_sfx_changed(value: float) -> void {
	if value <= -20.0 {value = -80.0}
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)
	_save_audio()
}

func _save_audio() -> void {
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	config.set_value("audio", "master", master_slider.value)
	config.set_value("audio", "music", music_slider.value)
	config.set_value("audio", "sfx", sfx_slider.value)
	config.save(CONFIG_PATH)
}

func _load_audio() -> void {
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK: return
	master_slider.value = config.get_value("audio", "master", 1.0)
	music_slider.value = config.get_value("audio", "music", 1.0)
	sfx_slider.value = config.get_value("audio", "sfx", 1.0)
	_on_master_changed(master_slider.value)
	_on_music_changed(music_slider.value)
	_on_sfx_changed(sfx_slider.value)
}

static func load_audio_independent() -> void {
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK: return
	
	var master_value := config.get_value("audio", "master", 1.0) as float
	if master_value <= -20.0 {master_value = -80.0}
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_value)
	
	var music_value := config.get_value("audio", "music", 1.0) as float
	if music_value <= -20.0 {master_value = -80.0}
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_value)
	
	var sfx_value := config.get_value("audio", "sfx", 1.0) as float
	if sfx_value <= -20.0 {sfx_value = -80.0}
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_value)
}
