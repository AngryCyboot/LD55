extends NavAgent
class_name Boss

signal character_entered_unsummoning_area(boss)
signal character_exited_unsummoning_area(boss)


@export var move_left_sound : AudioStreamPlayer3D
@export var move_right_sound : AudioStreamPlayer3D
@export var unsummon_color_code : Vector3 = Vector3(1,1,2)

var _audio_delay_timer := Timer.new()
var sbires : Array[NavAgent]

@onready var unsummoning_area:Area3D=$BossUnsummoningArea
@onready var prompt :Sprite3D=$Sprite3D


func _ready() -> void:
	super() # call parent method
	unsummoning_area.connect("body_entered", _body_entered_unsummoning_area)
	unsummoning_area.connect("body_exited", _body_exited_unsummoning_area)
	# audio management
	_audio_delay_timer.wait_time = 4.0
	_audio_delay_timer.one_shot = true
	_audio_delay_timer.autostart = true
	add_child(_audio_delay_timer)


func _process(_delta: float) -> void:
	super(_delta) # call parent method
	#Start sound here. No automatic play to manage sound delay
	if move_left_sound and not move_left_sound.playing : move_left_sound.play()
	if move_right_sound and not move_right_sound.playing and _audio_delay_timer.is_stopped(): move_right_sound.play()


func _body_entered_unsummoning_area(body:Node3D):
	if body.is_in_group("Character"):
		emit_signal("character_entered_unsummoning_area", self)

func _body_exited_unsummoning_area(body:Node3D):
	if body.is_in_group("Character"):
		emit_signal("character_exited_unsummoning_area", self)

func unsummon():
	for sbire in sbires:
		sbire.queue_free()
	for bod in unsummoning_area.get_overlapping_bodies():
		_body_exited_unsummoning_area(bod)
	queue_free()
