extends Node3D


signal character_entered_part(part)
signal character_exited_part(part)


var _boss_to_unsummon:Boss= null
var parts:Array[CirclePart]=[]
var color_code : Vector3
var character : Node3D
var part_scene : PackedScene = preload("res://Character/CirclePart.tscn")

@onready var center:Area3D=$Center
@onready var circle_limit:Area3D=$CircleLimit
@onready var link_to_boss:LinkToBoss=$LinkToBoss
@onready var creation_sound : AudioStreamPlayer3D = $creation

@export var size : float = 60

func _ready() -> void:
	assert(_boss_to_unsummon)
	if not creation_sound.playing :
		creation_sound.play()
	color_code = _boss_to_unsummon.unsummon_color_code
	var nodes : int = round(color_code.x) + round(color_code.y) + round(color_code.z)
	var angle : float = TAU/nodes
	for i in nodes:
		var n : CirclePart = part_scene.instantiate()
		add_child(n)
		n.position = Vector3(cos(angle*i),0,sin(angle*i))*size
		n.position.y = 0.01
		parts.append(n)
		n.area.connect("body_entered", _body_entered_part_center.bind(n))
		n.area.connect("body_exited", _body_exited_part_center.bind(n))
		
	circle_limit.connect("body_entered", _body_entered_circle)
	circle_limit.connect("body_exited", _body_exited_circle)
	$CircleViz.material_override.set_shader_parameter("size",size)

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
		_boss_to_unsummon.unsummon()
		character.unsummon()
		destroy()

func destroy():
	character._current_unsummoning_circle = null
	character.update_ring()
	queue_free()
