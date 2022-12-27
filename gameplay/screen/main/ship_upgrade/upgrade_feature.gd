tool
class_name UpgradeFeature
extends HBoxContainer

const pt_save_data_key:String="upgrade_point"

signal upgraded_or_donwgraded(cost)

export var status_name:String setget set_status_name
export var save_data_key:String
export var max_level:=10 setget set_max_level
export var costs:PoolIntArray setget set_costs


func _ready():
	assert(max_level+1==costs.size())
	
	set_status_name(status_name)
	set_max_level(max_level)
	set_costs(costs)
	
	if !Engine.editor_hint:
		if !SaveData.has_key(save_data_key):
			SaveData.store(save_data_key,0)
		var lvl:int=SaveData.read(save_data_key)
		$ProgressBar.value=lvl
		var pt:int=SaveData.read(pt_save_data_key)
		if lvl==0:
			$MinusButton.disabled=true
		if lvl==max_level or pt<costs[lvl]:
			$PlusButton.disabled=true
	
		_update_cost_text()
		_update_cost_color()


func set_status_name(n:String):
	status_name=n
	if has_node("StatusName"):
		$StatusName.text=n


func set_max_level(m:int):
	max_level=m
	if has_node("ProgressBar"):
		$ProgressBar.max_value=m


func set_costs(a:PoolIntArray):
	costs=a


func _change_upgrade_point(cost:int):
	if SaveData.has_key(pt_save_data_key):
		var pt:int=SaveData.read(pt_save_data_key)
		SaveData.store(pt_save_data_key,cost+pt)
	else:
		SaveData.store(pt_save_data_key,0+cost)
	
	emit_signal("upgraded_or_donwgraded")


func _update_cost_text():
	var lvl:int=SaveData.read(save_data_key)
	if lvl==max_level:
		$Cost.text="-"
	else:
		$Cost.text=str(costs[lvl])+" pt"


func _update_cost_color():
	var lvl:int=SaveData.read(save_data_key)
	var pt:int=SaveData.read(pt_save_data_key)
	if pt<costs[lvl]:
		$Cost.add_color_override("font_color",Color("ff6060"))
	else:
		$Cost.add_color_override("font_color",Color("#ffff9b"))


func _update_button_state():
	var lvl:int=SaveData.read(save_data_key)
	var pt:int=SaveData.read(pt_save_data_key)
	
	if lvl==0:
		$MinusButton.disabled=true
	else:
		$MinusButton.disabled=false
	
	if pt<costs[lvl] or lvl==max_level:
		$PlusButton.disabled=true
	else:
		$PlusButton.disabled=false


func _on_MinusButton_pressed():
	var lvl:int=SaveData.read(save_data_key)
	lvl=max(0,lvl-1)
	SaveData.store(save_data_key,lvl)
	_update_cost_text()
	_update_cost_color()
	_change_upgrade_point(costs[lvl]/2)
	$ProgressBar.value=lvl
	
	_update_button_state()


func _on_PlusButton_pressed():
	var lvl:int=SaveData.read(save_data_key)
	_change_upgrade_point(-costs[lvl])
	lvl=min(lvl+1,max_level)
	SaveData.store(save_data_key,lvl)
	_update_cost_text()
	_update_cost_color()
	$ProgressBar.value=lvl
	
	_update_button_state()


func _on_upgrade_point_changed(_pt:int):
	_update_cost_color()
	_update_button_state()
