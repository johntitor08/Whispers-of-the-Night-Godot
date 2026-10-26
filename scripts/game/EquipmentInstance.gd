class_name EquipmentInstance
extends RefCounted

var baseData
var upgradeLevel := 0

func _init(data = null, upgrade := 0) -> void:
	baseData = data
	upgradeLevel = upgrade

func GetDamageBonus() -> int:
	return Upgraded(int(baseData.damageBonus))

func GetDefenseBonus() -> int:
	return Upgraded(int(baseData.defenseBonus))

func GetPrimaryBonus() -> int:
	return Upgraded(int(baseData.primaryStatBonus))

func GetSecondaryBonus() -> int:
	return Upgraded(int(baseData.secondaryStatBonus))

func Upgraded(b: int) -> int:
	return b + upgradeLevel if b > 0 else 0

func CanUpgrade() -> bool:
	return upgradeLevel < int(baseData.maxUpgradeLevel)

func GetDisplayName() -> String:
	return "%s +%d" % [baseData.DisplayName, upgradeLevel] if upgradeLevel > 0 else baseData.DisplayName

func GetStatTotals() -> Array:
	var totals := []
	var add := func(stat: int, value: int) -> void:
		if value <= 0:
			return
		for t in totals:
			if t[0] == stat:
				t[1] += value
				return
		totals.append([stat, value])
	add.call(StatType.Damage, GetDamageBonus())
	add.call(StatType.Defense, GetDefenseBonus())
	add.call(int(baseData.primaryStat), GetPrimaryBonus())
	add.call(int(baseData.secondaryStat), GetSecondaryBonus())
	return totals

func GetStatTotal(stat: int) -> int:
	for t in GetStatTotals():
		if t[0] == stat:
			return t[1]
	return 0

func GetStatsDescription() -> String:
	var desc := ""
	for t in GetStatTotals():
		desc += "%s: +%d\n" % [DisplayNames.Stat(t[0]), t[1]]
	if upgradeLevel > 0:
		desc += "<color=%s>%s: +%d</color>" % [UIPalette.Hex(UIPalette.Gold), Loc.T("Upgrade", "Geliştirme"), upgradeLevel]
	return desc

func Clone() -> EquipmentInstance:
	return EquipmentInstance.new(baseData, upgradeLevel)
