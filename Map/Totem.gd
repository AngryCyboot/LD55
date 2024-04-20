extends StaticBody3D

var timer : float = 0
var collapse : bool = false
var sfx : Array[AudioStreamMP3] = [
	preload("res://Resources/Sound effects/meca_step.mp3"),
	preload("res://Resources/Sound effects/totem_destruction.mp3")
]
var playback : AudioStreamPlaybackPolyphonic

func _process(delta):
	position=position
	if collapse:
		timer += delta
		$"..".position.y -= delta * 15
		if timer < randf_range(0,1):
			playback.play_stream(sfx.pick_random())
		if timer > 1:
			$"..".visible =false
		elif timer > 2:
			$"..".queue_free()

func hit():
	if not collapse:
		$"../../..".destroyed_totem()
		$Destruction.play()
		playback = $Destruction.get_stream_playback()
		playback.play_stream(sfx[0])
		collapse = true
