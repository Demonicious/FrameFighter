extends Object
class_name FrameFighter

enum CHARGE {
	NONE = 0,
	IMMEDIATE = 1,
	TICK = 2
}

enum SIDE {
	PLAYER_ONE = 1,
	PLAYER_TWO = 2
}

const OPPOSITE_DIRECTIONS := {
	"up": "down",
	"down": "up",
	"back": "forward",
	"forward": "back"
}
