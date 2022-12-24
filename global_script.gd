extends Node

var battele_screen:Control
var node2d_root:Node2D
var water_area:Area2D


func play_sound(path:String):
	var a:=AudioStreamPlayer2D.new()
	node2d_root.add_child(a)
	a.stream=load(path)
	a.play()
	yield(a,"finished")
	a.queue_free()
