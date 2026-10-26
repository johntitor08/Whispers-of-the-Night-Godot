class_name StatType

enum { Health, MaxHealth, Energy, MaxEnergy, Charisma, Strength, Intelligence, Damage, Defense, Speed, Luck }

const NAMES := ["Health", "MaxHealth", "Energy", "MaxEnergy", "Charisma", "Strength", "Intelligence", "Damage", "Defense", "Speed", "Luck"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
