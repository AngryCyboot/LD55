extends Node3D

var legs : Array[Leg]
var mobile : int = 0

func _ready():
	for leg in get_children():
		if leg is Leg : legs.append(leg)
	mobile = legs.size()

func _process(delta):
	var max_mobile : int = legs.size()/2
	if mobile < max_mobile and $"../.."._target_node.global_position.distance_to(global_position)>1:
		var dist : float = -1
		var furthest : Leg
		for leg in legs:
			var wish_dist : float = leg.compute_foot_target().distance_to(leg.global_position)
			if wish_dist>dist: 
				dist = wish_dist
				furthest=leg
		if dist > furthest.max_extention : 
			furthest.mobile(true)
