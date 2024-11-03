extends Node2D

@onready var fighter_input: FighterInput = $FighterInput

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Movement Directions.
	# "up", "down", "back", "forward" are built in alongside their composites (down_back, up_forward).
	# You don't need to name these yourself, only provide the Input Map actions they correspond to.
	# Down and Back are also chargeable by default.
	fighter_input.bind_directions(
		"m_up",
		"m_down",
		"m_back",
		"m_forward"
	)
	
	# For other actions, you must specify the name and their Input Map action.
	# Punches
	fighter_input.add_action("lp", "a_lp")
	fighter_input.add_action("mp", "a_mp")
	fighter_input.add_action("hp", "a_hp")
	
	# Kicks
	fighter_input.add_action("lk", "a_lk")
	fighter_input.add_action("mk", "a_mk")
	fighter_input.add_action("hk", "a_hk")
	
	# Composite Inputs
	# Define name of the action with it's dependencies in an array.
	# In the dependencies, you need to use the names of the actions instead of Input Map names.
	fighter_input.add_composite_action("throw", [ "lp", "lk" ])
	
	# To set any action to charge.
	# The name of the action, as-well as the charge type.
	# immediate = When the input is released, the charge resets to 0 immediately.
	# tick = When the input is released, the charge decrements by 1 every frame.
	fighter_input.set_chargeable_action("forward", FrameFighter.CHARGE.IMMEDIATE)

	# Controls whether the node is active or not.
	fighter_input.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	print(fighter_input.is_key_pressed("down"))
	pass
