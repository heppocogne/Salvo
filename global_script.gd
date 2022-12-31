extends Node

var battele_screen:Control
var node2d_root:Node2D
var water_area:Area2D


func play_sound(path:String):
	var a:=AudioStreamPlayer.new()
	node2d_root.add_child(a)
	a.stream=load(path)
	a.play()
	a.connect("finished",a,"queue_free")


func damage_popup(dmg:int,pos:Vector2,color:Color=Color.black):
	var popup:DamageIndicator=preload("res://gameplay/ship/damage_indicator.tscn").instance()
	popup.text=str(dmg)
	popup.font_color=color
	popup.rect_position=pos+Vector2(0,-64)
	GlobalScript.node2d_root.add_child(popup)
