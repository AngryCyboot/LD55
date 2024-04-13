extends CharacterBody3D

@export var dash_time : float = 0.2
@export var dash_speed : float = 20

var dashing : bool = false
var timer : float = 0

func _process(delta):
	if not dashing :
		var char_input : Vector2 = Input.get_vector("West", "East", "North", "South")
		velocity = Vector3(char_input.x,0,char_input.y)*delta*500
	else:
		if timer < dash_time:
			timer += delta
		else:
			dashing = false
	move_and_slide()

func _input(event):
	if event.is_action_pressed("Dash") and not dashing:
		dashing = true
		timer = 0
		velocity *= dash_speed
