class_name SinkingShip
extends Node2D

var texture:Texture
var duration:=3.0


func _ready():
	$Sprite.rotation=rand_range(-PI,PI)/6.0
	$Sprite.texture=texture
	$Timer.wait_time=duration
	$Timer.start()
	$Tween.interpolate_property(
		self,
		"modulate",
		Color.white,
		Color(1,1,1,0),
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	$Tween.start()


func _physics_process(delta:float):
	position.y+=3.0*delta


func _on_Timer_timeout():
	queue_free()
