class_name Ship
extends Area2D

const water_level:=500

export var base_speed:=0.0
export var base_hp:=100
export var protection:Vector2

var hp:=base_hp


func _ready():
	pass


func _physics_process(_delta:float):
	pass


func get_max_hp()->int:
	return base_hp


func get_speed()->float:
	return base_speed


# enemy by default
func get_projectile_prototype(projectile_scene:PackedScene)->Projectile:
	var i:Projectile=projectile_scene.instance()
	i.set_collision_layer_bit(5,true)
	i.set_collision_mask_bit(2,true)
	return i
