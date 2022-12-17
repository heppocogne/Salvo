class_name BattleScreen
extends Control

onready var tween:Tween=$VBoxContainer/ViewportContainer/Viewport/Node2DRoot/Tween


func _ready():
	GlobalScript.node2d_root=$VBoxContainer/ViewportContainer/Viewport/Node2DRoot


func _process(_delta:float):
	pass


func spawn_enemy_ship(scene:PackedScene, x:float):
	var ship:Ship=scene.instance()
	GlobalScript.node2d_root.add_child(ship)
	ship.position.y=500
	tween.interpolate_property(
		ship,
		"position:x",
		1500,
		x,
		1.0,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	tween.start()
