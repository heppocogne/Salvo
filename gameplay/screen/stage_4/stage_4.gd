extends BattleScreen

#const _old_dd_scene:PackedScene=preload("res://gameplay/ship/enemy/old_dd.tscn")
#const _cvl_scene:PackedScene=preload("res://gameplay/ship/enemy/light_carrier.tscn")
#const _new_cl_scene:PackedScene=preload("res://gameplay/ship/enemy/new_cl.tscn")

var fortress:Node2D
var artillery_killed:=0


func _ready():
	pass


func _on_Timer_timeout():
	_fadeout_mission_text(tr(":DESTROY_ARTILLERIES:"),4.0)
#	spawn_enemy_ship(_new_cl_scene,600)
	
	fortress=preload("res://gameplay/screen/stage_4/stage_4_fortress.tscn").instance()
	GlobalScript.node2d_root.add_child(fortress)
	fortress.position=Vector2(1250,GlobalScript.water_level)
	var a=fortress.get_node("Artillery")
	_attach_marker(a,Vector2(4,-20))
	a.connect("killed",self,"_on_Artillery_killed")
	a=fortress.get_node("Artillery2")
	a.connect("killed",self,"_on_Artillery_killed")
	_attach_marker(a,Vector2(4,-20))
	fortress.get_node("Airbase").set_active(true)
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


func _on_Artillery_killed():
	artillery_killed+=1
	
	if artillery_killed==2:
		tween.interpolate_property(
			fortress,
			"modulate:a",
			1,
			0,
			5.0,
			Tween.TRANS_QUAD,
			Tween.EASE_OUT
		)
		tween.start()
		
		var tm:=Timer.new()
		add_child(tm)
		tm.start(6.0)
		yield(tm,"timeout")
		fortress.queue_free()
		
		fortress=preload("res://gameplay/screen/stage_4/stage_4_fortress2.tscn").instance()
		GlobalScript.node2d_root.add_child(fortress)
		fortress.position=Vector2(1400,GlobalScript.water_level)
		tween.interpolate_property(
			fortress,
			"position:x",
			1400,
			1024,
			5.0,
			Tween.TRANS_QUAD,
			Tween.EASE_OUT
		)
		tween.start()
		var a=fortress.get_node("Artillery")
		_attach_marker(a,Vector2(4,-20))
		a.connect("killed",self,"_on_Artillery_killed")
		a=fortress.get_node("Artillery2")
		a.connect("killed",self,"_on_Artillery_killed")
		_attach_marker(a,Vector2(4,-20))
		a=fortress.get_node("Artillery3")
		a.connect("killed",self,"_on_Artillery_killed")
		_attach_marker(a,Vector2(4,-20))
		a=fortress.get_node("Artillery4")
		a.connect("killed",self,"_on_Artillery_killed")
		_attach_marker(a,Vector2(4,-20))
	
	elif artillery_killed==6:
		stage_complete()
