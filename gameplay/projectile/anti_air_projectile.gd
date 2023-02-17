class_name AntiAirProjectile
extends Projectile

@export var radius:float=20
var delay:float : set = set_delay

var _circle_shape:CircleShape2D


func _ready():
	_circle_shape=CircleShape2D.new()
	_circle_shape.radius=radius
	var s:=Vector2(1,1)*radius/20.0
	scale=Vector2(1,1)
	$FragmentExplosion.scale*=s
	$Smoke.scale*=s
	_scale_modifier=Vector2(0.5,0.5)


func set_delay(d:float):
	delay=d
	$Timer.wait_time=d


func _on_Timer_timeout():
	$Sprite2D.queue_free()
	velocity=Vector2.ZERO
	set_collision_mask_value(0,false)
	$CollisionShape2D.shape=_circle_shape
	$AudioStreamPlayer.play()
	$FragmentExplosion.emitting=true
	$Smoke.emitting=true

	var tm:=Timer.new()
	add_child(tm)
	tm.start(0.4)
	await tm.timeout
	queue_free()
