extends RigidBody3D
class_name NavAgent


@export var _my_boss : NavAgent
@export var move_left_sound : AudioStreamPlayer3D
@export var move_right_sound : AudioStreamPlayer3D

var _audio_delay_timer := Timer.new()
var _speed = ProjectSettings.get_setting("specific/enemies/sbire/speed", 15)
var _angular_speed = deg_to_rad(ProjectSettings.get_setting("specific/enemies/sbire/angular_speed", 0.5))
var _char_attraction_distance = ProjectSettings.get_setting("specific/enemies/char_attraction_distance", 80)
var _destination_distance = ProjectSettings.get_setting("specific/enemies/sbire_destination_offset", 5)
var _sbire_min_distance = ProjectSettings.get_setting("specific/enemies/sbire/min_distance_to_boss", 20)
var _sbire_max_distance = ProjectSettings.get_setting("specific/enemies/sbire/max_distance_to_boss", 80)
enum FollowState { Totem, Character, Boss }
var _follow_state := FollowState.Totem


@onready var _character : Node3D = get_tree().get_first_node_in_group("Character")


func _ready() -> void:
	_audio_delay_timer.wait_time = 4.0
	_audio_delay_timer.one_shot = true
	_audio_delay_timer.autostart = true
	add_child(_audio_delay_timer)
	if not _my_boss:
		_speed = ProjectSettings.get_setting("specific/enemies/boss/speed", 5)
		_angular_speed = deg_to_rad(ProjectSettings.get_setting("specific/enemies/boss/angular_speed", 0.35))
		_destination_distance = ProjectSettings.get_setting("specific/enemies/boss/destination_offset", 20)
	linear_velocity = Vector3(0, 0, _speed)	


func look_follow(state: PhysicsDirectBodyState3D, current_transform: Transform3D, target_position: Vector3) -> void:
	var forward_local_axis: Vector3 = Vector3(0, 0, 1)
	var forward_dir: Vector3 = (current_transform.basis * forward_local_axis).normalized()
	var target_dir: Vector3 = (target_position - current_transform.origin).normalized()
	var local_speed: float = clampf(_angular_speed, 0, acos(forward_dir.dot(target_dir)))
	if abs(forward_dir.dot(target_dir)) > 1e-4:
		state.angular_velocity = local_speed * forward_dir.cross(target_dir) / state.step
	if current_transform.origin.distance_to(target_position) > _destination_distance:
		linear_velocity = forward_dir * _speed


func _integrate_forces(state):
	if _target_node:
		var target_position = _target_node.global_transform.origin
		look_follow(state, global_transform, target_position)


func _process(_delta: float) -> void:
	determine_target()
	#Start sound here. No automatic play to manage sound delay
	if move_left_sound and not move_left_sound.playing : move_left_sound.play()
	if move_right_sound and not move_right_sound.playing and _audio_delay_timer.is_stopped(): move_right_sound.play()

var _target_node:Node3D=null
func determine_target() -> void:
	var char_distance := global_position.distance_to(_character.global_position)
	var my_boss_distance := global_position.distance_to(_my_boss.global_position) if _my_boss else 0.0
	var closest_totem_distance := INF
	var closest_totem : Node3D = null
	for t in get_tree().get_nodes_in_group("Totem"):
		var dist = global_position.distance_to(t.global_position)
		if dist < closest_totem_distance:
			closest_totem_distance = dist
			closest_totem = t

	match _follow_state:
		FollowState.Totem:
			if my_boss_distance > _sbire_max_distance:
				_target_node = _my_boss
				_follow_state = FollowState.Boss
			elif char_distance <= _char_attraction_distance:
				_target_node = _character
				_follow_state = FollowState.Character
			else:
				_target_node = closest_totem
		FollowState.Character:
			if my_boss_distance > _sbire_max_distance:
				_target_node = _my_boss
				_follow_state = FollowState.Boss
			elif char_distance > _char_attraction_distance:
				_target_node = closest_totem
				_follow_state = FollowState.Totem
		FollowState.Boss:
			assert(_my_boss)
			if my_boss_distance <= _sbire_min_distance:
				_target_node = closest_totem
				_follow_state = FollowState.Totem
