@tool
class_name Ship
extends Area2D

signal weapon_reloaded(key)
signal weapon_fired(key,n)
signal damaged(d)
signal killed()

@export var is_enemy:=true : set = set_is_enemy
@export var base_speed:=0.0
@export var base_hp:=100
@export var protection:Vector2
@export var weapon_groups:Dictionary : set = _set_weapon_groups
# key:groupname:String
#{
#	"node_paths":Array,
#	"base_reload":float,
#	"base_accuracy":float,
#	"base_dispersion":float,
#}

@onready var hp:=get_max_hp()
var weapon_states:Dictionary


func _init():
	weapon_groups={}
	weapon_states={}


func _ready():
	if Engine.is_editor_hint:
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
			assert(w) #,str(np)+" is not a Weapon")
			ws.nodes.push_back(w)
		ws.timer.wait_time=get_weapon_reload(key)
		ws.timer.connect("timeout",Callable(self,"_on_ReloadTimer_timeout").bind(key))
		add_child(ws)


func _physics_process(_delta:float):
	pass


func set_is_enemy(f:bool):
	is_enemy=f
	if is_enemy:
		add_to_group("EnemyObjects")
	elif is_in_group("EnemyObjects"):
		remove_from_group("EnemyObjects")


func get_max_hp()->int:
	return base_hp


func get_velocity()->float:
	return base_speed


func get_weapon_reload(key:String="main")->float:
	return weapon_groups[key]["base_reload"]


func set_weapon_reload(key:String,t:float):
	weapon_groups[key]["base_reload"]=t
	weapon_states[key].timer.wait_time=t


func get_weapon_accuracy(key:String="main")->float:
	return weapon_groups[key]["base_accuracy"]


func get_weapon_dispersion(key:String="main")->float:
	return weapon_groups[key]["base_dispersion"]


func get_protection()->Vector2:
	return protection


func _set_weapon_groups(wg:Dictionary):
	weapon_groups=wg
	for key in weapon_groups:
		if weapon_groups[key]==null or weapon_groups[key].is_empty():
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
		var i:Projectile=projectile_scene.instantiate()
		i.set_collision_layer_value(5,true)
		i.set_collision_mask_value(2,true)
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
		w.put_projectile(i,rot,get_weapon_dispersion(key),get_weapon_accuracy(key))
		n+=w.num_barrels
	ws.is_ready=false
	ws.timer.start(get_weapon_reload(key))
	
	emit_signal("weapon_fired",key,n)


func damage(p:Projectile):
	if hp<=0:
		return
	
	var v_norm:=p.velocity.normalized()
	var raw_dmg:=v_norm*p.get_damage()-protection
	raw_dmg.x=max(0,raw_dmg.x)
	raw_dmg.y=max(0,raw_dmg.y)
	var dmg_mod:=max(raw_dmg.length(),0.05*p.get_damage())
	hp-=dmg_mod
	emit_signal("damaged",dmg_mod)
	GlobalScript.damage_popup(dmg_mod,p.position)
	if hp<=0:
		emit_signal("killed")
		var explosion:GPUParticles2D=preload("res://gameplay/effect/explosion.tscn").instantiate()
		GlobalScript.node2d_root.add_child(explosion)
		explosion.global_position=global_position
		explosion.scale=0.15*Vector2(1,1)
		
		_add_sinking_ship()
		
		GlobalScript.play_sound("res://gameplay/effect/tm2_bom002.wav")
		queue_free()


func _add_sinking_ship():
	var sinking:SinkingShip=preload("res://gameplay/ship/sinking_ship.tscn").instantiate()
	GlobalScript.node2d_root.add_child(sinking)
	sinking.setup($Sprite2D,scale)


func _on_ReloadTimer_timeout(key:String):
	weapon_states[key].is_ready=true
	emit_signal("weapon_reloaded",key)


func _on_Ship_tree_exiting():
	for key in weapon_groups:
		var ws:WeaponState=weapon_states[key]
		if ws.projectile_prototype:
			ws.projectile_prototype.queue_free()
