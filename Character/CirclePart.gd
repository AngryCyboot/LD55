extends Node3D
class_name CirclePart

@export var materials : Array[Material] = []
var material_id := -1

@onready var prompt : Sprite3D = $Sprite3D
@onready var area : Area3D = $Center

func next_one():
	material_id = ( material_id + 1 ) % materials.size()
	$Center/ColorViz.material_override = materials[material_id]
	get_parent().check_completion()
