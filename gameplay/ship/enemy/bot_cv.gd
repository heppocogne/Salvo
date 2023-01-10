extends "res://gameplay/ship/enemy/bot_ship.gd"

const f1_scene:PackedScene=preload("res://gameplay/aircraft/fighter.tscn")
const f2_scene:PackedScene=preload("res://gameplay/aircraft/fighter2.tscn")
const b1_scene:PackedScene=preload("res://gameplay/aircraft/bomber.tscn")
const b2_scene:PackedScene=preload("res://gameplay/aircraft/bomber2.tscn")

export var fighter_takeoff_duration:float=4.0
export var fighter_y_min:float=360
export var fighter_y_max:float=400
export var bomber_takeoff_duration:float=6.0
export var bomber_y_min:float=100
export var bomber_y_max:float=150


func _ready():
	pass



