class_name DamageIndicator
extends Label

export var font_color:Color


func _ready():
	add_color_override("font_color",font_color)
	$Tween.interpolate_property(
		self,
		"rect_position:y",
		rect_position.y+32,
		rect_position.y,
		0.5,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	$Tween.start()
	$Tween.interpolate_property(
		self,
		"self_modulate",
		Color(1,1,1,0),
		Color(1,1,1,1),
		0.5,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	$Tween.start()


func _on_Timer_timeout():
	queue_free()
