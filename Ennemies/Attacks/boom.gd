extends GPUParticles3D

var timer : float = 0

func _process(delta):
	timer += delta
	if timer > lifetime:
		queue_free()
