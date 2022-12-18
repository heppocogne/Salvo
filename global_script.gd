extends Node

var node2d_root:Node2D
var water_area:Area2D

var player_salvo_diff:Array
var enemy_shoot:=0
var enemy_hit:=0


func _ready():
	player_salvo_diff=[]
