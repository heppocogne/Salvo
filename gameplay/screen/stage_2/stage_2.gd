extends BattleScreen


const _old_dd_scene:PackedScene=preload("res://gameplay/ship/enemy/old_dd.tscn")
const _old_cl_scene:PackedScene=preload("res://gameplay/ship/enemy/old_cl.tscn")
const _old_bb2_scene:PackedScene=preload("res://gameplay/ship/enemy/old_bb2.tscn")

var kill_count:=0


func _ready():
	pass


func _on_Timer_timeout():
	_fadeout_mission_text(tr(":KILL_THEM_ALL:"),4.0)
	var s:=spawn_enemy_ship(_old_dd_scene,600)
	s.connect("killed",Callable(self,"_on_Enemy_killed"))
	s=spawn_enemy_ship(_old_cl_scene,700)
	s.connect("killed",Callable(self,"_on_Enemy_killed"))
	s=spawn_enemy_ship(_old_dd_scene,800)
	s.connect("killed",Callable(self,"_on_Enemy_killed"))


func _on_Enemy_killed():
	kill_count+=1
	
	if kill_count==3:
		timer.start(2.0)
		await timer.timeout
		var s:=spawn_enemy_ship(_old_cl_scene,600)
		s.connect("killed",Callable(self,"_on_Enemy_killed"))
		s=spawn_enemy_ship(_old_cl_scene,800)
		s.connect("killed",Callable(self,"_on_Enemy_killed"))
	elif kill_count==5:
		timer.start(2.0)
		await timer.timeout
		var s:=spawn_enemy_ship(_old_dd_scene,650)
		s.connect("killed",Callable(self,"_on_Enemy_killed"))
		s=spawn_enemy_ship(_old_cl_scene,750)
		s.connect("killed",Callable(self,"_on_Enemy_killed"))
		s=spawn_enemy_ship(_old_bb2_scene,900)
		s.connect("killed",Callable(self,"_on_Enemy_killed"))
	elif kill_count==8:
		stage_complete()
		SaveData.store("tutorial_2_unlocked",true)
