class_name Gun
extends Weapon


func _ready():
	pass


func put_projectile(rot:float,dispersion:float,accuracy:float):
	if !$AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
	.put_projectile(rot,dispersion,accuracy)
