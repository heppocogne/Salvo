extends Node

var node2d_root:Node2D
var water_area:Area2D

# ~30: S, 30~50:A, 50~70:B, 70~:C
var enemy_shoot:=0
var enemy_hit:=0


func play_sound(path:String):
	var a:=AudioStreamPlayer2D.new()
	node2d_root.add_child(a)
	a.stream=load(path)
	a.play()
	yield(a,"finished")
	a.queue_free()
