extends BattleScreen

var kill_count:=0
onready var timer:Timer=$VBoxContainer/ViewportContainer/Viewport/Node2DRoot/Timer


func _ready():
	pass


func _on_Timer_timeout():
	set_label_text("敵艦隊を撃沈せよ")
	var s:=spawn_enemy_ship(preload("res://gameplay/ship/enemy/old_dd.tscn"),600)
	s.connect("killed",self,"_on_Enemy_killed")
	s=spawn_enemy_ship(preload("res://gameplay/ship/enemy/old_dd.tscn"),700)
	s.connect("killed",self,"_on_Enemy_killed")
	s=spawn_enemy_ship(preload("res://gameplay/ship/enemy/old_dd.tscn"),800)
	s.connect("killed",self,"_on_Enemy_killed")


func _on_Enemy_killed():
	kill_count+=1
	
	if kill_count==1:
		var t:Tween=$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/Label/Tween
		var l:Label=$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/Label
		t.interpolate_property(
			l,
			"self_modulate",
			Color.white,
			Color(1,1,1,0),
			1.0,	# duration
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT
		)
		t.start()
		var tm:=Timer.new()
		add_child(tm)
		tm.start(1.0)
		yield(tm,"timeout")
		tm.queue_free()
		set_label_text("")
		l.self_modulate=Color(1,1,1,1)
		
	if kill_count==3:
		timer.start(2.0)
	elif kill_count==6:
		set_label_text("作戦成功!")
		stage_complete()
		$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/Label.self_modulate=Color(1,1,1,1)
		$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/Button.visible=true
#		SaveData.store("stage_2_unlocked",true)


func _on_Timer_timeout2():
	var s:=spawn_enemy_ship(preload("res://gameplay/ship/enemy/old_dd.tscn"),650)
	s.connect("killed",self,"_on_Enemy_killed")
	s=spawn_enemy_ship(preload("res://gameplay/ship/enemy/old_bb.tscn"),800)
	s.connect("killed",self,"_on_Enemy_killed")
	s=spawn_enemy_ship(preload("res://gameplay/ship/enemy/old_dd.tscn"),950)
	s.connect("killed",self,"_on_Enemy_killed")
