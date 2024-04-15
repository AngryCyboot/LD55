extends Node3D

var boss_scene : PackedScene = preload("res://Ennemies/Boss.tscn")
var sbire_scene :  PackedScene = preload("res://Ennemies/Sbire.tscn")

@export var spawn_radius : float = 1000
@export var spawn_time : float = 60
@export var char : CharacterBody3D

@onready var timer : float = spawn_time -5

func _process(delta):
	timer += delta
	if timer > spawn_time :
		var boss : Boss = boss_scene.instantiate()
		var i : int = randi_range(3,5)
		var angle : float = randf_range(0,TAU)
		boss.position = Vector3(cos(angle),0,sin(angle))*spawn_radius
		boss.rotate_y(-angle)
		$Enemies.add_child(boss)
		for x in i:
			angle = float(x/float(i)) * TAU
			var sbire : NavAgent = sbire_scene.instantiate()
			boss.sbires.append(sbire)
			sbire._my_boss = boss
			var pos = Vector3(cos(angle),0,sin(angle))*60
			boss.add_sibling(sbire)
			sbire.global_position = pos + boss.global_position
		char.boss_spawned(boss)
		timer = 0
