extends AnimatableBody3D
class_name Leg

@export var max_speed : float = 10
@export var max_extention : float = 4

@onready var visual : MeshInstance3D = $LegVisual
@onready var parent : Node3D = get_parent()

var mobile : bool = true
var speed : float = 0
var rest_pos :Node3D
var last_pos : Vector3

func _ready():
	rest_pos = Node3D.new()
	$"..".add_child.call_deferred(rest_pos)
	rest_pos.position = position
	rest_pos.name = name + "RestPos"
	top_level = true

func _process(delta):
	var extention : float = global_position.distance_to(rest_pos.global_position)
	if extention> max_extention*1.1:
		mobile = true
		visual.set_instance_shader_parameter("mobile",mobile)
	if mobile:
		step($"../../..".target,delta)
		last_pos = global_position
		var angle : float = atan2(parent.global_position.x-global_position.x,parent.global_position.z-global_position.z)
		rotation.y = lerp_angle(rotation.y,angle,delta)

func step(target : Vector3,delta : float) -> void:
	var foot_target :Vector3 = $"..".global_position.direction_to(target)
	foot_target = foot_target * max_extention + rest_pos.global_position
	var dist : float = foot_target.distance_to(Vector3(global_position.x,0,global_position.z))
	if dist > 0.1:
		var target_height : float = dist*2
		if dist*2> speed and speed < max_speed:
			speed += (max_speed-speed)*delta*2
		elif speed > dist*2 and speed > 5:
			speed -= speed*delta*2
		var dir : Vector3 = Vector3(foot_target.x,target_height,foot_target.z)
		global_position = global_position.move_toward(dir,delta*speed)
	else:
		mobile = false
		visual.set_instance_shader_parameter("mobile",mobile)
