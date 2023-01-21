extends Node

# for debug
const json_path:String="user://save.json"
const path:String="user://save.dat"
const _default_savedata:={
		"upgrade_point":0,
		"tutorial_1_unlocked":true,
		"subweapon":"",
		"upgrade_speed":0,
		"upgrade_HP":0,
		"upgrade_belt_armor":0,
		"upgrade_deck_armor":0,
		"upgrade_emergency_repair":0,
		"upgrade_main_weapon_barrels":0,
		"upgrade_main_weapon_caliber":0,
		"upgrade_main_weapon_accuracy":0,
		"upgrade_main_weapon_reload":0,
		"upgrade_sub_weapon_barrels":0,
		"upgrade_sub_weapon_caliber":0,
		"upgrade_sub_weapon_accuracy":0,
		"upgrade_sub_weapon_reload":0,
	}

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
				push_error("Save data corrupted!\nat line:%d\nerror:%s"%[parse_result.error_line,parse_result.error_string])
				get_tree().quit(1)
		else:
			_data=_default_savedata
	else:
		if f.open_encrypted(path,File.READ,GlobalScript.get_secret_key())==OK:
			var s:=f.get_as_text()
			var parse_result:=JSON.parse(s)
			if parse_result.error==OK:
				_data=parse_result.result
			else:
				push_error("Save data corrupted!\nat line:%d\nerror:%s"%[parse_result.error_line,parse_result.error_string])
				get_tree().quit(1)
		else:
			_data=_default_savedata
	
	print_debug("save_data=",_data)


func save_to_file():
	var f:=File.new()
	if OS.has_feature("debug"):
		if f.open(json_path,File.WRITE)==OK:
			var json:=to_json(_data)
			f.store_string(json)
	else:
		if f.open_encrypted(path,File.WRITE,GlobalScript.get_secret_key())==OK:
			var json:=to_json(_data)
			f.store_string(json)


func _on_SaveData_tree_exiting():
	save_to_file()


func store(key:String,value):
	_data[key]=value


func has_key(key:String)->bool:
	return _data.has(key)


func read(key:String,use_default_unlesss_exists:=true):
	if use_default_unlesss_exists and !has_key(key):
		_data[key]=_default_savedata[key]
	return _data[key]
