class_name Projectile
extends Area2D

export var base_damage:int=1 setget set_base_damage
export var sync_rotation:bool=true

var _original_scale:=scale
var invalid:=false
var velocity:Vector2
var _class_Ship=load("res://gameplay/ship/ship.gd")
var _scale_modifier:Vector2


func _ready():
	pass


func _physics_process(delta:float):
	if (position+velocity*delta).y<GlobalScript.water_level:
		position+=velocity*delta
	else:
		position+=velocity.normalized()*(GlobalScript.water_level-position.y)
	if sync_rotation and velocity.length_squared()!=0:
		rotation=velocity.angle()
	
	velocity+=gravity*gravity_vec*delta

	if 1024<position.y or position.x<-512 or 1536<position.x:
		queue_free()


func set_base_damage(d:int):
	base_damage=d
	_scale_modifier=sqrt(get_damage()/100)*Vector2(1,1)
	scale=_original_scale*_scale_modifier


func get_damage()->int:
	return base_damage


func _on_Projectile_area_entered(area:Area2D):
	if invalid:
		return
	if area==GlobalScript.water_area:
		var splash:Particles2D=preload("res://gameplay/effect/water_splash.tscn").instance()
		GlobalScript.node2d_root.add_child(splash)
		splash.scale=_scale_modifier
		splash.global_position=global_position
		
		# enemy projectile
		if get_collision_layer_bit(5):
			GlobalScript.battele_screen.on_EnemyShell_off(position)
		
		GlobalScript.play_sound("res://gameplay/effect/bom00.wav")
	else:
		invalid=true
		if area.has_method("damage"):
			area.damage(self)
		var explosion:Particles2D=preload("res://gameplay/effect/explosion.tscn").instance()
		GlobalScript.node2d_root.add_child(explosion)
		explosion.global_position=global_position
		explosion.scale=0.05*_scale_modifier
		explosion.speed_scale=2.0
		
		GlobalScript.play_sound("res://gameplay/effect/tm2_bom001.wav")
	queue_free()


func _on_SafetyTimer_timeout():
	$CollisionShape2D.disabled=false
