@tool
extends EditorPlugin
class_name FrameFighterPlugin

func _enter_tree() -> void:
	add_custom_type("FighterInputMap", "Resource", preload("Resources/FighterInputMap.gd"), preload("Assets/InputMapIcon.png"))
	add_custom_type("FighterMoveList", "Resource", preload("Resources/FighterMoveList.gd"), preload("Assets/MoveListIcon.png"))
	add_custom_type("FighterInput", "Node", preload("Nodes/FighterInput.gd"), preload("Assets/InputNode.png"))

func _exit_tree() -> void:
	remove_custom_type("FighterInputMap")
	remove_custom_type("FighterMoveList")
	remove_custom_type("FighterInput")
