class_name SFXPlayer extends Node

static var player: SFXPlayer


func _ready() -> void {
	player = self
}


static func play_sfx(stream: AudioStream, position: Vector2) -> void {
	if !player {return}
	var audio_player := AudioStreamPlayer2D.new()
	audio_player.stream = stream
	audio_player.position = position
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.bus = "SFX"
	player.add_child(audio_player)
	audio_player.play()
}
