extends Node

const path:String="user://save.var"

var _data:Dictionary


func _ready():
	connect("tree_exiting",self,"_on_SaveData_tree_exiting")
	
	var f:=File.new()
	if f.open(path,File.READ)==OK:
		_data=f.get_var()
	else:
		_data={
			"upgrade_point":0,
			"stage_1_unlocked":true,
		}
	
	print_debug("save_data=",_data)


func _on_SaveData_tree_exiting():
	var f:=File.new()
	if f.open(path,File.WRITE)==OK:
		f.store_var(_data)


func store(key:String,value):
	_data[key]=value


func has_key(key:String)->bool:
	return _data.has(key)


func read(key:String):
	return _data[key]
