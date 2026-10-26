class_name ItemType

enum { Consumable, Material_, Quest, Equipment }

const NAMES := ["Consumable", "Material", "Quest", "Equipment"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
