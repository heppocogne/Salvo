tool
class_name Player
extends Ship

signal player_fired(diff)
signal player_moved(diff)
signal main_weapon_relaod_time_left_changed(t)

const line_color:=Color.darkgray
const line_length:=64.0

var lock_weapon:=false
var mouse_pos:Vector2
var _class_Ship=load("res://gameplay/ship/ship.gd")

var _speed_upgrade:int
var _hp_upgrade:int
var _protection_upgrade:Vector2
var _shell_damage_upgrade:int
var _accuracy_upgrade:float
var _reload_upgrade:float

# speed: +1.5

# hp: +100
# h_protection: +25.4
# v_protection: +12.7

# barrels: +2 (4,6,8,10,12,14,16), reload: +0.3
# shell: +25.4 (305,330,356,381,406,431,457,483,508), reload: +0.3
# accuracy: +0.5
# reload: -0.5

func _ready():
	# load from savedata
	if !Engine.editor_hint:
		_speed_upgrade=SaveData.read("upgrade_speed")*1.5
		
		_hp_upgrade=SaveData.read("upgrade_HP")*100
		hp=get_max_hp()
		
		_protection_upgrade=Vector2(
				SaveData.read("upgrade_h_protection")*25.4,
				SaveData.read("upgrade_v_protection")*12.7
			)
		
		var barrels_upgrade:int=SaveData.read("upgrade_main_weapon_barrels")
		var num_barrels:=4+barrels_upgrade*2
		for w in main_weapons:
			w.num_barrels=num_barrels/4
		if num_barrels%4==2:
			main_weapons[1].num_barrels+=1
			main_weapons[2].num_barrels+=1
		_reload_upgrade+=barrels_upgrade*0.3
		
		var shell_upgrade:int=SaveData.read("upgrade_main_weapon_caliber")
		_shell_damage_upgrade=shell_upgrade*25.4
		_reload_upgrade+=shell_upgrade*0.3
		
		_accuracy_upgrade=SaveData.read("upgrade_main_weapon_accuracy")*0.5
		
		_reload_upgrade-=SaveData.read("upgrade_main_weapon_reload")*0.5


func _draw():
	var dir:=mouse_pos.normalized()
	draw_line(Vector2.ZERO,line_length*dir,line_color)
	pass


func _process(_delta:float):
	if Engine.editor_hint:
		return
	if !main_weapon_reload_timer.is_stopped():
		emit_signal("main_weapon_relaod_time_left_changed",main_weapon_reload_timer.time_left)


func _input(event:InputEvent):
	if event is InputEventMouseMotion:
		mouse_pos=get_local_mouse_position()
		update()
	elif event is InputEventMouseButton:
		var mb:=event as InputEventMouseButton
		if mb.pressed:
			if mb.button_index==BUTTON_LEFT and main_weapon_ready and !lock_weapon:
				var rot:=mouse_pos.angle()
				var i:Projectile=get_projectile_instance(main_weapons[0].projectile_scene)
				var a:=0.5*i.gravity
				var b:float=main_weapons[0].get_muzzle_velocity()*sin(rot)
				var c:=global_position.y-500
				var sqrt_d:=sqrt(b*b-4*a*c)
				var t:=(-b+sqrt_d)/(2*a)
				var pos:=Vector2(main_weapons[0].get_muzzle_velocity()*cos(rot)*t+global_position.x,500)
				
				i.queue_free()
				fire_main_weapon2(pos,rot)
				
				var dist_min:float=INF
				for n in GlobalScript.node2d_root.get_children():
					if n is _class_Ship and n!=self:
						if n.global_position.distance_to(pos)<dist_min:
							dist_min=n.global_position.distance_to(pos)
				if dist_min!=INF:
					emit_signal("player_fired",dist_min)


func _physics_process(delta:float):
	if Engine.editor_hint:
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


func get_max_hp()->int:
	return .get_max_hp()+_hp_upgrade


func get_speed()->float:
	return base_speed+_speed_upgrade


func get_main_weapon_reload()->float:
	return base_main_weapon_reload+_reload_upgrade


func get_main_weapon_accuracy()->float:
	return base_main_weapon_accuracy+_accuracy_upgrade


func get_protection()->Vector2:
	return protection+_protection_upgrade


func get_projectile_instance(projectile_scene:PackedScene)->Projectile:
	var i:Projectile=projectile_scene.instance()
	i.set_collision_layer_bit(4,true)
	i.set_collision_mask_bit(3,true)
	i.damage_upgrade=_shell_damage_upgrade
	return i


func fire_main_weapon2(pos:Vector2,approx_rot:float):
	for w in main_weapons:
		var v_diff:Vector2=pos-w.global_position
		var i:Projectile=get_projectile_instance(main_weapons[0].projectile_scene)
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
		w.put_projectile(rot,get_main_weapon_dispersion(),get_main_weapon_accuracy())
	main_weapon_ready=false
	main_weapon_reload_timer.start(get_main_weapon_reload())


func _damage_popup(d:int,pos:Vector2):
	var popup:DamageIndicator=preload("res://gameplay/ship/damage_indicator.tscn").instance()
	popup.text=str(d)
	popup.font_color=Color.red
	popup.rect_position=pos+Vector2(0,-64)
	GlobalScript.node2d_root.add_child(popup)
