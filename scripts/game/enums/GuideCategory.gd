class_name GuideCategory

enum { Book, Character, Lore }

const NAMES := ["Book", "Character", "Lore"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
