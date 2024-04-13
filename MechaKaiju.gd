extends AnimatableBody3D

@export var max_speed : float = 1
@export var target : Vector3 = Vector3.ZERO

var legs : Array[Leg]
var speed : float = 0

func _ready():
	for leg : Node3D in $MeshInstance3D/Legs.get_children():
		if leg is Leg :
			legs.append(leg)

func _process(delta):
	var dist : float = target.distance_to(global_position)
	if dist*2 > speed and speed < max_speed:
		speed += (max_speed-speed)*delta
	elif speed > dist*2 and speed > 0:
		speed -= speed*delta
	if dist> 0.1:
		var angle : float = atan2(target.x-global_position.x,target.z-global_position.z)
		global_rotation.y = lerp_angle(global_rotation.y,angle,(delta*speed)/10)
		global_position = global_position.move_toward(target,delta*speed)
