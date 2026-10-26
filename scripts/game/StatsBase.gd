class_name StatsBase
extends Mono

signal OnStatChanged(type: int, old_value: int, new_value: int)
signal OnDeath

var stats: Array = []
var statDict: Dictionary = {}
var statusEffectManager

static func NewStat(type: int, base_value: int, mn := 0, mx := 999) -> Dictionary:
	return {"type": type, "baseValue": base_value, "currentValue": base_value, "minValue": mn, "maxValue": mx}

func _on_injected(_root: Node) -> void:
	var out := []
	for s in stats:
		if s is Dictionary:
			out.append({"type": int(s.get("type", 0)), "baseValue": int(s.get("baseValue", 0)), "currentValue": int(s.get("currentValue", 0)), "minValue": int(s.get("minValue", 0)), "maxValue": int(s.get("maxValue", 999))})
	stats = out

func Awake() -> void:
	statusEffectManager = GetComponent(StatusEffectManager)
	InitializeStats()

func InitializeStats() -> void:
	statDict.clear()
	for stat in stats:
		if stat.currentValue <= 0:
			stat.currentValue = stat.baseValue
		statDict[stat.type] = stat

func Get(type: int) -> int:
	if not statDict.has(type):
		return 0
	return ApplyEffectModifiers(type, statDict[type].currentValue)

func SnapshotStats() -> Dictionary:
	var snap := {}
	for t in statDict:
		snap[t] = Get(t)
	return snap

func NotifyStatChanges(before) -> void:
	if before == null:
		return
	for k in before:
		if k == StatType.Health or k == StatType.Energy:
			continue
		var now := Get(k)
		if now != before[k]:
			OnStatChanged.emit(k, before[k], now)

func Set(type: int, value: int, save := true) -> void:
	if not statDict.has(type):
		return
	var stat: Dictionary = statDict[type]
	var old: int = stat.currentValue
	stat.currentValue = clampi(value, stat.minValue, stat.maxValue)
	if old != stat.currentValue:
		OnStatChanged.emit(type, old, stat.currentValue)
		if type == StatType.Health and stat.currentValue <= 0:
			OnDeath.emit()
			OnDie()
		if save:
			SaveStats()

func Modify(type: int, amount: int, save := true) -> void:
	if not statDict.has(type):
		return
	var stat: Dictionary = statDict[type]
	var old: int = stat.currentValue
	var mx := GetMaxValue(type, stat)
	stat.currentValue = clampi(stat.currentValue + amount, stat.minValue, mx)
	if old == stat.currentValue:
		return
	OnStatChanged.emit(type, old, stat.currentValue)
	if type == StatType.Health and stat.currentValue <= 0:
		OnDeath.emit()
		OnDie()
	if save:
		SaveStats()

func GetMaxValue(type: int, stat: Dictionary) -> int:
	if type == StatType.Health:
		return Get(StatType.MaxHealth)
	if type == StatType.Energy:
		return Get(StatType.MaxEnergy)
	return stat.maxValue

func ApplyEffectModifiers(type: int, base_value: int) -> int:
	var value := base_value
	if statusEffectManager == null or type == StatType.Health or type == StatType.Energy:
		return value
	for effect in statusEffectManager.activeEffects:
		var mods = effect.data.statModifiers
		if mods == null:
			continue
		for mod in mods:
			if int(mod.statType) != type:
				continue
			var amount: int = int(mod.amount) * effect.currentStacks
			value += U.RoundToInt(base_value * amount / 100.0) if mod.isPercentage else amount
	return value

func SaveStats() -> void:
	pass

func OnDie() -> void:
	pass

func ResetToBase(type: int) -> void:
	if statDict.has(type):
		Set(type, statDict[type].baseValue)

func ResetAllToBase() -> void:
	for stat in stats:
		Set(stat.type, stat.baseValue, false)
	SaveStats()
