class_name FallingAircraft
extends Sprite2D

var duration:=5.0
var velocity:Vector2
var gravity:float
@onready var smoke:GPUParticles2D=$Smoke


func _ready():
	var tm:Timer=$Timer
	var tw:=Tween.new()
	tm.wait_time=duration
	gravity=randf_range(49,98)
	tm.start()
	tw.interpolate_property(
		self,
		"modulate",
		Color.WHITE,
		Color(1,1,1,0),
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	tw.start()


func _physics_process(delta:float):
	velocity+=gravity*delta*Vector2.DOWN
	position+=velocity*delta
	rotation=velocity.angle()
	
	if GlobalScript.water_level<position.y:
		var splash:GPUParticles2D=preload("res://gameplay/effect/water_splash.tscn").instantiate()
		GlobalScript.node2d_root.add_child(splash)
		splash.global_position=global_position
		splash.scale=1.5*Vector2(1,1)
		GlobalScript.play_sound("res://gameplay/effect/bom00.wav")
		queue_free()


func setup(s:Sprite2D,init_velocity:Vector2,parent_scale:Vector2=Vector2(1,1)):
	texture=s.texture
	offset=s.offset
	scale=s.scale*parent_scale
	flip_h=s.flip_h
	flip_v=s.flip_v
	global_position=s.global_position
	
	velocity=init_velocity


func _on_Timer_timeout():
	queue_free()
