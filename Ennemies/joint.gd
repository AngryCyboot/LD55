extends MeshInstance3D

@export var connection : Node3D

@onready var curve: Curve3D = get_child(0).curve

func _ready():
	curve = Curve3D.new()
	curve.add_point(Vector3.ZERO)
	curve.add_point(connection.position)

func _process(_delta):
	global_rotation.y = 0
	var pos : Vector3 = connection.global_position-global_position
	curve.set_point_position(1,pos)
	get_child(0).curve = curve
