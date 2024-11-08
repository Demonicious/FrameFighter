extends Object
class_name FighterActionController

var _actions: Dictionary = {}
var _charge: Dictionary = {}

var should_charge: bool = true

var _side: FrameFighter.SIDE = FrameFighter.SIDE.PLAYER_ONE

var _back_input: String
var _forward_input: String

# Used to keep track of Pressed Actions.
var _pressed_actions_movement: String = "neutral"
var _pressed_actions_basic: Array[String] = []
var _pressed_actions_composite: Array[String] = []

# Bind Specific Actions like Attacks, Specials, Projectiles and More.
func add(name: String, input_map_action: String, charge_type: FrameFighter.CHARGE = FrameFighter.CHARGE.NONE) -> void:
	_actions[name] = FighterAction.basic(name, input_map_action, charge_type)
	
	_create_charge_key(name)

# Bind Specific Composite Actions using Pre-registered actions for EX Moves, Throws, etc
func add_composite(name: String, dependencies: Array[String], charge_type: FrameFighter.CHARGE = FrameFighter.CHARGE.NONE) -> void:
	_actions[name] = FighterAction.composite(name, dependencies, charge_type)
	
	_create_charge_key(name)

# Bind the 4 Movement Directions and their derived composite actions.
func bind_directions(up_action: String, down_action: String, back_action: String, forward_action: String) -> void:
	add("up", up_action)
	add("down", down_action, FrameFighter.CHARGE.IMMEDIATE)
	add("back", back_action, FrameFighter.CHARGE.IMMEDIATE)
	add("forward", forward_action)
	
	_back_input = back_action
	_forward_input = forward_action
	
	add_composite("up_forward", [ "up", "forward" ])
	add_composite("up_back", [ "up", "back" ])
	add_composite("down_forward", [ "down", "forward" ])
	add_composite("down_back", [ "down", "back" ])

func set_charge_type(action: String, charge_type: FrameFighter.CHARGE) -> void:
	_actions[action].charge_type = charge_type
	_create_charge_key(action)

# This method marks the pressed property on an action.
func press(name: String) -> void:
	_actions[name].is_pressed = true

# This method marks the pressed property on an action.
func release(name: String) -> void:
	_actions[name].is_pressed = false

func handle_side_switch(side: FrameFighter.SIDE) -> void:
	if _side == FrameFighter.SIDE.PLAYER_TWO:
		_actions["back"].input_map_action = _forward_input
		_actions["forward"].input_map_action = _back_input
	else:
		_actions["back"].input_map_action = _back_input
		_actions["forward"].input_map_action = _forward_input

# Private method to ensure the action key exists in the charge dictionary.
func _create_charge_key(action: String) -> void:
	if is_chargeable(action):
		_charge[action] = 0
	else:
		_charge.erase(action)

func increment_charge(action: String) -> void:
	_charge[action] += 1
	_charge[action] = clamp(_charge[action], 0, 99)

func decrement_charge(action: String) -> void:
	_charge[action] -= 1
	_charge[action] = clamp(_charge[action], 0, 99)

func reset_charge(action: String) -> void:
	_charge[action] = 0

# Get the entire action object.
func get_action(name: String) -> FighterAction:
	return _actions[name]

func get_all_actions() -> Array:
	return _actions.keys() as Array

func get_input_map_key(action: String) -> String:
	return get_action(action).input_map_action

func get_dependencies(action: String) -> Array[String]:
	return get_action(action).dependencies

func get_charge_type(action: String) -> FrameFighter.CHARGE:
	return get_action(action).charge_type

# Checks if an action is chargeable or not.
func is_chargeable(action: String) -> bool:
	return get_charge_type(action) != FrameFighter.CHARGE.NONE

func is_composite(action: String) -> bool:
	return get_action(action).is_composite

# Used to check whether an action (basic or composite) is currently pressed.
func is_pressed(name: String) -> bool:
	return get_action(name).is_pressed

# Used to check whether the input map key for a basic action is currently pressed.
# This is useful where you want to check for a key being pressed even when the action could not be pressed. 
# For example when 2 cardinal directions are held.
func is_key_pressed(action: String) -> bool:
	return Input.is_action_pressed(get_action(action).input_map_action)

# These are hard-coded for now.
# Ideally the user defines these alongside other actions.
func is_movement(action: String) -> bool:
	return [
		"up", "down", "back", "forward",
		
		"up_forward", "up_back",
		"down_forward", "down_back"
	].has(action)

# Function to get the pressed actions from other scripts. Movement Actions always appear first.
func pressed_actions() -> Array:
	# Separate movement actions from other actions so that movement actions are always earlier in the returned array
	_pressed_actions_movement = "neutral"
	_pressed_actions_basic = []
	_pressed_actions_composite = []
	
	for action in get_all_actions():
		if is_pressed(action):
			if is_movement(action):
				_pressed_actions_movement = action
			elif is_composite(action):
				_pressed_actions_composite.append(action)
			else:
				_pressed_actions_basic.append(action)
	
	return [_pressed_actions_movement] + _pressed_actions_composite + _pressed_actions_basic

func movement_direction() -> String:
	return _pressed_actions_movement

func basic_actions() -> Array[String]:
	return _pressed_actions_basic

func composite_actions() -> Array[String]:
	return _pressed_actions_composite

func charged_actions() -> Dictionary:
	return _charge

func opposite(movement_action: String) -> String:
	return FrameFighter.OPPOSITE_DIRECTIONS[movement_action]

func tick() -> void:
	for action in get_all_actions():
		if !is_composite(action):
			if is_key_pressed(action):
				press(action)
				
				if is_movement(action):
					_handle_socd(action)
			else:
				release(action)
		else:
			_handle_composite_action(action)
		
		if is_chargeable(action):
			_handle_charge_action(action)

func _handle_composite_action(action: String) -> void:
	var pressed := true
	
	for dependency in get_dependencies(action):
		pressed = pressed and is_pressed(dependency)
	
	if pressed:
		press(action)
		
		# In-case of movement options. We release the dependency keys cause we only need direction value out of 8 possible directions.
		if is_movement(action):
			for dependency in get_dependencies(action):
				release(dependency)
	else:
		release(action)

func _handle_charge_action(action: String) -> void:
	if is_pressed(action) and should_charge:
		increment_charge(action)
	else:
		if get_charge_type(action) == FrameFighter.CHARGE.IMMEDIATE:
			reset_charge(action)
		elif get_charge_type(action) == FrameFighter.CHARGE.TICK:
			decrement_charge(action)

func _handle_socd(movement_action: String) -> void:
	if is_key_pressed(opposite(movement_action)):
		release(movement_action)
		release(opposite(movement_action))
