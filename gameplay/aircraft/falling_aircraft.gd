class_name FallingAircraft
extends Sprite

const water_level:=500

var duration:=5.0
var velocity:Vector2
var gravity:float
onready var smoke:Particles2D=$Smoke


func _ready():
	var tm:Timer=$Timer
	var tw:Tween=$Tween
	tm.wait_time=duration
	gravity=rand_range(49,98)
	tm.start()
	tw.interpolate_property(
		self,
		"modulate",
		Color.white,
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
	
	if water_level<position.y:
		var splash:Particles2D=preload("res://gameplay/effect/water_splash.tscn").instance()
		GlobalScript.node2d_root.add_child(splash)
		splash.global_position=global_position
		splash.scale=1.5*Vector2(1,1)
		GlobalScript.play_sound("res://gameplay/effect/bom00.wav")
		queue_free()


func setup(s:Sprite,init_velocity:Vector2,parent_scale:Vector2=Vector2(1,1)):
	texture=s.texture
	offset=s.offset
	scale=s.scale*parent_scale
	flip_h=s.flip_h
	flip_v=s.flip_v
	global_position=s.global_position
	
	velocity=init_velocity
