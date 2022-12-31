extends BattleScreen

const bomber_scene:PackedScene=preload("res://gameplay/aircraft/bomber.tscn")
const fighter_scene:PackedScene=preload("res://gameplay/aircraft/fighter.tscn")
const marker_scene:PackedScene=preload("res://gameplay/misc/marker.tscn")

enum{
	NONE,
	SUB_WEAPON_TUTORIAL,
	SUB_WEAPON_SWITCH_TUTORIAL,
	KILL_BOMBER_TUTORIAL,
	KILL_FIGHTER_TUTORIAL,
	FORTRESS_TUTORIAL,
	TUTORIAL_END,
}
var step:=NONE
var right_clicked:=false
var bomber_killed:=false
var fighter_killed:=false
var artillery_killed:=false
var fortress:NavalFortress
onready var timer2:Timer=$VBoxContainer/ViewportContainer/Viewport/Node2DRoot/Timer2


func _ready():
	pass


func _on_Timer_timeout():
	set_label_text("右クリックで副兵装を発射")
	var ts:PackedScene=preload("res://gameplay/ship/enemy/tutorial_target.tscn")
	spawn_enemy_ship(ts,500)
	$VBoxContainer/ViewportContainer/Viewport/Node2DRoot/Player.subweapon="secondary"
	step=SUB_WEAPON_TUTORIAL


func _physics_process(_delta:float):
	if step==SUB_WEAPON_TUTORIAL:
		if right_clicked:
			var flag:=false
			for n in GlobalScript.node2d_root.get_children():
				if n is Projectile:
					flag=true
					return
		
			if !flag:
				set_label_text("スペースキーで副兵装を切り替え")
				step=SUB_WEAPON_SWITCH_TUTORIAL
				return
			
		if Input.is_mouse_button_pressed(BUTTON_RIGHT):
			for n in GlobalScript.node2d_root.get_children():
				if n is Projectile:
					right_clicked=true
					return
	
	if step==SUB_WEAPON_SWITCH_TUTORIAL:
		if Input.is_key_pressed(KEY_SPACE):
			_fadeout_mission_text("爆撃機を撃墜せよ",3.0)
			timer2.start(7.5)
			step=KILL_BOMBER_TUTORIAL
			_on_Timer2_timeout()
			return
	
	if step==KILL_BOMBER_TUTORIAL or step==KILL_FIGHTER_TUTORIAL:
		for n in GlobalScript.node2d_root.get_children():
			if n is Aircraft:
				if n.position.x<-64:
					n.queue_free()


func _on_Timer2_timeout():
	if step==KILL_BOMBER_TUTORIAL:
		var b:Aircraft=bomber_scene.instance()
		var m:Marker=marker_scene.instance()
		m.target_node=b
		b.connect("killed",self,"_on_Bomber_killed")
		b.connect("tree_exiting",m,"queue_free")
		b.target_velocity=-Vector2(b.get_speed(),0)
		GlobalScript.node2d_root.call_deferred("add_child",b)
		GlobalScript.node2d_root.call_deferred("add_child",m)
		b.rotation=PI
		b.position=Vector2(1050,120)
	elif step==KILL_FIGHTER_TUTORIAL:
		var f:Aircraft=fighter_scene.instance()
		var m:Marker=marker_scene.instance()
		m.target_node=f
		f.connect("killed",self,"_on_Fighter_killed")
		f.connect("tree_exiting",m,"queue_free")
		f.target_velocity=-Vector2(f.get_speed(),0)
		GlobalScript.node2d_root.call_deferred("add_child",f)
		GlobalScript.node2d_root.call_deferred("add_child",m)
		f.rotation=PI
		f.position=Vector2(1050,380)


func _on_Bomber_killed():
	if !bomber_killed:
		bomber_killed=true
		for n in GlobalScript.node2d_root.get_children():
			if n is Marker:
				n.set_disabled(true)
		_fadeout_mission_text("戦闘機を撃墜せよ",3.0)
		step=KILL_FIGHTER_TUTORIAL
		timer2.start(5.0)
		_on_Timer2_timeout()


func _on_Fighter_killed():
	if !fighter_killed:
		fighter_killed=true
		for n in GlobalScript.node2d_root.get_children():
			if n is Marker:
				n.set_disabled(true)
		step=FORTRESS_TUTORIAL
		timer2.stop()
		fortress=preload("res://gameplay/screen/tutorial_2/tutorial_fortress.tscn").instance()
		fortress.position=Vector2(1400,500)
		GlobalScript.node2d_root.call_deferred("add_child",fortress)
		tween.interpolate_property(
			fortress,
			"position:x",
			1250,
			1024,
			5.0,
			Tween.TRANS_QUAD,
			Tween.EASE_OUT
		)
		tween.start()
		var tm:=Timer.new()
		add_child(tm)
		tm.start(6.0)
		yield(tm,"timeout")
		_fadeout_mission_text("敵の海上要塞を確認\n要塞砲に注意しつつ航空基地を破壊せよ",5.0)
		var airport:Airport=fortress.get_node("Airport")
		airport.set_active(true)
		var m:Marker=marker_scene.instance()
		m.popup_offset=Vector2(0,-20)
		m.target_node=airport
		airport.add_child(m)
		tm.start(6)
		yield(tm,"timeout")
		airport.connect("killed",m,"queue_free")
		airport.connect("killed",self,"_on_Airport_killed")
		fortress.get_node("Artillery").active=true
		tm.queue_free()


func _on_Airport_killed():
	if !player_killed:
		set_label_text("チュートリアル 2 完了")
		fortress.get_node("Artillery").active=false
		stage_complete()
		step=TUTORIAL_END
		SaveData.store("stage_3_unlocked",true)
