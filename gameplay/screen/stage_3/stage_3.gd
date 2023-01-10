extends BattleScreen

const _old_dd_scene:PackedScene=preload("res://gameplay/ship/enemy/old_dd.tscn")
const _old_cl_scene:PackedScene=preload("res://gameplay/ship/enemy/old_cl.tscn")
const _cvl_scene:PackedScene=preload("res://gameplay/ship/enemy/light_carrier.tscn")
const _cv_scene:PackedScene=preload("res://gameplay/ship/enemy/carrier.tscn")

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
	
	if kill_count==3:
		timer.start(2.0)
		yield(timer,"timeout")
		spawn_enemy_ship(_old_dd_scene,550)
		spawn_enemy_ship(_old_dd_scene,700)
		var s:=spawn_enemy_ship(_cv_scene,850)
		s.connect("killed",self,"_on_CV_killed")
		var m:Marker=preload("res://gameplay/misc/marker.tscn").instance()
		m.target_node=s
		m.popup_offset=Vector2(0,-20)
		s.connect("killed",m,"queue_free")
		GlobalScript.node2d_root.call_deferred("add_child",m)


func _on_CV_killed():
	stage_complete()
#	SaveData.store("tutorial_4_unlocked",true)
