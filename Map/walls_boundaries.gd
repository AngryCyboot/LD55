@tool
extends StaticBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var world_size = ProjectSettings.get_setting("specific/world/size", Vector2(1000,1000))
	$CollisionShape3DminusX.position = Vector3(-world_size.x/2, 0, 0)
	$CollisionShape3DplusX.position = Vector3(world_size.x/2, 0, 0)
	$CollisionShape3DminusZ.position = Vector3(0, 0, -world_size.y/2)
	$CollisionShape3DplusZ.position = Vector3(0, 0, world_size.y/2)
