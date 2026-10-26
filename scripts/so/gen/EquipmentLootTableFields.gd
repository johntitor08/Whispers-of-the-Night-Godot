class_name EquipmentLootTableFields
extends SO

var possibleEquipment:
	get:
		return d.get("possibleEquipment", [])
	set(v):
		d["possibleEquipment"] = v

var commonChance:
	get:
		return d.get("commonChance", 0.50)
	set(v):
		d["commonChance"] = v

var rareChance:
	get:
		return d.get("rareChance", 0.15)
	set(v):
		d["rareChance"] = v

var epicChance:
	get:
		return d.get("epicChance", 0.04)
	set(v):
		d["epicChance"] = v

var legendaryChance:
	get:
		return d.get("legendaryChance", 0.01)
	set(v):
		d["legendaryChance"] = v

var minDrops:
	get:
		return d.get("minDrops", 0)
	set(v):
		d["minDrops"] = v

var maxDrops:
	get:
		return d.get("maxDrops", 2)
	set(v):
		d["maxDrops"] = v

var equipmentDropChance:
	get:
		return d.get("equipmentDropChance", 0.3)
	set(v):
		d["equipmentDropChance"] = v

var luckBonusPerPoint:
	get:
		return d.get("luckBonusPerPoint", 0.5)
	set(v):
		d["luckBonusPerPoint"] = v
