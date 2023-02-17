@tool
extends "res://gameplay/ship/enemy/bot_ship.gd"

const f1_scene:PackedScene=preload("res://gameplay/aircraft/fighter.tscn")
const f2_scene:PackedScene=preload("res://gameplay/aircraft/fighter2.tscn")
const fb_scene:PackedScene=preload("res://gameplay/aircraft/fighter_bomber.tscn")


@export var fighter_takeoff_duration:float=4.0
@export var fighter_y_min:float=360
@export var fighter_y_max:float=400


func _ready():
	if Engine.editor_hint:
		return
	$FighterTakeoffTimer.wait_time=fighter_takeoff_duration
	$FighterTakeoffTimer.start()


func spawn_aircraft(aircraft_scene:PackedScene)->Aircraft:
	var a:Aircraft=aircraft_scene.instantiate()
	a.connect("damaged",Callable(GlobalScript.battele_screen,"_on_Enemy_damaged"))
	a.connect("weapon_fired",Callable(GlobalScript.battele_screen,"_on_Enemy_fired"))
	GlobalScript.node2d_root.add_child(a)
	return a


func _on_FighterTakeoffTimer_timeout():
	if !GlobalScript.node2d_root.has_node("Player"):
		return
	
	var a:Fighter
	if randi()%4==0:
		a=spawn_aircraft(fb_scene)
	elif randf()<0.5:
		a=spawn_aircraft(f1_scene)
	else:
		a=spawn_aircraft(f2_scene)
		
	
	a.position=global_position
	a.target_velocity=polar2cartesian(a.get_velocity(),deg_to_rad(225))
	a._actual_velocity=a.target_velocity
	a.target_y=randf_range(fighter_y_min,fighter_y_max)
