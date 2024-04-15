extends Node3D
class_name LaserBeam

var _canon_node:Node3D=null
var _laser_time := 0.1
var _explosion_time := 2.5
var _explosion_max_scale := 15


@onready var _laser_pivot : Node3D = $LaserPivot
@onready var _laser_mesh : Node3D = $LaserPivot/LaserMesh
@onready var _laser_explosion : Node3D = $LaserExplosion


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	laser_look_at_canon()
	
	# tween animation laserBeam
	var tween_laser = get_tree().create_tween()
	tween_laser.tween_callback(_laser_pivot.show)
	tween_laser.tween_interval(_laser_time)
	tween_laser.tween_callback(_laser_explosion.show)
	tween_laser.tween_property(_laser_explosion, "scale", Vector3.ONE * _explosion_max_scale / 3.0, _explosion_time/3.0)
	tween_laser.tween_callback(_laser_pivot.hide)
	tween_laser.tween_property(_laser_explosion, "scale", Vector3.ONE * _explosion_max_scale * 2 / 3.0, _explosion_time*2/3.0)
	tween_laser.tween_callback(queue_free)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	laser_look_at_canon()

func laser_look_at_canon():
	assert(_canon_node)
	var position_to_follow = _canon_node.global_position
	var height := global_position.distance_to(position_to_follow)
	_laser_mesh.scale = Vector3(1,height,1)
	_laser_mesh.position = Vector3(0,0,height/2)
	_laser_pivot.look_at(position_to_follow, Vector3.UP, true)


func body_entered_laser_explosion(body: Node3D) -> void:
	if body.has_method("you_died"):
		body.you_died()
	elif body.has_method("hit"):
		body.hit()
