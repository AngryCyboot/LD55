extends Node3D


signal character_entered_part(part)
signal character_exited_part(part)


var _boss_to_unsummon:NavAgent= null
var parts:Array[CirclePart]=[]
@onready var center:Area3D=$Center
@onready var circle_limit:Area3D=$CircleLimit
@onready var link_to_boss:LinkToBoss=$LinkToBoss


func _ready() -> void:
	assert(_boss_to_unsummon)
	for n in get_children():
		if n is CirclePart:
			parts.append(n)
			n.area.connect("body_entered", _body_entered_part_center.bind(n))
			n.area.connect("body_exited", _body_exited_part_center.bind(n))
	circle_limit.connect("body_entered", _body_entered_circle)
	circle_limit.connect("body_exited", _body_exited_circle)


func _body_entered_part_center(body:Node3D, part:CirclePart):
	if body.is_in_group("Character"):
		emit_signal("character_entered_part", part)


func _body_exited_part_center(body:Node3D, part:CirclePart):
	if body.is_in_group("Character"):
		emit_signal("character_exited_part", part)


func _body_entered_circle(body:Node3D):
	if body.is_in_group("Boss"):
		link_to_boss.boss_enter_circle()


func _body_exited_circle(body:Node3D):
	if body.is_in_group("Character"):
		destroy()
	elif body.is_in_group("Boss"):
		link_to_boss.boss_exit_circle()


func destroy():
	queue_free()
