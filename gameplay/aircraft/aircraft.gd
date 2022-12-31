tool
class_name Aircraft
extends Area2D

signal weapon_reloaded(key)
signal weapon_fired(key,n)
signal damaged(d)
signal killed()

const water_level:=500

export var is_enemy:=true setget set_is_enemy
export var base_speed:=0.0 setget ,get_speed
export var base_turn_radius:float=100.0 setget ,get_turn_radius
export var base_hp:=100 setget ,get_max_hp
export var sync_rotation:=true
export var weapon_groups:Dictionary setget _set_weapon_groups

var target_velocity:Vector2
var _actual_velocity:Vector2

onready var sprite:Sprite=$Sprite
onready var hp:=get_max_hp()
var weapon_states:Dictionary


func _init():
	weapon_states={}


func _ready():
	if Engine.editor_hint:
		return
	
	for key in weapon_groups:
		var wg:Dictionary=weapon_groups[key]
		# validiation
		if !wg.has("node_paths"):
			wg["node_paths"]=[]
		else:
			assert(wg["node_paths"] is Array)
		
		if !wg.has("base_reload"):
			wg["base_reload"]=1.0
		else:
			assert(wg["base_reload"] is float or wg["base_reload"] is int)
		
		if !wg.has("base_accuracy"):
			wg["base_accuracy"]=0.0
		else:
			assert(wg["base_accuracy"] is float or wg["base_accuracy"] is int)
		
		if !wg.has("base_dispersion"):
			wg["base_dispersion"]=0.0
		else:
			assert(wg["base_dispersion"] is float)
		
		var ws:WeaponState=WeaponState.new()
		weapon_states[key]=ws
		for np in wg["node_paths"]:
			var w:Weapon=get_node(np)
			assert(w,str(np)+" is not a Weapon")
			ws.nodes.push_back(w)
		ws.timer.wait_time=get_weapon_reload(key)
		ws.timer.connect("timeout",self,"_on_ReloadTimer_timeout",[key])
		add_child(ws)


func _process(_delta:float):
	pass


func _physics_process(delta:float):
	if Engine.editor_hint:
		return
	
	if target_velocity!=_actual_velocity:
		var angle_diff:=_actual_velocity.angle_to(target_velocity)
		if PI<abs(angle_diff):
			angle_diff=TAU-angle_diff
		var omg:=target_velocity.length()/get_turn_radius()
		if angle_diff<omg*delta:
			_actual_velocity=target_velocity
		else:
			var r:=rotation+omg*delta
			_actual_velocity=Vector2(cos(r),sin(r))*target_velocity.length()

	position+=_actual_velocity*delta
	if 1024<position.y or position.x<-512 or 1536<position.x:
		queue_free()

	if sync_rotation:
		if _actual_velocity!=Vector2.ZERO:
			rotation=_actual_velocity.angle()
		if 0<_actual_velocity.x:
			sprite.flip_v=false
		elif _actual_velocity.x<0:
			sprite.flip_v=true


func set_is_enemy(f:bool):
	is_enemy=f
	if is_enemy:
		add_to_group("EnemyObjects")
	elif is_in_group("EnemyObjects"):
		remove_from_group("EnemyObjects")


func get_speed()->float:
	return base_speed


func get_max_hp()->int:
	return base_hp


func get_turn_radius()->float:
	return base_turn_radius


func get_weapon_reload(key:String="main")->float:
	return weapon_groups[key]["base_reload"]


func set_weapon_reload(key:String,t:float):
	weapon_groups[key]["base_reload"]=t
	weapon_states[key].timer.wait_time=t


func get_weapon_accuracy(key:String="main")->float:
	return weapon_groups[key]["base_accuracy"]


func get_weapon_dispersion(key:String="main")->float:
	return weapon_groups[key]["base_dispersion"]


func _set_weapon_groups(wg:Dictionary):
	weapon_groups=wg
	for key in weapon_groups:
		if weapon_groups[key]==null or weapon_groups[key].empty():
			weapon_groups[key]={
					"node_paths":[],
					"base_reload":1.0,
					"base_accuracy":0.0,
					"base_dispersion":0.0,
				}


# enemy by default
func get_projectile_instance(key:String="main")->Projectile:
	if weapon_states[key].projectile_prototype==null:
		var projectile_scene:PackedScene=weapon_states[key].nodes[0].projectile_scene
		var i:Projectile=projectile_scene.instance()
		i.set_collision_layer_bit(5,true)
		i.set_collision_mask_bit(2,true)
		weapon_states[key].projectile_prototype=i
	return weapon_states[key].projectile_prototype.duplicate()


func fire_weapon(key:String,pos:Vector2):
	var n:=0
	var ws:WeaponState=weapon_states[key]
	for w in ws.nodes:
		var v_diff:Vector2=pos-w.global_position
		var i:Projectile=get_projectile_instance(key)
		var v:float=w.get_muzzle_velocity()
		var a:=0.5*i.gravity*v_diff.x*v_diff.x/(v*v)
		var rot:float
		if a!=0.0:
			var b:=v_diff.x
			var c:=a-v_diff.y
			var d:=b*b-4*a*c
			if 0<=d:
				var tan_theta:float
				var sqrt_d:=sqrt(b*b-4*a*c)
				if abs(-b+sqrt_d)>abs(-b-sqrt_d):
					tan_theta=(-b-sqrt_d)/(2*a)
					rot=atan(tan_theta)+PI
				else:
					tan_theta=(-b+sqrt_d)/(2*a)
					rot=atan(tan_theta)
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
		w.put_projectile(get_projectile_instance(key),rot,get_weapon_dispersion(key),get_weapon_accuracy(key))
		n+=w.num_barrels
	ws.ready=false
	ws.timer.start(get_weapon_reload(key))
	
	emit_signal("weapon_fired",key,n)


func damage(p:Projectile):
	if hp<=0:
		return
	
	var v_norm:=p.velocity.normalized()
	var raw_dmg:=v_norm*p.get_damage()
	raw_dmg.x=max(0,raw_dmg.x)
	raw_dmg.y=max(0,raw_dmg.y)
	var dmg_mod:=max(raw_dmg.length(),0.05*p.get_damage())
	hp-=dmg_mod
	emit_signal("damaged",dmg_mod)
	_damage_popup(dmg_mod,p.position)
	if hp<=0:
		emit_signal("killed")
		var explosion:Particles2D=preload("res://gameplay/effect/explosion.tscn").instance()
		GlobalScript.node2d_root.add_child(explosion)
		explosion.global_position=global_position
		explosion.scale=0.05*Vector2(1,1)
		
		_add_falling_aircraft()
		
		GlobalScript.play_sound("res://gameplay/effect/tm2_bom002.wav")
		queue_free()


func _damage_popup(d:int,pos:Vector2):
	var popup:DamageIndicator=preload("res://gameplay/ship/damage_indicator.tscn").instance()
	popup.text=str(d)
	popup.font_color=Color.black
	popup.rect_position=pos+Vector2(0,-64)
	GlobalScript.node2d_root.add_child(popup)


func _add_falling_aircraft():
	var falling:FallingAircraft=preload("res://gameplay/aircraft/falling_aircraft.tscn").instance()
	GlobalScript.node2d_root.add_child(falling)
	falling.setup($Sprite,_actual_velocity,scale)


func _on_ReloadTimer_timeout(key:String):
	weapon_states[key].ready=true
	emit_signal("weapon_reloaded",key)
