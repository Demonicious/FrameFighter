@tool
extends Node
class_name FighterInput

var _active = false

var actions: FighterActionController  # A list of all registered actions
var history: FighterHistory # Input history alongside frames an action was held for

var _side: FrameFighter.SIDE = FrameFighter.SIDE.PLAYER_ONE
var _previous_frame_actions: Array = []

var _should_charge: bool = true

func _ready() -> void:
	actions = FighterActionController.new()
	history = FighterHistory.new()

func _physics_process(delta: float) -> void:
	if _active:
		_previous_frame_actions = actions.pressed_actions()
		
		actions.handle_side_switch(_side)
		actions.should_charge = _should_charge
		actions.tick()
		
		history.update(
			actions,
			_previous_frame_actions
		)

func start() -> void:
	_active = true

func stop() -> void:
	_active = false

func set_side(side: FrameFighter.SIDE):
	_side = side

func should_charge(state: bool) -> void:
	_should_charge = state

func get_history() -> Array[Dictionary]:
	return history.all()

func get_actions() -> Dictionary:
	return {
		"movement": actions.movement_direction(),
		"basic": actions.basic_actions(),
		"composite": actions.composite_actions(),
		"charge": actions.charged_actions()
	}
