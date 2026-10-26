class_name ConsumableBuffItem
extends ConsumableBuffItemFields

func Use() -> void:
	if PlayerBuffManager.Instance == null:
		return
	var b := PlayerBuffManager.Buff.new()
	b.id = name if U.empty(d.get("itemID")) else str(d.itemID)
	b.type = int(d.get("buffType", 2))
	b.damageMultiplier = float(d.get("damageMultiplier", 1.0))
	b.damageReduction = float(d.get("damageReduction", 0.0))
	b.fightsRemaining = maxi(1, int(d.get("fights", 2)))
	b.displayName = DisplayName
	b.icon = d.get("icon")
	PlayerBuffManager.Instance.AddBuff(b)
