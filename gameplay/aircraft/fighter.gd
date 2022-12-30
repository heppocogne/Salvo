tool
class_name Fighter
extends Aircraft

var target_y:=300.0
onready var timer:Timer=$Timer
var player_node:Player

func _ready():
	player_node=GlobalScript.node2d_root.get_node("Player")


func _physics_process(_delta:float):
	if Engine.editor_hint:
		return
	
	if weakref(player_node).get_ref():
		var p:Vector2=player_node.position
		if p.distance_to(position)<weapon_states["main"].nodes[0].get_range() and weapon_states["main"].ready:
			fire_weapon("main",p)


func _on_Timer_timeout():
	var rot_deg:float
	if position.y<target_y:
		rot_deg=rand_range(150,180)
	else:
		rot_deg=rand_range(180,210)
	
	target_velocity=polar2cartesian(get_speed(),deg2rad(rot_deg))
	
	timer.start(rand_range(0.5,1.0))
