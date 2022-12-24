tool
class_name SubjectEvaluation
extends HBoxContainer

const colors:={
	"S":Color.orangered,
	"A":Color.yellow,
	"B":Color.skyblue,
	"C":Color.lightgreen,
	"D":Color.lightgray,
}

export var subject_name:String setget set_subject_name
var evaluation:String setget set_evaluation


func _ready():
	pass


func set_subject_name(n:String):
	subject_name=n
	if has_node("Subject"):
		$Subject.text=n


func set_evaluation(e:String):
	evaluation=e
	if has_node("Evaluation"):
		$Evaluation.text=e
		if colors.has(e):
			$Evaluation.add_color_override("font_color",colors[e])
