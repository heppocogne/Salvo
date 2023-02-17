extends Node


const json_path:String="user://system_save.json"
const _default_savedata:={
		"language":"",
		"se_volume":100,
		"use_default_cursor":false,
		"show_fps":true,
	}

var _data:Dictionary


func _ready():
	connect("tree_exiting",Callable(self,"_on_SystemSaveData_tree_exiting"))
	
	var f:=FileAccess.open(json_path,FileAccess.READ)
	if f:
		var s:=f.get_as_text()
		var test_json_conv = JSON.new()
		test_json_conv.parse(s)
		var parse_result:Dictionary=test_json_conv.data
		_data=test_json_conv.data
	else:
		_data=_default_savedata
		if OS.get_locale_language()=="ja":
			_data["language"]="ja"
		else:
			_data["language"]="en"
	
	print_debug("system_save_data=",_data)


func save_to_file():
	var f:=FileAccess.open(json_path,FileAccess.WRITE)
	if f:
		var json:=JSON.new().stringify(_data)
		f.store_string(json)


func _on_SystemSaveData_tree_exiting():
	save_to_file()


func store(key:String,value):
	_data[key]=value


func has_key(key:String)->bool:
	return _data.has(key)


func read(key:String,use_default_unlesss_exists:=true):
	if use_default_unlesss_exists and !has_key(key):
		_data[key]=_default_savedata[key]
	return _data[key]


func reset():
	_data=_default_savedata
	if OS.get_locale_language()=="ja":
		_data["language"]="ja"
	else:
		_data["language"]="en"
