tool
class_name Weapon
extends Node2D

export var projectile_scene:PackedScene
export var base_reload:float setget set_base_reload
export var base_muzzle_velocity:float
export var base_dispersion:float
export var base_accuracy:float
export var muzzle_position:Vector2
export var num_barrels:int=1

var _prototype:Projectile
var _range:float=-1


func _ready():
	assert(get_parent().has_method("get_projectile_prototype"))
	_prototype=get_parent().get_projectile_prototype


func get_reload()->float:
	return base_reload


func set_base_reload(r:float):
	$ReloadTimer.wait_time=base_reload


func get_muzzle_velocity()->float:
	return base_muzzle_velocity


func get_dispersion()->float:
	return base_dispersion


func get_accuracy()->float:
	return base_accuracy


func get_range()->float:
	if _range<0.0:
		var instance:Projectile=_prototype
		if instance:
			var v:=get_muzzle_velocity()
			_range=v*v/(2.0*instance.gravity)
		else:
			_range=0.0
	return _range


func put_projectile(rot:float):
	for _i in num_barrels:
		var instance:Projectile=_prototype.duplicate()
		if instance:
			GlobalScript.node2d_root.add_child(instance)
			instance.global_position=to_global(muzzle_position)
			# TODO: consider dispersion & accuracy
			instance.rotation=rot
