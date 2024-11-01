@tool
extends Node
class_name FighterInput

signal generic_input(action: String)
signal motion_input(name: String, sequence: Array)

var _active = false

var _actions: Dictionary = {} # A list of all registered actions
var _charge: Dictionary = {}  # To keep track of directional charge
var _history: Array[Dictionary] = [] # Input history alongside frames an action was held for

var _history_size = 15
var _previous_frame_actions: Array = []

var _main_actions: Array[String] = []
var _composite_actions: Array[String] = []
var _charged_actions: Array[String] = []
var _movement_action: String = "neutral"

func _physics_process(delta: float) -> void:
	if _active:
		_intercept_input()
		_update_history()

func _intercept_input() -> void:
	_previous_frame_actions = get_all_actions()
	
	for action in _actions:
		if !_is_composite_action(action):
			if Input.is_action_pressed(_get_input_map_action(action)):
				_press_action(action)
				
				if _is_movement_action(action):
					_handle_socd(action)
			else:
				_release_action(action)
		else:
			_handle_composite_action(action)
		
		if _is_chargeable_action(action):
			_handle_charge_action(action)

# Manages the Input History. Pushes the most recent set of inputs in the front of the array if they
# differ from the last frame.
# Also counts up the frames.
func _update_history() -> void:
	if ",".join(get_all_actions()) != ",".join(_previous_frame_actions):
		_history.push_front({
			"frames": 0,
			"actions": {
				"movement": get_movement(),
				"main": get_main_actions(),
				"composite": get_composite_actions(),
				"charge": get_charge()
			}
		})
		
		_history.resize(_history_size)

	if _history.size():
		_history[0]["frames"] += 1
		_history[0]["frames"] = clamp(_history[0]["frames"], 0, 99)

# Function to get the pressed actions from other scripts. Movement Actions always appear first.
func get_all_actions() -> Array:
	# Separate movement actions from other actions so that movement actions are always earlier in the returned array
	_movement_action = "neutral"
	_main_actions = []
	_composite_actions = []
	
	for action in _actions:
		if is_action_pressed(action):
			if _is_movement_action(action):
				_movement_action = action
			elif _is_composite_action(action):
				_composite_actions.append(action)
			else:
				_main_actions.append(action)
	
	return [_movement_action] + _composite_actions + _main_actions

func get_movement() -> String:
	return _movement_action

func get_main_actions() -> Array[String]:
	return _main_actions

func get_composite_actions() -> Array[String]:
	return _composite_actions

func get_charge() -> Dictionary:
	return _charge

# Function to get the input history with frame information from other scripts
func get_input_history() -> Array[Dictionary]:
	return _history

# Utility Function to get out the entire input map
func get_input_map() -> Dictionary:
	return _actions

# Bind the 4 Movement Directions and their derived composite actions.
func bind_directions(up_action: String, down_action: String, back_action: String, forward_action: String) -> void:
	_create_action("up", up_action)
	_create_action("down", down_action)
	_create_action("back", back_action)
	_create_action("forward", forward_action)
	
	set_chargeable_action("back", "immediate")
	set_chargeable_action("down", "immediate")
	
	_create_action("up_forward", [ "up", "forward" ], true)
	_create_action("up_back", [ "up", "back" ], true)
	_create_action("down_forward", [ "down", "forward" ], true)
	_create_action("down_back", [ "down", "back" ], true)

# By default only Down and Back are chargeable but you may specify other actions to be chargeable as-well.
func set_chargeable_action(fighter_action: String, charge_type):
	_actions[fighter_action]["charge"] = charge_type
	
	if(_is_chargeable_action(fighter_action)):
		_charge[fighter_action] = 0
	else:
		_charge.erase(fighter_action)

# Bind Specific Actions like Attacks, Specials, Projectiles and More.
func bind_action(fighter_action: String, input_action: String) -> void:
	_create_action(fighter_action, input_action, false)

# Bind Specific Composite Actions using Pre-registered actions for EX Moves, Throws, etc
func bind_composite_action(fighter_action: String, dependencies: Array) -> void:
	_create_action(fighter_action, dependencies, true)

func start() -> void:
	_active = true

func stop() -> void:
	_active = false

func is_action_pressed(fighter_action: String) -> bool:
	return _actions[fighter_action]["pressed"] == true

func set_history_size(size: int) -> void:
	_history_size = size

func _create_action(name: String, input, composite: bool = false) -> void:
	_actions[name] = {
		"composite": composite,
		"pressed": false,
		"charge": "none",
		"input": input
	}

func is_key_pressed(fighter_action: String) -> bool:
	if _get_input_map_action(fighter_action) is not Array:
		return Input.is_action_pressed(_get_input_map_action(fighter_action))
	
	return false

func _get_input_map_action(fighter_action: String):
	return _actions[fighter_action]["input"]
	
func _is_composite_action(fighter_action: String) -> bool:
	return _actions[fighter_action]["composite"] == true

func _get_charge_type(fighter_action: String):
	return _actions[fighter_action]["charge"]

func _is_chargeable_action(fighter_action: String) -> bool:
	return _get_charge_type(fighter_action) != "none"

func _is_movement_action(fighter_action: String) -> bool:
	return [
		"up", "down", "back", "forward",
		
		"up_forward", "up_back",
		"down_forward", "down_back"
	].has(fighter_action)

func _press_action(fighter_action: String) -> void:
	_actions[fighter_action]["pressed"] = true

func _release_action(fighter_action: String) -> void:
	_actions[fighter_action]["pressed"] = false

func _handle_composite_action(fighter_action: String) -> void:
	var pressed := true
	
	for dependency in _get_input_map_action(fighter_action):
		pressed = pressed && is_action_pressed(dependency)
	
	if pressed:
		_press_action(fighter_action)
		
		# In-case of movement options. We release the dependency keys cause we only need direction value out of 8 possible directions.
		if _is_movement_action(fighter_action):
			for dependency in _get_input_map_action(fighter_action):
				_release_action(dependency)
	else:
		_release_action(fighter_action)

func _handle_charge_action(fighter_action: String) -> void:
	if is_action_pressed(fighter_action):
		_charge[fighter_action] += 1
		_charge[fighter_action] = clamp(_charge[fighter_action], 0, 99)
	else:
		if _get_charge_type(fighter_action) == "immediate":
			_charge[fighter_action] = 0
		elif _get_charge_type(fighter_action) == "tick":
			_charge[fighter_action] -= 1
			_charge[fighter_action] = clamp(_charge[fighter_action], 0, 99)

func _handle_socd(movement_action: String) -> void:
	var opposites := {
		"up": "down",
		"down": "up",
		"back": "forward",
		"forward": "back"
	}
	
	if Input.is_action_pressed(_get_input_map_action(opposites[movement_action])):
		_release_action(movement_action)
		_release_action(opposites[movement_action])
