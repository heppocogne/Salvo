extends Ship

var player_node:Area2D
var player_detected:=false


func _ready():
	player_node=GlobalScript.node2d_root.get_node("Player")


func _physics_process(_delta:float):
	if !weakref(player_node).get_ref():
		return
	elif main_weapon_ready and position.distance_to(player_node.position)<=main_weapons[0].get_range():
		fire_main_weapon(player_node.position)
