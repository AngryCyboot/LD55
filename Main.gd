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
		var r : int = randi_range(0,2)
		var g : int = randi_range(0,2)
		var b : int = randi_range(0,2)
		if r+g+b == 0:
			var code : Array = [r,g,b]
			code[randi_range(0,2)] +=1
			code[randi_range(0,2)] +=1
		boss.unsummon_color_code = Vector3(r,g,b)
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
