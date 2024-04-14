extends MeshInstance3D
class_name CirclePart

@export var materials : Array[Material] = []
var material_id := -1


func next_one():
	material_id = ( material_id + 1 ) % materials.size()
	material_override = materials[material_id]
