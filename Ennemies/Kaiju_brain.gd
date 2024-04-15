extends Node3D

@export var max_angle : float = 30
@export var light_colors : PackedColorArray = [Color.RED,Color.GREEN,Color.ORANGE]
@export var max_range : float = 100
@export var attack_length : float = 1
@export var is_head := false


@onready var agent : NavAgent = $".."
@onready var pivot : Node3D = get_child(0).get_child(0)
@onready var _laser_beam_scene : PackedScene = preload("res://Ennemies/Attacks/LaserBeam.tscn")
@onready var _targetted_scene : PackedScene = preload("res://Ennemies/Attacks/targetted.tscn")
@onready var _targetted : Node3D = null


var target : Node3D
var is_in_line_of_sight : bool = false
var charge_timer : float = 0
var charge_duration : float = 4
var lights : Array[SpotLight3D]
var is_in_range : bool = false
var attack_timer : float = 0
var attack_duration : float = 2.4


func _ready():
	for light in pivot.get_children():
		if light is SpotLight3D: lights.append(light)
	
	_targetted = _targetted_scene.instantiate()
	get_tree().root.add_child(_targetted)


func _process(delta):
	target = agent._target_node
	if charge_timer >= charge_duration:
		attack(delta)
	else:
		watch()
		charging(delta)


func watch() -> void :
	var dir : Vector3 = target.global_position.direction_to(global_position)
	if dir.dot(-get_child(0).global_basis.z) > sin(deg_to_rad(max_angle)):
		pivot.look_at(target.global_position,Vector3.UP,true)
		var dist: float = global_position.distance_to(target.global_position)
		is_in_range = true if dist < max_range else false
		is_in_line_of_sight = true
	else:
		is_in_line_of_sight = false
		is_in_range = false


func attack(delta : float) -> void :
	if attack_timer == 0: # attack beginning
		_targetted.global_position = target.global_position
		create_laser_beam(target.global_position)
		if is_head:
			var target_direction = (target.global_position - global_position).normalized()
			target_direction = target_direction.project(Vector3(target_direction.x,0,target_direction.z))
			var tween_attack = create_tween()
			tween_attack.tween_interval(0.8)
			tween_attack.tween_callback(create_laser_beam.bind(target.global_position + target_direction * 5))
			tween_attack.tween_interval(0.8)
			tween_attack.tween_callback(create_laser_beam.bind(target.global_position + target_direction * 10))
			tween_attack.tween_interval(0.8)
			tween_attack.tween_callback(create_laser_beam.bind(target.global_position + target_direction * 15))
	
	set_light_color(0)
	attack_timer += delta
	if attack_timer >= attack_duration :
		attack_timer = 0
		charge_timer = 0

func charging(delta : float) -> void :
	if is_in_line_of_sight and charge_timer<charge_duration and is_in_range:
		charge_timer += delta
		set_light_color(2)
	elif charge_timer>0 and not is_in_line_of_sight:
		charge_timer -= delta
		set_light_color(1)
	
	_targetted.global_position = target.global_position + (Vector3.UP * 0.1)
	_targetted.visible = is_in_line_of_sight and is_in_range


func create_laser_beam(explosion_position:Vector3):
	var laser_beam :LaserBeam= _laser_beam_scene.instantiate() as LaserBeam
	laser_beam._canon_node = self
	get_tree().root.add_child(laser_beam, true)
	laser_beam.global_position = explosion_position


func set_light_color(i : int)-> void :
	for light in lights:
		light.light_color = light_colors[i]
	pivot.get_child(0).set_instance_shader_parameter("lights",i)
