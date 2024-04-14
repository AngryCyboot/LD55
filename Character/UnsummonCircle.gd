extends Node3D


signal character_entered_part(part)
signal character_exited_part(part)


var parts:Array[CirclePart]=[]
@onready var center:Area3D=$Center


func _ready() -> void:
	pass # Replace with function body.
	for n in get_children():
		if n is CirclePart:
			parts.append(n)
			n.area.connect("body_entered", _body_entered_part_center.bind(n))
			n.area.connect("body_exited", _body_exited_part_center.bind(n))


func _body_entered_part_center(body:Node3D, part:CirclePart):
	if body.is_in_group("Character"):
		emit_signal("character_entered_part", part)


func _body_exited_part_center(body:Node3D, part:CirclePart):
	if body.is_in_group("Character"):
		emit_signal("character_exited_part", part)
