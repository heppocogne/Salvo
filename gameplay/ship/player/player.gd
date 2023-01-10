tool
class_name Player
extends Ship

signal player_fired(diff)
signal player_moved(diff)
signal player_repaired(h)
signal weapon_relaod_time_left_changed(key,t)
signal repair_cooldown_started(c)
signal repair_cooldown_left_changed(t)
signal subweapon_changed(sw)

const line_color:=Color.darkgray
const line_length:=64.0

var subweapon:="" setget set_subweapon
var block_user_input:=false
var mouse_pos:Vector2
var _class_Ship=load("res://gameplay/ship/ship.gd")
var _class_NavalBaseObject=load("res://gameplay/base/naval_base_object.gd")
var _class_Aircraft=load("res://gameplay/aircraft/aircraft.gd")

var _speed_upgrade:int
var _hp_upgrade:int
var _protection_upgrade:Vector2
var _regeneration_per_sec:int
var _main_weapon_shell_damage_upgrade:int
var _main_weapon_accuracy_upgrade:float
var _main_weapon_dispersion_upgrade:float
var _main_weapon_reload_upgrade:float

onready var damage_timer:Timer=$DamageTimer
onready var repair_timer:Timer=$RpairTimer

# speed: +1.5

# hp: +50
# h_protection: +25.4
# v_protection: +12.7
# repair: +1/s

# barrels: +2 (4,6,8,10,12,14,16), reload: +0.3 dispersion+0.03
# shell: +25.4 (305,330,356,381,406,431,457,483,508), reload: +0.3
# accuracy: +0.4
# reload: -0.5

func _ready():
	# load from savedata
	if Engine.editor_hint:
		return
	
	subweapon=SaveData.read("subweapon")
	_speed_upgrade=SaveData.read("upgrade_speed")*1.5
	
	_hp_upgrade=SaveData.read("upgrade_HP")*50
	hp=get_max_hp()
	
	_protection_upgrade=Vector2(
			SaveData.read("upgrade_belt_armor")*25.4,
			SaveData.read("upgrade_deck_armor")*12.7
		)
	
	_regeneration_per_sec=SaveData.read("upgrade_emergency_repair")*2
	_main_weapon_reload_upgrade-=SaveData.read("upgrade_main_weapon_reload")*0.4
	if weapon_groups.has("main"):
		# restart reload timer to apply upgrade effect
		weapon_states["main"].timer.start(get_weapon_reload("main"))
	
	_main_weapon_accuracy_upgrade=SaveData.read("upgrade_main_weapon_accuracy")*0.3
	
	var barrels_upgrade:int=SaveData.read("upgrade_main_weapon_barrels")
	var num_barrels:=4+barrels_upgrade*2
	if weapon_groups.has("main"):
		for w in weapon_states["main"].nodes:
			w.num_barrels=num_barrels/4
	if num_barrels%4==2:
		weapon_states["main"].nodes[0].num_barrels+=1
		weapon_states["main"].nodes[3].num_barrels+=1
	# _main_weapon_reload_upgrade+=barrels_upgrade*0.3
	# _main_weapon_dispersion_upgrade+=barrels_upgrade*0.03
	
	var shell_upgrade:int=SaveData.read("upgrade_main_weapon_caliber")
	_main_weapon_shell_damage_upgrade=round((shell_upgrade+12)*25.4)
	# _main_weapon_reload_upgrade+=shell_upgrade*0.3


func _process(_delta:float):
	if Engine.editor_hint:
		return
	
	var mw:Dictionary=weapon_groups["main"]
	var tm:Timer=weapon_states["main"].timer
	if !tm.is_stopped():
		emit_signal("weapon_relaod_time_left_changed","main",tm.time_left)
	
	if subweapon!="":
		var sw:Dictionary=weapon_groups[subweapon]
		tm=weapon_states[subweapon].timer
		if !tm.is_stopped():
			emit_signal("weapon_relaod_time_left_changed",subweapon,tm.time_left)
	
	if !damage_timer.is_stopped():
		emit_signal("repair_cooldown_left_changed",damage_timer.time_left)


