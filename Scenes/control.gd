extends Node2D

@onready var fighter_input: FighterInput = $FighterInput

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Movement Directions.
	# "up", "down", "back", "forward" are built in alongside their composites (down_back, up_forward).
	# You don't need to name these yourself, only provide the Input Map actions they correspond to.
	# Down and Back are also chargeable by default.
	fighter_input.actions.bind_directions(
		"m_up",
		"m_down",
		"m_back",
		"m_forward"
	)
	
	# For other actions, you must specify the name and their Input Map action.
	# Punches
	fighter_input.actions.add("lp", "a_lp")
	fighter_input.actions.add("mp", "a_mp")
	fighter_input.actions.add("hp", "a_hp")
	
	# Kicks
	fighter_input.actions.add("lk", "a_lk")
	fighter_input.actions.add("mk", "a_mk")
	fighter_input.actions.add("hk", "a_hk")
	
	# Composite Inputs
	# Define name of the action with it's dependencies in an array.
	# In the dependencies, you need to use the names of the actions instead of Input Map names.
	fighter_input.actions.add_composite("throw", [ "lp", "lk" ])

	# Controls whether the node is active or not.
	fighter_input.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	pass
