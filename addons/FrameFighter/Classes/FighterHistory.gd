extends Object
class_name FighterHistory

var _history: Array[Dictionary]
var _size: int = 15

# Manages the Input History. Pushes the most recent set of inputs in the front of the array if they
# differ from the last frame.
# Also counts up the frames.
func update(actions: FighterActionController, previous_frame: Array) -> void:
	if ",".join(actions.pressed_actions()) != ",".join(previous_frame):
		_history.push_front({
			"frames": 0,
			"actions": {
				"movement": actions.movement_direction(),
				"basic": actions.basic_actions(),
				"composite": actions.composite_actions(),
				"charge": actions.charged_actions()
			}
		})
		
		_history.resize(_size)

	if _history.size():
		_history[0]["frames"] += 1
		_history[0]["frames"] = clamp(_history[0]["frames"], 0, 99)

func set_size(size: int) -> void:
	_size = size

func all() -> Array[Dictionary]:
	return _history

func current() -> Dictionary:
	return _history[0]
