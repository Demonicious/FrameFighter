extends Node2D

@onready var finput: FighterInput = $FighterInput

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	finput.bind_directions(
		"m_up",
		"m_down",
		"m_back",
		"m_forward"
	)
	
	finput.bind_action("lp", "a_lp")
	finput.bind_action("mp", "a_mp")
	finput.bind_action("hp", "a_hp")
	
	finput.bind_action("lk", "a_lk")
	finput.bind_action("mk", "a_mk")
	finput.bind_action("hk", "a_hk")
	
	finput.bind_composite_action("1pp", [ "lp", "mp" ])
	finput.bind_composite_action("2pp", [ "mp", "hp" ])
	finput.bind_composite_action("3pp", [ "lp", "hp" ])
	finput.bind_composite_action("4pp", [ "lp", "mp", "hp" ])
	
	finput.bind_composite_action("kk", [ "lk", "mk" ])
	
	finput.bind_composite_action("throw", [ "lp", "lk" ])

	finput.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	print(finput.get_pressed_actions())
	pass
