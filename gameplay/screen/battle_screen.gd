class_name BattleScreen
extends Control

export var clear_count_key:String
export var pt_per_damage:=1.0
export var pt_aiming:=1.0
export var pt_maneuver:=1.0
export var first_reward:=0

var player_killed:=false
var _player_salvo_diff:Array
var _enemy_shell_diff:Array
var _player_move_timer_active:=false
var _player_moving_distance:float
var _damage_sum:=0.0
var _enemy_shoot:=0
var _enemy_hit:=0

onready var player:Player=$VBoxContainer/ViewportContainer/Viewport/Node2DRoot/Player
onready var player_move_timer:Timer=$VBoxContainer/ViewportContainer/Viewport/Node2DRoot/Player/Timer
onready var tween:Tween=$VBoxContainer/ViewportContainer/Viewport/Node2DRoot/Tween
onready var timer:Timer=$VBoxContainer/ViewportContainer/Viewport/Node2DRoot/Timer
onready var aiming:PlayEvaluation=$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/MarginContainer/Evaluations/AimingAccuracy
onready var maneuver:PlayEvaluation=$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/MarginContainer/Evaluations/Maneuver


func _ready():
	_player_salvo_diff=[]
	_enemy_shell_diff=[]
	GlobalScript.battele_screen=self
	GlobalScript.node2d_root=$VBoxContainer/ViewportContainer/Viewport/Node2DRoot
	GlobalScript.water_area=$VBoxContainer/ViewportContainer/Viewport/Node2DRoot/WaterArea
	if !SystemSaveData.read("use_default_cursor"):
		Input.set_custom_mouse_cursor(preload("res://gameplay/screen/cursor.svg"),0,Vector2(30,30))
	
	if !SystemSaveData.read("show_fps"):
		$VBoxContainer/ViewportContainer/Viewport/FpsLabel.queue_free()


func _on_BattleScreen_tree_exiting():
	GlobalScript.battele_screen=null
	GlobalScript.node2d_root=null
	GlobalScript.water_area=null


func _process(_delta:float):
	pass


