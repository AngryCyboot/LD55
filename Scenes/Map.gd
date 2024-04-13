@tool
extends MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mesh_size = ProjectSettings.get_setting("specific/world/mesh_size", Vector2(1300,1300))
	scale.x = mesh_size.x
	scale.z = mesh_size.y
