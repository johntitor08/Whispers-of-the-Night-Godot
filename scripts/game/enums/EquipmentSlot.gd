class_name EquipmentSlot

enum { Weapon, Armor, Helmet, Accessory, Shield, Boots }

const NAMES := ["Weapon", "Armor", "Helmet", "Accessory", "Shield", "Boots"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