func _physics_process(delta:float):
	if Engine.editor_hint:
		return
	
	if block_user_input:
		return
	
	var l:=Input.is_action_pressed("game_left")
	var r:=Input.is_action_pressed("game_right")
	
	var v:float
	if r and !l:
		v=get_speed()
	elif l and !r:
		v=-get_speed()
	else:
		v=0.0
	
	var prev:=position
	position.x=clamp(position.x+v*delta,0,OS.window_size.x)
	if v!=0.0:
		emit_signal("player_moved",position-prev)


func _input(event:InputEvent):
	if event is InputEventMouseMotion:
		mouse_pos=get_local_mouse_position()
		update()
	elif event is InputEventMouseButton:
		var mb:=event as InputEventMouseButton
		if mb.pressed:
			var weapon_key:=""
			if !block_user_input:
				if mb.button_index==BUTTON_LEFT:
					weapon_key="main"
				elif mb.button_index==BUTTON_RIGHT:
					if subweapon!="":
						weapon_key=subweapon
					else:
						return
				if weapon_states[weapon_key].ready:
					var rot:=mouse_pos.angle()
					var wp:Weapon=weapon_states[weapon_key].nodes[0]
					var i:Projectile=get_projectile_instance(weapon_key)
					var a:=0.5*i.gravity
					var b:float=wp.get_muzzle_velocity()*sin(rot)
					var c:=global_position.y-500
					var sqrt_d:=sqrt(b*b-4*a*c)
					var t:=(-b+sqrt_d)/(2*a)
					var pos:=Vector2(wp.get_muzzle_velocity()*cos(rot)*t+global_position.x,500)
					
					if weapon_key=="main" or weapon_key=="secondary":
						i.queue_free()
						fire_weapon2(weapon_key,pos,rot)
						
						var dist_min:float=INF
						for n in get_tree().get_nodes_in_group("EnemyObjects"):
							if n is _class_Ship or n is _class_NavalBaseObject:
								if n.global_position.distance_to(pos)<dist_min:
									dist_min=n.global_position.distance_to(pos)
						if dist_min!=INF:
							emit_signal("player_fired",dist_min)
					elif weapon_key=="aa":
						fire_aa(to_global(mouse_pos))
						
						var dist_min:float=INF
						for n in get_tree().get_nodes_in_group("EnemyObjects"):
							if n is _class_Aircraft:
								# wip: dist_min for aircrafts
								pass
						if dist_min!=INF:
							emit_signal("player_fired",dist_min)
	elif event is InputEventKey:
		var key:=event as InputEventKey
		if key.pressed:
			if key.scancode==KEY_SPACE:
				if subweapon=="secondary":
					subweapon="aa"
					emit_signal("subweapon_changed","aa")
				elif subweapon=="aa":
					subweapon="secondary"
					emit_signal("subweapon_changed","secondary")


func get_max_hp()->int:
	return .get_max_hp()+_hp_upgrade


func get_speed()->float:
	return base_speed+_speed_upgrade


func get_weapon_reload(key:String="main")->float:
	if key=="main":
		return .get_weapon_reload(key)+_main_weapon_reload_upgrade
	else:
		return .get_weapon_reload(key)


func get_weapon_accuracy(key:String="main")->float:
	if key=="main":
		return .get_weapon_accuracy(key)+_main_weapon_accuracy_upgrade
	else:
		return .get_weapon_accuracy(key)


func get_weapon_dispersion(key:String="main")->float:
	if key=="main":
		return .get_weapon_dispersion(key)+_main_weapon_dispersion_upgrade
	else:
		return .get_weapon_dispersion(key)


func get_protection()->Vector2:
	return protection+_protection_upgrade


