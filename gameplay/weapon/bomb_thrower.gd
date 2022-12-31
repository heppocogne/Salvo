class_name BombThrower
extends Weapon


func _ready():
	pass


func put_projectile(projectile_prototype:Projectile,rot:float,dispersion:float,accuracy:float):
	if !$AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
	
	for _i in num_barrels:
		var instance:Projectile=projectile_prototype.duplicate()
		if instance:
			GlobalScript.node2d_root.add_child(instance)
			instance.global_position=to_global(muzzle_position)
			
			# enemy bomber
			var d:=get_random_dispersion(dispersion,accuracy)+dispersion/2
			rot-=PI/6*d
			if instance.sync_rotation:
				instance.rotation=rot
			instance.velocity=Vector2(cos(rot),sin(rot))*get_muzzle_velocity()


func _set_range(r:float):
	_range=r
