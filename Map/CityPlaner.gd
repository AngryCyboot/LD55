extends MultiMeshInstance3D

@export var space : float = 10
@export var village_radius : float = 50

@onready var houses : MultiMesh = $".".multimesh

func _ready():
	var last_pos : Vector3 = Vector3.ZERO
	var radius : float = village_radius
	var x = 0
	for i in houses.instance_count:
		var angle : float = atan(space/radius)
		var pos : Vector3 = Vector3(cos(angle*x),0,sin(angle*x))
		var jiggle: Vector3 = Vector3(randf_range(-1,1),0,randf_range(-1,1))
		pos *= radius
		pos += jiggle*0.5
		var trans : Transform3D = Transform3D(Basis(),pos)
		trans = trans.looking_at(-jiggle*randf_range(1,50))
		houses.set_instance_transform(i,trans)
		if (x+1)*angle > TAU:
			x = 0
			radius -= space + randf_range(0,1)
		else:
			x+=1
