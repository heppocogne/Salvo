class_name OneshotParticles2D
extends GPUParticles2D

signal emission_started()
signal emission_finished()

@export var auto_start:=true
@export var auto_remove:=true

var _prev_emitting:=false


func _ready():
	if auto_start:
		set_deferred("emitting",true)


func _process(_delta:float):
	if _prev_emitting and !emitting:
		emit_signal("emission_finished")
		if auto_remove:
			queue_free()
			return
	elif !_prev_emitting and emitting:
		emit_signal("emission_started")
	_prev_emitting=emitting
