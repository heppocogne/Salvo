class_name Marker
extends Sprite

export var rotation_speed:float=TAU

var target_node:Node2D
var popup_offset:=Vector2(0,-10)
var disabled:=false setget set_disabled

var _scale_x:=scale.x
var _time:=0.0


func _ready():
	pass


func _process(delta:float):
	if weakref(target_node).get_ref():
		global_position=target_node.global_position+popup_offset
	else:
		return
	if !disabled:
		_time+=delta
		scale.x=_scale_x*cos(rotation_speed*_time)


func set_disabled(f:bool):
	disabled=f
	visible=!f
