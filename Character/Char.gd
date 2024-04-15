extends CharacterBody3D


@export var dash_time : float = 0.2
@export var dash_speed : float = 20
@export var dash_sound : AudioStreamPlayer3D
@export var death_sound : AudioStreamPlayer3D
@export var spawn_sound : AudioStreamPlayer3D
@export var village : Node3D
@export var environement : Environment

var dashing : bool = false
var timer : float = 0
var _current_boss:Boss = null
var _current_unsummoning_circle:Node3D = null
var _current_unsummoning_circle_part:CirclePart = null
var alive : bool = true

@onready var _unsummoning_circle_scene:= preload("res://Character/UnsummonCircleExample.tscn")

func _ready():
	# todo: a boss spawner and a signal "boss_spawned" 
	for b in get_tree().get_nodes_in_group("Boss"):
		b.connect("character_entered_unsummoning_area", enter_boss_unsummoning_area)
		b.connect("character_exited_unsummoning_area", exit_boss_unsummoning_area)


func _process(delta):
	if alive:
		if not dashing :
			var char_input : Vector2 = Input.get_vector("West", "East", "North", "South")
			velocity = Vector3(char_input.x,0,char_input.y)*delta*500
		else:
			if timer < dash_time:
				timer += delta
			else:
				dashing = false
		move_and_slide()
	else:
		timer+=delta
		respawn()

func _input(event):
	if event.is_action_pressed("Dash") and not dashing:
		dashing = true
		if not dash_sound.playing : dash_sound.play()
		timer = 0
		velocity *= dash_speed
	if event.is_action_pressed("Context"):
		if _current_unsummoning_circle == null:
			if _current_boss:
				draw_unsummon_circle()
		elif _current_unsummoning_circle_part != null:
			draw_unsummon_circle_part()


func draw_unsummon_circle():
	_current_unsummoning_circle = _unsummoning_circle_scene.instantiate()
	_current_unsummoning_circle.position = Vector3(global_position.x, 0.1, global_position.z)
	_current_unsummoning_circle.connect("character_entered_part", enter_part)
	_current_unsummoning_circle.connect("character_exited_part", exit_part)
	_current_unsummoning_circle._boss_to_unsummon = _current_boss
	get_tree().root.add_child(_current_unsummoning_circle, true)


func draw_unsummon_circle_part():
	_current_unsummoning_circle_part.next_one()


func enter_part(part:CirclePart):
	_current_unsummoning_circle_part = part


func exit_part(part:CirclePart):
	if part == _current_unsummoning_circle_part:
		_current_unsummoning_circle_part = null


func enter_boss_unsummoning_area(boss:Boss):
	_current_boss = boss


func exit_boss_unsummoning_area(boss:Boss):
	if boss == _current_boss:
		_current_boss = null

func you_died() -> void :
	alive = false
	timer = 0
	AudioServer.set_bus_effect_enabled(0,0,true)
	environement.adjustment_saturation = 0.5

func respawn() -> void:
	if timer > 0.8 and global_position.distance_to(village.spawn()) > 1:
		global_position = village.spawn()
	elif timer > 1.6:
		alive = true
		AudioServer.set_bus_effect_enabled(0,0,false)
		environement.adjustment_saturation = 1
	elif timer >1.1:
		environement.adjustment_saturation = timer-0.6
