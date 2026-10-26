class_name ShapeType

enum { Line, Rectangle, Circle }

const NAMES := ["Line", "Rectangle", "Circle"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
