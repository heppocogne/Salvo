extends Node

# for debug
const json_path:String="user://save.json"
const path:String="user://save.var"

var _data:Dictionary


func _ready():
	connect("tree_exiting",self,"_on_SaveData_tree_exiting")
	
	var f:=File.new()
	if OS.has_feature("debug"):
		if f.open(json_path,File.READ)==OK:
			var s:=f.get_as_text()
			var parse_result:=JSON.parse(s)
			if parse_result.error==OK:
				_data=parse_result.result
			else:
				print_debug("Save data corrupted!\nline:%d\nerror:%s"%[parse_result.error_line,parse_result.error_string])
				_data={}
		else:
			_data={
				"upgrade_point":0,
				"tutorial_unlocked":true,
			}
	
	print_debug("save_data=",_data)


func _on_SaveData_tree_exiting():
	var f:=File.new()
	if OS.has_feature("debug"):
		if f.open(json_path,File.WRITE)==OK:
			var json:=to_json(_data)
			f.store_string(json)


func store(key:String,value):
	_data[key]=value


func has_key(key:String)->bool:
	return _data.has(key)


func read(key:String):
	return _data[key]
