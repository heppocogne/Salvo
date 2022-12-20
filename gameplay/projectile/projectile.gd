class_name Projectile
extends Area2D

export var base_damage:int=1
export var sync_rotation:bool=true

var invalid:=false
var velocity:Vector2


func _ready():
	pass


func _physics_process(delta:float):
	position+=velocity*delta
	if sync_rotation and velocity.length_squared()!=0:
		rotation=velocity.angle()
	
	velocity+=gravity*gravity_vec*delta


func get_damage()->int:
	return base_damage


func _on_Projectile_area_entered(area:Area2D):
	if area.has_method("damage"):
		if invalid:
			return
		invalid=true
		
		area.damage(self)
		var explosion:Particles2D=preload("res://gameplay/effect/explosion.tscn").instance()
		GlobalScript.node2d_root.add_child(explosion)
		explosion.global_position=global_position
		explosion.scale=0.05*Vector2(1,1)
		explosion.speed_scale=2.0
		
		GlobalScript.play_sound("res://gameplay/effect/tm2_bom001.wav")
		
		if "is_enemy" in area and !area.is_enemy:
			GlobalScript.enemy_hit+=1
	elif area==GlobalScript.water_area:
		var splash:Particles2D=preload("res://gameplay/effect/water_splash.tscn").instance()
		GlobalScript.node2d_root.add_child(splash)
		splash.global_position=global_position
		
		GlobalScript.play_sound("res://gameplay/effect/bom00.wav")
	queue_free()
