class_name EnemyLoot
extends Mono

var equipmentLootTable
var possibleLoot: Array = []
var lootChances: Array = []
var minGold := 10
var maxGold := 50
var luckDropChanceBonus := 0.005
var showDropLog := true

func DropLoot(data = null) -> void:
	var loot = data.possibleLoot if data != null else possibleLoot
	var chances = data.lootChances if data != null else lootChances
	var table = data.equipmentLootTable if data != null else equipmentLootTable
	var luck: int = PlayerStats.Instance.Get(StatType.Luck) if PlayerStats.Instance != null else 0
	if table != null:
		for eq in table.RollLoot(luck):
			if eq == null:
				continue
			_add(eq)
			LogDrop("<color=%s>%s</color> (%s)" % [UIPalette.Hex(eq.GetRarityColor()), eq.DisplayName, Loc.T("Equipment", "Ekipman")])
	if loot != null and chances != null:
		for i in mini(loot.size(), chances.size()):
			var item = loot[i]
			if item == null:
				continue
			var base := float(chances[i])
			var ch := 0.0 if base <= 0.0 else clampf(base + luck * luckDropChanceBonus, 0.0, 1.0)
			if U.value() <= ch:
				_add(item)
				LogDrop("<color=%s>%s</color>" % [UIPalette.Hex(UIPalette.Gold), item.DisplayName])
	if ProfileManager.Instance != null:
		var gold := U.rangei(minGold, maxGold + 1)
		ProfileManager.Instance.AddCurrency(gold)
		LogDrop("<color=%s>%d %s</color>" % [UIPalette.Hex(UIPalette.Gold), gold, Loc.T("Gold", "Altın")])

func _add(item) -> void:
	if InventoryManager.Instance != null:
		InventoryManager.Instance.AddItem(item, 1)

func LogDrop(msg: String) -> void:
	if showDropLog and CombatUI.Instance != null:
		CombatUI.Instance.AddLogMessage("%s: %s" % [Loc.T("Obtained", "Elde edildi"), msg])
