class_name DrawBlendMode

enum { Normal, Multiply, Screen, Overlay }

const NAMES := ["Normal", "Multiply", "Screen", "Overlay"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
