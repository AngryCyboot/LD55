extends MultiMeshInstance3D

@export var instances : int = 1000
@export var radius : float = 100

@onready var area : Area3D = $Area3D

var mecha_is_in : bool = false

func _ready():
	setup()
	$Area3D/CollisionShape3D.shape.radius = radius +10

func _process(_delta):
	position = position #voudou magic
	if mecha_is_in:
		var guests : Array[Node3D]
		guests = area.get_overlapping_bodies()
		if guests.size() == 0: mecha_is_in = false
		for i in instances:
			var trans :Transform3D = multimesh.get_instance_transform(i)
			if trans.basis.is_equal_approx(Basis()):
				for mecha in guests:
					var mecha_pos : Vector3 = mecha.global_position-global_position
					if trans.origin.distance_to(mecha_pos) <10:
						trans = trans.looking_at(Vector3(mecha_pos.x,500,mecha_pos.z),Vector3.UP,true)
						multimesh.set_instance_transform(i,trans)

func setup():
	multimesh.instance_count = instances
	for i in instances:
		var angle : float = TAU*(float(i)/float(instances))
		var pos : Vector3 = Vector3(cos(angle),0,sin(angle))* randf_range(0,radius)
		pos.y = randf_range(0,0.5)
		multimesh.set_instance_transform(i,Transform3D(Basis(),pos))

func _on_area_3d_body_entered(_body):
	mecha_is_in = true
