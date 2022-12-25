extends BattleScreen


const _old_dd_scene:PackedScene=preload("res://gameplay/ship/enemy/old_dd.tscn")
const _old_cl_scene:PackedScene=preload("res://gameplay/ship/enemy/old_cl.tscn")

var kill_count:=0


func _ready():
	pass


func _on_Timer_timeout():
	_fadeout_mission_text("敵艦隊を撃沈せよ",4.0)
	var s:=spawn_enemy_ship(_old_dd_scene,600)
	s.connect("killed",self,"_on_Enemy_killed")
	s=spawn_enemy_ship(_old_cl_scene,700)
	s.connect("killed",self,"_on_Enemy_killed")
	s=spawn_enemy_ship(_old_cl_scene,800)
	s.connect("killed",self,"_on_Enemy_killed")


func _on_Enemy_killed():
	kill_count+=1
	
	if kill_count==3:
		pass
