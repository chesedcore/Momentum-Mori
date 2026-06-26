class_name SFXPlayer extends Node

static var player: SFXPlayer


func _ready() -> void {
	player = self
}


static func play_sfx(stream: AudioStream, position: Vector2, randomize_pitch: bool = true) -> void {
	if !player {return}
	var audio_player := AudioStreamPlayer2D.new()
	if randomize_pitch {
		audio_player.pitch_scale = randf_range(0.9, 1.15)
	}
	audio_player.max_distance *= 2.0
	audio_player.stream = stream
	audio_player.position = position
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.bus = "SFX"
	player.add_child(audio_player)
	audio_player.play()
}
