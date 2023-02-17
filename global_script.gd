extends Node

const water_level:=560

var battele_screen:Control
var node2d_root:Node2D
var water_area:Area2D

var _secret_key:PackedByteArray


func play_sound(path:String):
	var a:=AudioStreamPlayer.new()
	node2d_root.add_child(a)
	a.stream=load(path)
	a.play()
	a.connect("finished",Callable(a,"queue_free"))


func damage_popup(dmg:int,pos:Vector2,color:Color=Color.BLACK):
	var popup:DamageIndicator=preload("res://gameplay/ship/damage_indicator.tscn").instantiate()
	popup.text=str(dmg)
	popup.font_color=color
	popup.position=pos+Vector2(0,-64)
	GlobalScript.node2d_root.add_child(popup)


func get_secret_key()->PackedByteArray:
	if _secret_key.size()!=32:
		# Because this is open source, save data encrypto key is public!
		_secret_key=hex_decode("4925897B0B1408E4DCCA51D09924C58736D7A52498773430DF6AC5BB6BE804A6")
	return _secret_key


func hex_decode(hex:String)->PackedByteArray:
	assert(hex.length()%2==0)
	var map:={
		"A":10,
		"a":10,
		"B":11,
		"b":11,
		"C":12,
		"c":12,
		"D":13,
		"d":13,
		"E":14,
		"e":14,
		"F":15,
		"f":15,
	}
	for i in range(10):
		map[str(i)]=i
	
	var a:PackedByteArray=[]
	var c:=0
	for _i in range(hex.length()/2):
		a.push_back((map[hex[c]]<<4)+map[hex[c+1]])
		c+=2
	
	return a
