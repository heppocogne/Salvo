tool
class_name Ship
extends Area2D

signal main_weapon_reloaded()
signal damaged()
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


func fire_main_weapon(a:float):
	for w in main_weapons:
		w.put_projectile(a,get_main_weapon_dispersion(),get_main_weapon_accuracy())
	main_weapon_ready=false
	main_weapon_reload_timer.start(get_main_weapon_reload())


func damage(p:Projectile):
	var v_norm:=p.velocity.normalized()
	var raw_dmg:=v_norm*p.get_damage()-protection
	raw_dmg.x=max(0,raw_dmg.x)
	raw_dmg.y=max(0,raw_dmg.y)
	var dmg_mod:=max(raw_dmg.length(),0.05*p.get_damage())
	hp-=dmg_mod
	emit_signal("damaged")
	if hp<=0:
		emit_signal("killed")
		var explosion:Particles2D=preload("res://gameplay/effect/explosion.tscn").instance()
		GlobalScript.node2d_root.add_child(explosion)
		explosion.global_position=global_position
		explosion.scale=0.15*Vector2(1,1)
		
		var sinking:SinkingShip=preload("res://gameplay/ship/sinking_ship.tscn").instance()
		sinking.texture=$Sprite.texture
		sinking.get_node("Sprite").flip_h=true
		GlobalScript.node2d_root.add_child(sinking)
		sinking.global_position=global_position
		
		queue_free()


func _on_MainWeaponReloadTimer_timeout():
	main_weapon_ready=true
	emit_signal("main_weapon_reloaded")
