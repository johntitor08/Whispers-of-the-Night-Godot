class_name ToolType

enum { Brush, Eraser, Fill, Shape, Eyedropper }

const NAMES := ["Brush", "Eraser", "Fill", "Shape", "Eyedropper"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
