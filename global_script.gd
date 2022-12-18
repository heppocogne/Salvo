extends Node

var node2d_root:Node2D
var water_area:Area2D

var player_salvo_diff:Array
var enemy_shoot:=0
var enemy_hit:=0


func _ready():
	player_salvo_diff=[]


func play_sound(path:String):
	var a:=AudioStreamPlayer2D.new()
	node2d_root.add_child(a)
	a.stream=load(path)
	a.play()
	yield(a,"finished")
	a.queue_free()
