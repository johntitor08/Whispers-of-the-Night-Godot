class_name TimePhase

enum { Morning, Noon, Evening, Night }

const NAMES := ["Morning", "Noon", "Evening", "Night"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