func set_subweapon(sw:String):
	subweapon=sw
	emit_signal("subweapon_changed",sw)


func get_projectile_instance(key:String="main")->Projectile:
	if weapon_states[key].projectile_prototype==null:
		var projectile_scene:PackedScene=weapon_states[key].nodes[0].projectile_scene
		var i:Projectile=projectile_scene.instance()
		i.set_collision_layer_bit(4,true)
		if key=="main" or key=="secondary":
			i.set_collision_mask_bit(3,true)
			i.set_collision_mask_bit(9,true)
		elif key=="aa":
			i.set_collision_mask_bit(7,true)
		
		if key=="main":
			i.base_damage=_main_weapon_shell_damage_upgrade
		weapon_states[key].projectile_prototype=i
	return weapon_states[key].projectile_prototype.duplicate()


func fire_weapon2(key:String,pos:Vector2,approx_rot:float):
	var ws:WeaponState=weapon_states[key]
	for w in ws.nodes:
		var v_diff:Vector2=pos-w.global_position
		var i:Projectile=get_projectile_instance(key)
		var rot:float
		var v:float=w.get_muzzle_velocity()
		var a:=0.5*i.gravity*v_diff.x*v_diff.x/(v*v)
		if a!=0.0:
			var b:=v_diff.x
			var c:=a-v_diff.y
			var d:=b*b-4*a*c
			if 0<=d:
				var sqrt_d:=sqrt(d)
				var rot_candidates:=[
						atan((-b-sqrt_d)/(2*a)),
						atan((-b+sqrt_d)/(2*a)),
					]
				rot_candidates.push_back(rot_candidates[0]-PI)
				rot_candidates.push_back(rot_candidates[1]-PI)
				var diff_min_idx:=-1
				var diff_min:=INF
				for idx in range(4):
					var diff:=abs(rot_candidates[idx]-approx_rot)
					if diff<diff_min:
						diff_min=diff
						diff_min_idx=idx
				rot=rot_candidates[diff_min_idx]
			else:
				if 0<v_diff.x:
					rot=-PI/4
				else:
					rot=-3*PI/4
		else:
			if 0<v_diff.y:
				rot=-PI/2
			else:
				rot=PI/2
		w.put_projectile(i,rot,get_weapon_dispersion(key),get_weapon_accuracy(key))
	ws.ready=false
	ws.timer.start(get_weapon_reload(key))


func fire_aa(pos:Vector2):
	var ws:WeaponState=weapon_states["aa"]
	var mv:float=weapon_states["aa"].nodes[0].get_muzzle_velocity()
	for w in ws.nodes:
		var i:=get_projectile_instance("aa")
		var delay:float=w.global_position.distance_to(pos)/mv
		var disp:=get_weapon_dispersion("aa")
		var acc:=get_weapon_accuracy("aa")
		i.delay=delay*(1+Weapon.get_random_dispersion(disp,acc))
		w.put_projectile(i,pos.angle_to_point(w.global_position),disp,acc)
	ws.ready=false
	ws.timer.start(get_weapon_reload("aa"))


func _on_Player_damaged(d:int):
	repair_timer.stop()
	var cooldown:=max(damage_timer.time_left,sqrt(d))
	damage_timer.start(cooldown)
	emit_signal("repair_cooldown_started",cooldown)


func _on_DamageTimer_timeout():
	if _regeneration_per_sec!=0:
		repair_timer.start()


func _on_RpairTimer_timeout():
	if hp!=get_max_hp():
		hp=min(get_max_hp(),hp+_regeneration_per_sec)
		var popup:=preload("res://gameplay/ship/repair_indicator.tscn").instance()
		popup.text="+"+str(_regeneration_per_sec)
		popup.rect_position=position+Vector2(0,-64)
		GlobalScript.node2d_root.add_child(popup)
		emit_signal("player_repaired",hp)
	else:
		repair_timer.stop()
