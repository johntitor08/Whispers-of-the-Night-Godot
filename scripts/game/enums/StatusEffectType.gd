class_name StatusEffectType

enum { Poison, Bleed, Stun, Burn, Freeze, Slow, Weakness, Strength, Shield, Regeneration }

const NAMES := ["Poison", "Bleed", "Stun", "Burn", "Freeze", "Slow", "Weakness", "Strength", "Shield", "Regeneration"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
