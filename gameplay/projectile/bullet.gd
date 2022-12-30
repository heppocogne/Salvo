class_name Bullet
extends Projectile


func _ready():
	scale=base_damage/20*Vector2(1,1)
	_scale_modifier=Vector2(0.5,0.5)


func _on_Projectile_area_entered(area:Area2D):
	if area.has_method("damage"):
		if invalid:
			return
		invalid=true
		
		area.damage(self)
		var fragment:Particles2D=preload("res://gameplay/effect/bullet_fragment.tscn").instance()
		GlobalScript.node2d_root.add_child(fragment)
		fragment.global_position=global_position
		
		GlobalScript.play_sound("res://gameplay/effect/metal05.wav")
	elif area==GlobalScript.water_area:
		var splash:Particles2D=preload("res://gameplay/effect/water_splash.tscn").instance()
		GlobalScript.node2d_root.add_child(splash)
		splash.scale=_scale_modifier
		splash.global_position=global_position
		
		GlobalScript.play_sound("res://gameplay/effect/sha00.wav")
	queue_free()
