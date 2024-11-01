extends Node2D

@onready var finput: FighterInput = $FighterInput

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Movement Directions. Up and Back are chargeable by default.
	finput.bind_directions(
		"m_up",
		"m_down",
		"m_back",
		"m_forward"
	)
	
	# Punches
	finput.bind_action("lp", "a_lp")
	finput.bind_action("mp", "a_mp")
	finput.bind_action("hp", "a_hp")
	
	# Kicks
	finput.bind_action("lk", "a_lk")
	finput.bind_action("mk", "a_mk")
	finput.bind_action("hk", "a_hk")
	
	# Composite
	finput.bind_composite_action("throw", [ "lp", "lk" ])
	
	# Charge the forward direction if you want to
	finput.set_chargeable_action("forward", "immediate")

	finput.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	print(finput.is_key_pressed("down"))
	pass
