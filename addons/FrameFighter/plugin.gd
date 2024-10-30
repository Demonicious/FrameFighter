@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("FighterInput", "Node", preload("Nodes/FighterInput.gd"), preload("Assets/InputNode.png"))
	pass


func _exit_tree() -> void:
	remove_custom_type("FighterInput")
	pass
