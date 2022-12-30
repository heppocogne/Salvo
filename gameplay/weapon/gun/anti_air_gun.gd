tool
class_name AntiAirGun
extends Gun


func _ready():
	pass


func put_projectile(projectile_prototype:Projectile,rot:float,dispersion:float,accuracy:float):
	for _i in num_barrels:
		var instance:Projectile=projectile_prototype.duplicate()
		if instance:
			GlobalScript.node2d_root.add_child(instance)
			instance.global_position=to_global(muzzle_position)
			
			rot+=PI/4*get_random_dispersion(dispersion,accuracy)
			if instance.sync_rotation:
				instance.rotation=rot
			instance.velocity=Vector2(cos(rot),sin(rot))*get_muzzle_velocity()
