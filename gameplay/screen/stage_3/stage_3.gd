extends BattleScreen

const _old_dd_scene:PackedScene=preload("res://gameplay/ship/enemy/old_dd.tscn")
const _old_cl_scene:PackedScene=preload("res://gameplay/ship/enemy/old_cl.tscn")
const _cvl_scene:PackedScene=preload("res://gameplay/ship/enemy/light_carrier.tscn")
#const _cv_scene:PackedScene=preload("res://gameplay/ship/enemy/carrier.tscn")

var kill_count:=0


func _ready():
	pass


func _on_Timer_timeout():
	_fadeout_mission_text(tr(":KILL_ENEMY_CV:"),4.0)
	var s:=spawn_enemy_ship(_old_dd_scene,550)
	s.connect("killed",self,"_on_Enemy_killed")
	s=spawn_enemy_ship(_cvl_scene,700)
	s.connect("killed",self,"_on_Enemy_killed")
	s=spawn_enemy_ship(_cvl_scene,850)
	s.connect("killed",self,"_on_Enemy_killed")


func _on_Enemy_killed():
	kill_count+=1
