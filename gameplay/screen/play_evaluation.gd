tool
class_name PlayEvaluation
extends HBoxContainer

const colors:={
	"S":Color.purple,
	"A":Color.skyblue,
	"B":Color.lightgreen,
	"C":Color.yellow,
	"D":Color.orangered,
}

export var title_name:String setget set_title_name
var evaluation:String setget set_evaluation


func _ready():
	pass


func set_title_name(n:String):
	title_name=n
	if has_node("Title"):
		$Title.text=n


func set_evaluation(e:String):
	evaluation=e
	if has_node("Evaluation"):
		$Evaluation.text=e
		if colors.has(e):
			$Evaluation.add_color_override("font_color",colors[e])
