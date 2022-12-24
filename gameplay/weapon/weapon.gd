class_name Weapon
extends Node2D

export var projectile_scene:PackedScene
export var base_muzzle_velocity:float
export var muzzle_position:Vector2
export var num_barrels:int=1

var _range:float=-1


func _ready():
	assert(get_parent().has_method("get_projectile_instance"))


func get_muzzle_velocity()->float:
	return base_muzzle_velocity


func get_range()->float:
	if _range<0.0:
		var instance:Projectile=get_parent().get_projectile_instance(projectile_scene)
		if instance:
			var v:=get_muzzle_velocity()
			_range=v*v/instance.gravity
			instance.queue_free()
		else:
			_range=0.0
	return _range


func put_projectile(rot:float,dispersion:float,accuracy:float):
	for _i in num_barrels:
		var instance:Projectile=get_parent().get_projectile_instance(projectile_scene)
		if instance:
			GlobalScript.node2d_root.add_child(instance)
			instance.global_position=to_global(muzzle_position)
			# TODO: consider dispersion & accuracy
			var v_mod:float
			if accuracy==0.0:
				v_mod=rand_range(1-dispersion,1+dispersion)
			else:
				var a_eval:=accuracy
				var sum:=0.0
				while 0<a_eval:
					var temp:=rand_range(1-dispersion,1+dispersion)
					if a_eval<1:
						temp*=a_eval
					sum+=temp
					a_eval-=1.0
				
				v_mod=sum/accuracy
			if instance.sync_rotation:
				instance.rotation=rot
			instance.velocity=Vector2(cos(rot),sin(rot))*get_muzzle_velocity()*v_mod
