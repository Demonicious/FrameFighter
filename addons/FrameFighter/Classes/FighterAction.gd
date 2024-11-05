extends Object
class_name FighterAction

var name: String
var is_composite: bool
var is_pressed: bool
var charge_type: FrameFighter.CHARGE
var input_map_action: String
var dependencies: Array[String]

static func basic(_name: String, _input_map_action: String, _charge_type: FrameFighter.CHARGE) -> FighterAction:
	var ins = FighterAction.new()
	
	ins.name = _name
	ins.is_composite = false
	ins.is_pressed = false
	ins.charge_type = _charge_type
	ins.input_map_action = _input_map_action

	return ins

static func composite(_name: String, _dependencies: Array[String], _charge_type: FrameFighter.CHARGE) -> FighterAction:
	var ins = FighterAction.new()
	
	ins.name = _name
	ins.is_composite = true
	ins.is_pressed = false
	ins.charge_type = _charge_type
	ins.dependencies = _dependencies

	return ins
