class_name EquipmentLootTable
extends EquipmentLootTableFields

func RollLoot(playerLuck: int) -> Array:
	var dropped := []
	var total := float(d.get("equipmentDropChance", 0.3)) + playerLuck * float(d.get("luckBonusPerPoint", 0.5)) / 100.0
	if U.value() > total:
		return dropped
	var count := U.rangei(int(d.get("minDrops", 0)), int(d.get("maxDrops", 2)) + 1)
	var attempts := 0
	var max_attempts := count * 4
	while dropped.size() < count and attempts < max_attempts:
		attempts += 1
		var item = RollSingleItem(playerLuck)
		if item != null and not dropped.has(item):
			dropped.append(item)
	return dropped

func RollSingleItem(playerLuck: int):
	var target := RollRarity(playerLuck)
	var pool: Array = d.get("possibleEquipment", [])
	var eligible := pool.filter(func(e): return e.equipment != null and int(e.equipment.rarity) == target and playerLuck >= int(e.minLuckRequired))
	if eligible.is_empty():
		eligible = pool.filter(func(e): return e.equipment != null and playerLuck >= int(e.minLuckRequired))
		if eligible.is_empty():
			return null
	var total := 0.0
	for e in eligible:
		total += float(e.baseDropChance)
	var roll := U.value() * total
	var cur := 0.0
	for e in eligible:
		cur += float(e.baseDropChance)
		if roll <= cur:
			return e.equipment
	return eligible[U.rangei(0, eligible.size())].equipment

func RollRarity(playerLuck: int) -> int:
	var lb := minf(playerLuck * float(d.get("luckBonusPerPoint", 0.5)) / 100.0, 0.05)
	var roll := U.value()
	var cum := float(d.get("legendaryChance", 0.01)) + lb
	if roll <= cum:
		return Rarity.Legendary
	cum += float(d.get("epicChance", 0.04)) + lb * 0.5
	if roll <= cum:
		return Rarity.Epic
	cum += float(d.get("rareChance", 0.15)) + lb * 0.3
	if roll <= cum:
		return Rarity.Rare
	return Rarity.Common
