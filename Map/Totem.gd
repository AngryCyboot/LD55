extends StaticBody3D

func _process(_delta):
	position=position

func hit():
	$"../../..".destroyed_totem()
	$"..".queue_free()
