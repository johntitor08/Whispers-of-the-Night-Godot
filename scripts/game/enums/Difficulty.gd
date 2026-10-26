class_name Difficulty

enum { Easy, Medium, Hard }

const NAMES := ["Easy", "Medium", "Hard"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
