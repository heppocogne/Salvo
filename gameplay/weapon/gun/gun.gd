tool
class_name Gun
extends Weapon


func _ready():
	pass


func put_projectile(projectile_prototype:Projectile,rot:float,dispersion:float,accuracy:float):
	if !$AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
	.put_projectile(projectile_prototype,rot,dispersion,accuracy)
