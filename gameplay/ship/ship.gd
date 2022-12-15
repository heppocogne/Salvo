tool
class_name Ship
extends Area2D

signal main_weapon_reloaded()

const water_level:=500

export var base_speed:=0.0
export var base_hp:=100
export var protection:Vector2
export(Array,NodePath) var main_weapon_nodepaths:Array
export var base_main_weapon_reload:float=1.0 setget set_base_main_weapon_reload

var hp:=base_hp
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


# enemy by default
func get_projectile_instance(projectile_scene:PackedScene)->Projectile:
	var i:Projectile=projectile_scene.instance()
	i.set_collision_layer_bit(5,true)
	i.set_collision_mask_bit(2,true)
	return i


func fire_main_weapon(a:float):
	for w in main_weapons:
		w.put_projectile(a)
	main_weapon_ready=false


func _on_MainWeaponReloadTimer_timeout():
	main_weapon_ready=true
	emit_signal("main_weapon_reloaded")
