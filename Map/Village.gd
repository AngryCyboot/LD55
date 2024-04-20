extends Node3D

var totems: int = 4

func spawn() -> Vector3:
	return $SpawnPoint.global_position

func destroyed_totem():
	totems -=1
	if totems ==0:
		$"../Char/MainCam/UI".failure()
