class_name Ship
extends Area2D

const water_level:=500

export var base_speed:=0.0
export var base_hp:=100
export var protection:Vector2

var hp:=base_hp


func _ready():
	pass


func _physics_process(_delta:float):
	pass


func get_max_hp()->int:
	return base_hp


func get_speed()->float:
	return base_speed
