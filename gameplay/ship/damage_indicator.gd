class_name DamageIndicator
extends Label

@export var font_color:Color


func _ready():
	add_theme_color_override("font_color",font_color)
	var tw:=Tween.new()
	tw.interpolate_property(
		self,
		"position:y",
		position.y+32,
		position.y,
		0.5,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	tw.start()
	tw.interpolate_property(
		self,
		"self_modulate",
		Color(1,1,1,0),
		Color(1,1,1,1),
		0.5,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	tw.start()


func _on_Timer_timeout():
	queue_free()
