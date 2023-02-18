class_name SinkingShip
extends Sprite2D

var duration:=3.0


func _ready():
	var tm:Timer=$Timer
	var tw:=Tween.new()
	rotation=randf_range(-PI,PI)/6.0
	tm.wait_time=duration
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
	position.y+=3.0*delta


func setup(s:Sprite2D,parent_scale:Vector2=Vector2(1,1)):
	$Smoke.rotation=-rotation
	texture=s.texture
	offset=s.offset
	scale=s.scale*parent_scale
	flip_h=s.flip_h
	global_position=s.global_position


func _on_Timer_timeout():
	queue_free()
