tool
class_name Weapon
extends Node2D

export var projectile_scene:PackedScene setget set_projectile_scene
export var base_muzzle_velocity:float setget set_base_muzzle_velocity
export var muzzle_position:Vector2
export var num_barrels:int=1

export var _range:float=-1  setget _set_range,get_range


func _ready():
	pass


func set_projectile_scene(scene:PackedScene):
	projectile_scene=scene
	_range=-1
	get_range()


func set_base_muzzle_velocity(v:float):
	base_muzzle_velocity=v
	_range=-1
	get_range()


func get_muzzle_velocity()->float:
	return base_muzzle_velocity


func _set_range(_r:float):
	push_warning("'_range' is read only")


func get_range()->float:
	if projectile_scene:
		if _range<0.0:
			var instance:Projectile=projectile_scene.instance()
			if instance:
				var v:=get_muzzle_velocity()
				if instance.gravity==0.0:
					_range=INF
				else:
					_range=v*v/instance.gravity
				instance.queue_free()
			else:
				_range=-1.0
	else:
		_range=-1.0
	return _range


static func get_random_dispersion(dispersion:float,accuracy:float)->float:
	var disp:float
	if accuracy==0.0:
		disp=rand_range(-dispersion,dispersion)
	else:
		var a_eval:=accuracy
		var sum:=0.0
		while 0<a_eval:
			var temp:=rand_range(-dispersion,dispersion)
			if a_eval<1:
				temp*=a_eval
			sum+=temp
			a_eval-=1.0
		
		disp=sum/accuracy
	return disp


func put_projectile(projectile_prototype:Projectile,rot:float,dispersion:float,accuracy:float):
	for _i in num_barrels:
		var instance:Projectile=projectile_prototype.duplicate()
		if instance:
			GlobalScript.node2d_root.add_child(instance)
			instance.global_position=to_global(muzzle_position)
			
			rot+=PI/6*get_random_dispersion(dispersion,accuracy)
			if instance.sync_rotation:
				instance.rotation=rot
			instance.velocity=Vector2(cos(rot),sin(rot))*get_muzzle_velocity()
