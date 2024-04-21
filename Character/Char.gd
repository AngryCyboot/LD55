extends CharacterBody3D

@export var movement_speed : float = 30
@export var dash_time : float = 0.2
@export var dash_cooldown_time : float = 1.0
@export var dash_speed : float = 10
@export var dash_sound : AudioStreamPlayer3D
@export var death_sound : AudioStreamPlayer3D
@export var spawn_sound : AudioStreamPlayer3D

var ready_to_dash : bool = true
var timer : float = 0
var cooldown_timer : float = 0
var _current_boss:Boss = null
var _current_unsummoning_circle:Node3D = null
var _current_unsummoning_circle_part:CirclePart = null
var alive : bool = true

@onready var environement : Environment = $"../WorldEnvironment".environment
@onready var village : Node3D = $"../Village"
@onready var ring : MeshInstance3D = $ColoRing
@onready var _unsummoning_circle_scene:= preload("res://Character/UnsummonCircleExample.tscn")
@onready var ui : Control = $MainCam/UI

func _process(delta):
	var paused : bool = ProjectSettings.get_setting("specific/state/paused")
	if not paused:
		if alive:
			#Update timers
			if timer < dash_time:
				timer += delta
			if cooldown_timer < dash_cooldown_time:
				cooldown_timer += delta
			#Dash time ends, reset velocity
			if timer >= dash_time:
				var char_input : Vector2 = Input.get_vector("West", "East", "North", "South")
				velocity = Vector3(char_input.x,0,char_input.y)*movement_speed
			#Cooldown ok ? Enable dash
			if cooldown_timer >= dash_cooldown_time:
				ready_to_dash = true
			$ColoRing.rotate_y(delta)
			move_and_slide()
		else:
			timer+=delta
			respawn()

func _input(event):
	if event.is_action_pressed("Dash") and ready_to_dash:
		ready_to_dash = false
		if not dash_sound.playing : dash_sound.play()
		timer = 0
		cooldown_timer = 0
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
	_current_unsummoning_circle.character = self
	get_tree().root.add_child(_current_unsummoning_circle, true)
	_current_boss.prompt.visible = false
	update_ring()


func draw_unsummon_circle_part():
	_current_unsummoning_circle_part.next_one()


func enter_part(part:CirclePart):
	_current_unsummoning_circle_part = part


func exit_part(part:CirclePart):
	if part == _current_unsummoning_circle_part:
		_current_unsummoning_circle_part = null


func enter_boss_unsummoning_area(boss:Boss):
	_current_boss = boss
	if _current_unsummoning_circle == null:
		boss.prompt.visible = true


func exit_boss_unsummoning_area(boss:Boss):
	if boss == _current_boss:
		_current_boss = null
	boss.prompt.visible = false

func update_ring() -> void:
	if _current_unsummoning_circle != null:
		ring.visible = true
		ring.material_override.set_shader_parameter("color_code",_current_unsummoning_circle.color_code)
	else:
		ring.visible = false

func you_died() -> void :
	alive = false
	timer = 0
	AudioServer.set_bus_effect_enabled(0,0,true)
	#environement.adjustment_saturation = 0.5
	environement.fog_light_energy = 0.5

func boss_spawned(boss)-> void:
		boss.connect("character_entered_unsummoning_area", enter_boss_unsummoning_area)
		boss.connect("character_exited_unsummoning_area", exit_boss_unsummoning_area)

func respawn() -> void:
	if timer > 0.8 and global_position.distance_to(village.spawn()) > 1:
		global_position = village.spawn()
	elif timer > 1.6:
		alive = true
		AudioServer.set_bus_effect_enabled(0,0,false)
		#environement.adjustment_saturation = 1
		environement.fog_light_energy = 0
	elif timer >1.1:
		#environement.adjustment_saturation = timer-0.6
		environement.fog_light_energy = 1.6-timer

func unsummon() -> void:
	$unsummon.play()
	ui.score +=1
