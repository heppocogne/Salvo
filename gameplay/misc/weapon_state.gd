class_name WeaponState
extends Node

var nodes:Array
var ready:bool=false
var timer:Timer
var projectile_prototype:Projectile=null


func _init():
	nodes=[]
	timer=Timer.new()
	timer.one_shot=true
	timer.autostart=true


func _ready():
	add_child(timer)
