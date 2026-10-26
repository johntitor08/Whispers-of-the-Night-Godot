class_name GameLanguage

enum { EN, TR }

const NAMES := ["EN", "TR"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
