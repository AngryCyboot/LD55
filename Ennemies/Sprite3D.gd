extends Sprite3D

var main_cam : Camera3D

@export var dist : float = 60

func _ready():
	main_cam = get_viewport().get_camera_3d()

func _process(_delta):
	if visible :
		var dir : Vector3 = $"..".global_position.direction_to(main_cam.global_position)
		dir *= dist
		dir.y = 5
		global_position = dir + $"..".global_position