func spawn_enemy_ship(scene:PackedScene, x:float)->Ship:
	var ship:Ship=scene.instance()
	GlobalScript.node2d_root.call_deferred("add_child",ship)
	ship.position.y=GlobalScript.water_level
	ship.connect("damaged",self,"_on_Enemy_damaged")
	ship.connect("weapon_fired",self,"_on_Enemy_fired")
	tween.interpolate_property(
		ship,
		"position:x",
		1500,
		x,
		1.0,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	tween.start()
	return ship


func set_label_text(text:String):
	var l:Label=$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/Label
	l.text=text
	if l.text=="":
		$VBoxContainer/ViewportContainer/CenterContainer/PanelContainer.hide()
		l.hide()
	else:
		l.visible=true
		l.percent_visible=0.0
		var t:Tween=l.get_node("Tween")
		t.interpolate_property(
			l,
			"percent_visible",
			0.0,
			1.0,
			0.5,	# duration
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT
		)
		t.start()


func _on_Timer_timeout():
	pass


func _on_Button_pressed():
	SaveData.save_to_file()
	Input.set_custom_mouse_cursor(null)
	get_tree().change_scene_to(load("res://gameplay/screen/main/main.tscn"))


func _attach_marker(target:Node2D,offset:Vector2=Vector2(0,-10)):
	var m:Marker=preload("res://gameplay/misc/marker.tscn").instance()
	GlobalScript.node2d_root.add_child(m)
	m.popup_offset=offset
	m.target_node=target
	target.connect("killed",m,"queue_free")


func _fadeout_mission_text(mission_message:String,duration:float):
	set_label_text(mission_message)
	
	var tm:=Timer.new()
	add_child(tm)
	tm.start(duration)
	yield(tm,"timeout")
	
	var l:Label=$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/Label
	var t:Tween=l.get_node("Tween")
	t.interpolate_property(
		l,
		"self_modulate:a",
		1.0,
		0.0,
		1.0,	# duration
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	t.start()
	var p:PanelContainer=$VBoxContainer/ViewportContainer/CenterContainer/PanelContainer
	t.interpolate_property(
		p,
		"self_modulate:a",
		1.0,
		0.0,
		1.0,	# duration
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	t.start()
	tm.start(1.1)
	yield(tm,"timeout")
	tm.queue_free()
	set_label_text("")
	l.self_modulate.a=1.0
	p.self_modulate.a=1.0


func stage_complete():
	if player_killed:
		return
	
	$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/Button.visible=true
	set_label_text(tr(":MISSION_COMPLETED:")+"!")
	$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/Label.add_color_override("font_color",Color.yellow)
	player.block_user_input=true
	player.disconnect("killed",self,"_on_Player_killed")
	var c:int
	
	SaveData.store("subweapon",player.subweapon)
	
	if SaveData.has_key(clear_count_key):
		c=SaveData.read(clear_count_key)+1
	else:
		c=1
	SaveData.store(clear_count_key,c)
	
	var reward:=0
	if c==1:
		reward+=first_reward
	
	_calculate_reward(true,reward)


func _calculate_reward(success:bool,bonus:int=0):
	$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/MarginContainer/Evaluations.visible=true
	var tm:Timer=Timer.new()
	add_child(tm)
	tm.start(0.5)
	yield(tm,"timeout")
	aiming.visible=true
	
	# evaluation systemu is work in progress
	var aiming_sum:=0.0
	for a in _player_salvo_diff:
		aiming_sum+=a
	var eval_aiming:float
	if aiming_sum==0:
		eval_aiming=0.0
	else:
		eval_aiming=10+log(_player_salvo_diff.size()/aiming_sum)/log(2)
	
	if 5.0<eval_aiming:
		aiming.set_evaluation("S")
	elif 4.0<eval_aiming:
		aiming.set_evaluation("A")
	elif 3.0<eval_aiming:
		aiming.set_evaluation("B")
	elif 2.0<eval_aiming:
		aiming.set_evaluation("C")
	else:
		aiming.set_evaluation("D")
	
	tm.start(0.5)
	yield(tm,"timeout")
	maneuver.visible=true
	
	var diff_sum:=0.0
	for d in _enemy_shell_diff:
		diff_sum+=d
	
	var eval_maneuver:=0.0
	if _enemy_shell_diff.size()==0:
		eval_maneuver=0.0
	else:
		eval_maneuver=0.05*diff_sum/_enemy_shell_diff.size()
	
	if _enemy_shoot==0:
		eval_maneuver+=1.0
	else:
		eval_maneuver+=1.0-float(_enemy_hit)/_enemy_shoot
	
	if 5.0<eval_maneuver:
		maneuver.set_evaluation("S")
	elif 4.0<eval_maneuver:
		maneuver.set_evaluation("A")
	elif 3.0<eval_maneuver:
		maneuver.set_evaluation("B")
	elif 2.0<eval_maneuver:
		maneuver.set_evaluation("C")
	else:
		maneuver.set_evaluation("D")
	
	tm.start(0.5)
	yield(tm,"timeout")
	tm.queue_free()
	var reward_node:=$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/MarginContainer/Evaluations/Reward
	reward_node.visible=true
	
	var reward:=int(pt_per_damage*_damage_sum)
	if aiming_sum!=0.0:
		reward+=int(pt_aiming*100*_player_salvo_diff.size()/aiming_sum)
	if _enemy_shell_diff.size()!=0:
		reward+=pt_maneuver*0.01*diff_sum/_enemy_shell_diff.size()
	reward+=bonus
	if !success:
		reward/=2
	reward_node.get_node("Point").text=str(reward)+" pt"
	print_debug("eval_aiming=",eval_aiming,
				"\neval_maneuver=",eval_maneuver,
				"\ndamage=",_damage_sum,
				"\nreward=",reward
				)
	
	var pt:int=SaveData.read("upgrade_point")
	SaveData.store("upgrade_point",pt+reward)
	SaveData.save_to_file()


func _on_Player_killed():
	player_killed=true
	stage_fail()


func stage_fail():
	$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/Button.visible=true
	set_label_text(tr(":MISSION_FAILED:")+"!")
	$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/Label.add_color_override("font_color",Color.orangered)
	
	SaveData.store("subweapon",player.subweapon)
	
	if !SaveData.has_key(clear_count_key):
		SaveData.store(clear_count_key,0)
	
	_calculate_reward(false)


func _on_Player_player_fired(diff:float):
	_player_salvo_diff.push_back(diff)


func _on_Enemy_damaged(d:int):
	_damage_sum+=d


func _on_Enemy_fired(_key:String,n:int):
	_enemy_shoot+=n


func on_EnemyShell_off(pos:Vector2):
	if _player_move_timer_active and weakref(player).get_ref():
		_enemy_shell_diff.push_back((pos-player.position).length())


func _on_Player_damaged(_d:int):
	_enemy_hit+=1


func _on_Player_player_moved(_diff:Vector2):
	_player_move_timer_active=true
	player_move_timer.start()


func _on_PlayerMoveTimer_timeout():
	_player_move_timer_active=false
