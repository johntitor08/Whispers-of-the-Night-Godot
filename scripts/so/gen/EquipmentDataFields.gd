class_name EquipmentDataFields
extends ItemData

var slot:
	get:
		return d.get("slot", 0)
	set(v):
		d["slot"] = v

var damageBonus:
	get:
		return d.get("damageBonus", 0)
	set(v):
		d["damageBonus"] = v

var defenseBonus:
	get:
		return d.get("defenseBonus", 0)
	set(v):
		d["defenseBonus"] = v

var onHitEffect:
	get:
		return d.get("onHitEffect", null)
	set(v):
		d["onHitEffect"] = v

var onHitChance:
	get:
		return d.get("onHitChance", 0.0)
	set(v):
		d["onHitChance"] = v

var primaryStat:
	get:
		return d.get("primaryStat", 0)
	set(v):
		d["primaryStat"] = v

var primaryStatBonus:
	get:
		return d.get("primaryStatBonus", 0)
	set(v):
		d["primaryStatBonus"] = v

var secondaryStat:
	get:
		return d.get("secondaryStat", 0)
	set(v):
		d["secondaryStat"] = v

var secondaryStatBonus:
	get:
		return d.get("secondaryStatBonus", 0)
	set(v):
		d["secondaryStatBonus"] = v

var requiredLevel:
	get:
		return d.get("requiredLevel", 1)
	set(v):
		d["requiredLevel"] = v

var requiredStat:
	get:
		return d.get("requiredStat", 0)
	set(v):
		d["requiredStat"] = v

var requiredStatValue:
	get:
		return d.get("requiredStatValue", 0)
	set(v):
		d["requiredStatValue"] = v

var setData:
	get:
		return d.get("setData", null)
	set(v):
		d["setData"] = v

var maxUpgradeLevel:
	get:
		return d.get("maxUpgradeLevel", 5)
	set(v):
		d["maxUpgradeLevel"] = v
