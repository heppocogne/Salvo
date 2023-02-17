@tool
extends Ship

var player_node:Area2D
var player_detected:=false


func _ready():
	player_node=GlobalScript.node2d_root.get_node("Player")


func _physics_process(_delta:float):
	if !weakref(player_node).get_ref():
		return
	for key in weapon_groups:
		var ws:WeaponState=weapon_states[key]
		if ws.nodes.size()==0:
			return
		elif ws.ready and position.distance_to(player_node.position)<=ws.nodes[0].get_range():
			fire_weapon(key,player_node.position)
