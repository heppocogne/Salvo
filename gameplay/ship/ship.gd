tool
class_name Ship
extends Area2D

const water_level:=500

export var base_speed:=0.0
export var base_hp:=100
export var protection:Vector2
export var base_main_weapon_reload:float=1.0 setget set_base_main_weapon_reload

var hp:=base_hp


func _ready():
	pass


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
func get_projectile_prototype(projectile_scene:PackedScene)->Projectile:
	var i:Projectile=projectile_scene.instance()
	i.set_collision_layer_bit(5,true)
	i.set_collision_mask_bit(2,true)
	return i
