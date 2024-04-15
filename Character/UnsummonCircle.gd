extends Node3D


signal character_entered_part(part)
signal character_exited_part(part)


var _boss_to_unsummon:Boss= null
var parts:Array[CirclePart]=[]
var color_code : Vector3

@onready var center:Area3D=$Center
@onready var circle_limit:Area3D=$CircleLimit
@onready var link_to_boss:LinkToBoss=$LinkToBoss

@export var creation_sound : AudioStreamPlayer3D
@export var unsummon_sound : AudioStreamPlayer3D


func _ready() -> void:
	assert(_boss_to_unsummon)
	if not creation_sound.playing :
		creation_sound.play()
	for n in get_children():
		if n is CirclePart:
			parts.append(n)
			n.area.connect("body_entered", _body_entered_part_center.bind(n))
			n.area.connect("body_exited", _body_exited_part_center.bind(n))
	circle_limit.connect("body_entered", _body_entered_circle)
	circle_limit.connect("body_exited", _body_exited_circle)
	color_code = _boss_to_unsummon.unsummon_color_code


func _body_entered_part_center(body:Node3D, part:CirclePart):
	if body.is_in_group("Character"):
		emit_signal("character_entered_part", part)
		part.prompt.visible = true


func _body_exited_part_center(body:Node3D, part:CirclePart):
	if body.is_in_group("Character"):
		emit_signal("character_exited_part", part)
		part.prompt.visible = false


func _body_entered_circle(body:Node3D):
	if body.is_in_group("Boss"):
		link_to_boss.boss_enter_circle()


func _body_exited_circle(body:Node3D):
	if body.is_in_group("Character"):
		destroy()
	elif body.is_in_group("Boss"):
		link_to_boss.boss_exit_circle()

func check_completion():
	var check : Vector3 = color_code
	for part in parts:
		if part.material_id == 0:
			check.x -= 1
		elif part.material_id == 1:
			check.y -= 1
		elif part.material_id == 2:
			check.z -= 1
	if check == Vector3.ZERO:
		if not unsummon_sound.playing :
			unsummon_sound.play()
		_boss_to_unsummon.unsummon()
		destroy()

func destroy():
	for bod in get_tree().get_nodes_in_group("Character"):
		bod._current_unsummoning_circle = null
		bod.update_ring()
	queue_free()
