extends Node3D

var boss_scene : PackedScene
#var sbire_scene :  PackedScene = preload("res://Ennemies/Sbire.tscn")
var init : bool = false

@export var spawn_radius : float = 1000
@export var spawn_time : float = 60


@onready var _char : CharacterBody3D = get_tree().get_first_node_in_group("Character")
@onready var timer : float = spawn_time - 5

func _process(delta):
	var paused : bool = ProjectSettings.get_setting("specific/state/paused")
	timer += delta if not paused else 0
	if timer > spawn_time :
		if not init :
			boss_scene = load("res://Ennemies/Boss.tscn")
			init = true
		var boss : Boss = boss_scene.instantiate()
		#var i : int = randi_range(3,5)
		var angle : float = randf_range(0,TAU)
		boss.position = Vector3(cos(angle),0,sin(angle))*spawn_radius
		boss.rotate_y(-angle)
		var code : Array = [randi_range(0,2),randi_range(0,2),randi_range(0,2)]
		if code[0]+code[1]+code[2] < 2:
			code[randi_range(0,2)] +=1
			code[randi_range(0,2)] +=1
		boss.unsummon_color_code = Vector3(code[0],code[1],code[2])
		$Enemies.add_child(boss)
		#for x in i:
			#angle = float(x/float(i)) * TAU
			#var sbire : NavAgent = sbire_scene.instantiate()
			#boss.sbires.append(sbire)
			#sbire._my_boss = boss
			#var pos = Vector3(cos(angle),0,sin(angle))*60
			#boss.add_sibling(sbire)
			#sbire.global_position = pos + boss.global_position
		_char.boss_spawned(boss)
		timer = 0
