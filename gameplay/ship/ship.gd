tool
class_name Ship
extends Area2D

signal main_weapon_reloaded()
signal main_weapon_fired(n)
signal damaged(d)
signal killed()

const water_level:=500

export var is_enemy:=true
export var base_speed:=0.0
export var base_hp:=100
export var protection:Vector2
export(Array,NodePath) var main_weapon_nodepaths:Array
export var base_main_weapon_reload:=1.0 setget set_base_main_weapon_reload
export var base_main_weapon_accuracy:=0.0
export var base_main_weapon_dispersion:=0.0

onready var main_weapon_reload_timer:Timer=$MainWeaponReloadTimer
onready var hp:=get_max_hp()
var main_weapons:Array
var main_weapon_ready:=false


func _ready():
	main_weapons=[]
	for np in main_weapon_nodepaths:
		var w:Weapon=get_node(np)
		assert(w)
		main_weapons.push_back(w)


func _physics_process(_delta:float):
	pass


func get_max_hp()->int:
	return base_hp


func get_speed()->float:
	return base_speed


func get_main_weapon_reload()->float:
	return base_main_weapon_reload


func set_base_main_weapon_reload(t:float):
	base_main_weapon_reload=t
	$MainWeaponReloadTimer.wait_time=t


func get_main_weapon_accuracy()->float:
	return base_main_weapon_accuracy


func get_main_weapon_dispersion()->float:
	return base_main_weapon_dispersion


# enemy by default
func get_projectile_instance(projectile_scene:PackedScene)->Projectile:
	var i:Projectile=projectile_scene.instance()
	i.set_collision_layer_bit(5,true)
	i.set_collision_mask_bit(2,true)
	return i


func fire_main_weapon(pos:Vector2):
	var n:=0
	for w in main_weapons:
		var v_diff:Vector2=pos-w.global_position
		var i:Projectile=get_projectile_instance(main_weapons[0].projectile_scene)
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
		w.put_projectile(rot,get_main_weapon_dispersion(),get_main_weapon_accuracy())
		n+=w.num_barrels
	main_weapon_ready=false
	main_weapon_reload_timer.start(get_main_weapon_reload())
	
	emit_signal("main_weapon_fired",n)


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
	_damage_popup(dmg_mod,p.position)
	if hp<=0:
		emit_signal("killed")
		var explosion:Particles2D=preload("res://gameplay/effect/explosion.tscn").instance()
		GlobalScript.node2d_root.add_child(explosion)
		explosion.global_position=global_position
		explosion.scale=0.15*Vector2(1,1)
		
		_add_sinking_ship()
		
		GlobalScript.play_sound("res://gameplay/effect/tm2_bom002.wav")
		queue_free()


func _damage_popup(d:int,pos:Vector2):
	var popup:DamageIndicator=preload("res://gameplay/ship/damage_indicator.tscn").instance()
	popup.text=str(d)
	popup.font_color=Color.black
	popup.rect_position=pos+Vector2(0,-64)
	GlobalScript.node2d_root.add_child(popup)


func _add_sinking_ship():
	var sinking:SinkingShip=preload("res://gameplay/ship/sinking_ship.tscn").instance()
	var s:Sprite=$Sprite
	GlobalScript.node2d_root.add_child(sinking)
	sinking.setup(s.texture, s.offset, s.scale*scale, s.flip_h)
	sinking.global_position=global_position


func _on_MainWeaponReloadTimer_timeout():
	main_weapon_ready=true
	emit_signal("main_weapon_reloaded")
