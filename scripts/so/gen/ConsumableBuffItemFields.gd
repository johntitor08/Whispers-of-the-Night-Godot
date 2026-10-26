class_name ConsumableBuffItemFields
extends ItemData

var buffType:
	get:
		return d.get("buffType", null)
	set(v):
		d["buffType"] = v

var damageMultiplier:
	get:
		return d.get("damageMultiplier", 1.0)
	set(v):
		d["damageMultiplier"] = v

var damageReduction:
	get:
		return d.get("damageReduction", 0.0)
	set(v):
		d["damageReduction"] = v

var fights:
	get:
		return d.get("fights", 2)
	set(v):
		d["fights"] = v
