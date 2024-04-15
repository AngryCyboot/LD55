extends Node3D
class_name LinkToBoss


@export var material_too_far:Material=null
@export var material_inside:Material=null
@onready var link_to_boss_mesh:MeshInstance3D=$Mesh
@onready var _boss_to_unsummon:Boss=get_parent()._boss_to_unsummon


func _ready():
	boss_enter_circle()


func _process(_delta: float) -> void:
	var possition_to_follow = _boss_to_unsummon.global_position + Vector3(0,10,0)
	var height := global_position.distance_to(possition_to_follow)
	link_to_boss_mesh.scale = Vector3(1,height,1)
	link_to_boss_mesh.position = Vector3(0,0,height/2)
	look_at(possition_to_follow, Vector3.UP, true)


func boss_enter_circle():
	link_to_boss_mesh.material_override = material_inside


func boss_exit_circle():
	link_to_boss_mesh.material_override = material_too_far
