class_name MachineGun
extends Gun


func _ready():
	pass


func _set_range(_r:float):
	_range=_r


func get_range()->float:
	return _range
