class_name NavaelBaseObject
extends Area2D

signal damaged(d)
signal killed()

export var hp:int=1000
export var active:=true setget set_active


func _ready():
	pass


func set_active(f:bool):
	active=f
