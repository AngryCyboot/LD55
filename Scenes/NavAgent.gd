extends CharacterBody3D
class_name NavAgent


@export var _nav_agent:NavigationAgent3D = null


var _my_boss : NavAgent
var _speed = ProjectSettings.get_setting("specific/boss/speed", 10)
var _char_attraction_distance = ProjectSettings.get_setting("specific/boss/char_attraction_distance", 50)
var _sbire_min_distance = ProjectSettings.get_setting("specific/boss/sbire_min_distance", 20)
var _sbire_max_distance = ProjectSettings.get_setting("specific/boss/sbire_max_distance", 80)
enum FollowState { Totem, Character, Boss }
var _follow_state := FollowState.Totem


@onready var _character : Node3D = get_tree().get_first_node_in_group("Character")


func _physics_process(delta):
	if _nav_agent.is_navigation_finished():
		return
	var next_position = _nav_agent.get_next_path_position()
	var offset = next_position - global_position
	global_position = global_position.move_toward(next_position, delta * _speed)
	move_and_slide()

	# Make the NavAgent look at the direction we're traveling.
	# Clamp y to 0 so the robot only looks left and right, not up/down.
	offset.y = 0
	look_at(global_position + offset, Vector3.UP)


func _process(_delta: float) -> void:
	determine_target()
	_nav_agent.target_position = _target_node.global_position

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
