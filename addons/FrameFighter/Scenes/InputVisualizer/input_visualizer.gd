extends Control

@export var fighter_input: FighterInput

@onready var handle = $Gates/Handle
@onready var directions = {
	"neutral": handle.position,
	"up": $Gates/Up,
	"down": $Gates/Down,
	"back": $Gates/Back,
	"forward": $Gates/Forward,
	"down_forward": $Gates/DownForward,
	"down_back": $Gates/DownBack,
	"up_forward": $Gates/UpForward,
	"up_back": $Gates/UpBack
}

@onready var LP = $Actions/LP
@onready var MP = $Actions/MP
@onready var HP = $Actions/HP
@onready var LK = $Actions/LK
@onready var MK = $Actions/MK
@onready var HK = $Actions/HK

@onready var charge: Label = $Charge
@onready var history: Label = $History

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_movement()

func _physics_process(_delta: float) -> void:
	_actions()
	_charge()
	_history()

func _history() -> void:
	var text = ""
	var input_history = fighter_input.get_input_history()
	 
	for change in input_history:
		if change.size():
			text += str(change["frames"]) + ": " + change["actions"]["movement"] + ", " + "+".join(change["actions"]["composite"]) + ", " + "+".join(change["actions"]["basic"]) + "\n"
	
	history.text = text

func _charge() -> void:
	var text = ""
	var actions = fighter_input.get_charge()
	
	for action in actions:
		text += action + ": " + str(actions[action]) + "\n"
	
	charge.text = text

func _movement() -> void:
	var movement_direction = fighter_input.get_movement()
	
	if movement_direction != "neutral":
		create_tween().tween_property(handle, "position", directions[movement_direction].position, 0.02)
	else:
		create_tween().tween_property(handle, "position", directions["neutral"], 0.02)

func _actions() -> void:
	var actions = fighter_input.get_basic_actions()
	
	LP.release()
	MP.release()
	HP.release()
	LK.release()
	MK.release()
	HK.release()
	
	for action in actions:
		if action == "lp":
			LP.press()
		elif action == "mp":
			MP.press()
		elif action == "hp":
			HP.press()
		elif action == "lk":
			LK.press()
		elif action == "mk":
			MK.press()
		elif action == "hk":
			HK.press()
