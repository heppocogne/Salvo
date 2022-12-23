class_name SinkingShip
extends Node2D

var duration:=3.0


func _ready():
	var tm:Timer=$Timer
	var tw:Tween=$Tween
	$Sprite.rotation=rand_range(-PI,PI)/6.0
	tm.wait_time=duration
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
	position.y+=3.0*delta


func setup(t:Texture, o:Vector2, scale:Vector2, f_h:bool):
	var s:Sprite=$Sprite
	s.texture=t
	s.offset=o
	s.scale=scale
	s.flip_h=f_h


func _on_Timer_timeout():
	queue_free()
