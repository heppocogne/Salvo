class_name Projectile
extends Area2D

export var base_damage:int=1
export var sync_rotation:bool=true

var velocity:Vector2


func _ready():
	pass


func _physics_process(delta:float):
	position+=velocity*delta
	if sync_rotation and velocity.length_squared()!=0:
		rotation=velocity.angle()
	
	velocity+=gravity*gravity_vec


func _on_Projectile_area_entered(area:Area2D):
	pass