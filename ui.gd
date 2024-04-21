extends Control

var button_labels : Array[String] = ["Play","Restart"]
var title_labels : Array[String] = ["UNSUMMONING Dark creatures","You failed to defend the village"]
var game_over : bool = false
var score : int = 0

@onready var start_button : Button = $VBoxContainer/Button
@onready var title : Label = $VBoxContainer/Title
@onready var explanation : Label = $VBoxContainer/explanation

func _ready():
	title.text = title_labels[0]
	start_button.text = button_labels[0]

func _process(_delta):
	$Label.text = "SCORE : " + str(score)

func failure() :
	ProjectSettings.set_setting("specific/state/paused",true)
	title.text = title_labels[1]
	start_button.text = button_labels[1]
	explanation.visible = false
	$VBoxContainer.visible = true
	$VBoxContainer/Button.visible = false
	#game_over = true

func play() :
	if not game_over:
		ProjectSettings.set_setting("specific/state/paused",false)
		$VBoxContainer.visible = false
	#else:
		#$"../..".reload()
