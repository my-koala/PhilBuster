@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	print(_get_verb_continuous_tense("test"))
	print(_get_verb_continuous_tense("cut"))
	print(_get_verb_continuous_tense("eat"))
	print(_get_verb_continuous_tense("shop"))
	print(_get_verb_continuous_tense("quit"))
	print(_get_verb_continuous_tense("look"))
	print(_get_verb_continuous_tense("fire"))
	print(_get_verb_continuous_tense("pile"))
	print(_get_verb_continuous_tense("construct"))

var _irregular_verb_continuous_tenses: Dictionary[String, String] = {}

func _get_verb_continuous_tense(verb: String) -> String:
	if _irregular_verb_continuous_tenses.has(verb):
		return _irregular_verb_continuous_tenses[verb]
	
	if verb.ends_with("e") || verb.ends_with("y"):
		return verb.substr(0, verb.length() - 1) + "ing"
	
	if verb.length() > 2:
		var check_0: String = verb[-3]
		var check_1: String = verb[-2]
		var check_2: String = verb[-1]
		if !"aeiou".contains(check_0) && "aeiou".contains(check_1) && !"aeiou".contains(check_2):
			return verb + check_2 + "ing"
	return verb + "ing"
