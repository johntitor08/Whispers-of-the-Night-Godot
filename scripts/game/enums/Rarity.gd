class_name Rarity

enum { Common, Rare, Epic, Legendary, Godly }

const NAMES := ["Common", "Rare", "Epic", "Legendary", "Godly"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
