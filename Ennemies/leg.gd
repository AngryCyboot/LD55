extends AnimatableBody3D
class_name Leg

@export var max_speed : float = 10
@export var max_extention : float = 4
@export var close_enough : float = 0.5
@export var leg_animation : Curve
@export var particules : PackedScene
@export var area : Area3D

@onready var visual : MeshInstance3D = $LegVisual
@onready var parent : Node3D = get_parent()
@onready var boss : Node3D = $"../../.."

var is_mobile : bool = true
var speed : float = 0
var rest_pos :Node3D = Node3D.new()

func init():
	$"..".add_child.call_deferred(rest_pos)
	rest_pos.position = position
	rest_pos.name = name + "RestPos"
	top_level = true

func _process(delta):
	var extention : float = global_position.distance_to(rest_pos.global_position)
	if extention> max_extention+close_enough*2 and not is_mobile:
		mobile(true)
	if is_mobile:
		step(compute_foot_target(),delta)
		var angle : float = atan2(parent.global_position.x-global_position.x,parent.global_position.z-global_position.z)
		rotation.y = lerp_angle(rotation.y,angle,delta)


func step(foot_target : Vector3,delta : float) -> void:
	var dist : float = foot_target.distance_to(Vector3(global_position.x,0,global_position.z))
	if dist > close_enough or global_position.y > close_enough/2:
		var target_height : float = leg_animation.sample(dist-close_enough)*max_extention
		if target_height > max_extention : target_height=max_extention
		if dist < close_enough:
			speed = max_speed
		elif dist*2> speed and speed < max_speed:
			speed += (max_speed-speed)*delta
		elif speed > dist*2 and speed > max_speed/2:
			speed -= speed*delta
		global_position.y += (target_height-global_position.y)*delta*speed
		var rotation_radius : float = boss.global_position.distance_to(global_position) +10
		var rotation_speed : float = tan(deg_to_rad(boss.angular_velocity.y)) * rotation_radius *15
		var actual_speed : float = speed + boss.linear_velocity.length() + rotation_speed**2
		var dir : Vector3 = Vector3(foot_target.x,0,foot_target.z)
		global_position = global_position.move_toward(dir,delta*actual_speed)
	else:
		mobile(false)

func compute_foot_target(target: Vector3 = boss._target_node.global_position) -> Vector3:
	var foot_target: Vector3 = $"..".global_position.direction_to(target)
	foot_target = foot_target * (max_extention-close_enough) + rest_pos.global_position
	foot_target.y = 0
	return foot_target

func mobile(x : bool)-> void:
	if x != is_mobile:
		is_mobile = x
		#visual.set_instance_shader_parameter("lights",int(is_mobile)-1)
		speed = is_mobile
		if is_mobile :
			parent.mobile += 1
		else:
			parent.mobile -= 1
			if area!= null : damage()
			$Stomp.play()

func damage() -> void :
	var boom : GPUParticles3D = particules.instantiate()
	get_node("/root").add_child(boom)
	boom.global_position = global_position
	boom.emitting = true
	for bod in area.get_overlapping_bodies():
		if bod.has_method("you_died"): bod.you_died()
