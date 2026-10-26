class_name CurrencyType

enum { Gold, Gems, Tokens, Credits }

const NAMES := ["Gold", "Gems", "Tokens", "Credits"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
