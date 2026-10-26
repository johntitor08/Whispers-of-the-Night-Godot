class_name CombatAction
extends RefCounted

var actionName := "Attack"
var actionNameTR := ""
var description := ""
var descriptionTR := ""
var icon
var baseDamage := 10
var scalingStat := StatType.Strength
var statScaling := 0.25
var energyCost := 10
var isDefensive := false
var defenseBonus := 30
var defenseStatScaling := 0.25
var healAmount := 0
var guaranteedCrit := false
var critChanceBonus := 0.0
var ignoreDefense := false
var armorPenetration := 0.0
var isFlee := false
var isDisabled := false
var applyBuff := false
var buffId := ""
var buffDisplayName := ""
var buffDisplayNameTR := ""
var buffType := 0
var buffDamageMultiplier := 1.0
var buffDamageReduction := 0.0
var buffDuration := 5.0
var buffIcon

static func from_dict(d: Dictionary) -> CombatAction:
	var a := CombatAction.new()
	for p in a.get_property_list():
		var n: String = p.name
		if d.has(n) and d[n] != null:
			match p.type:
				TYPE_BOOL:
					a.set(n, bool(d[n]))
				TYPE_INT:
					a.set(n, int(d[n]))
				TYPE_FLOAT:
					a.set(n, float(d[n]))
				TYPE_STRING:
					a.set(n, str(d[n]))
				_:
					a.set(n, d[n])
	return a

var DisplayActionName: String:
	get:
		return Loc.Pick(actionName, actionNameTR)

var DisplayDescription: String:
	get:
		return Loc.Pick(description, descriptionTR)

var DisplayBuffName: String:
	get:
		return Loc.Pick(buffDisplayName, buffDisplayNameTR)

func CalculateDamage() -> int:
	if PlayerStats.Instance == null:
		return baseDamage
	var dmg := baseDamage + U.RoundToInt(PlayerStats.Instance.Get(scalingStat) * statScaling)
	if EquipmentManager.Instance != null:
		dmg += EquipmentManager.Instance.GetTotalDamageBonus()
	return maxi(1, dmg)

func CalculateDefenseBonus() -> int:
	var b := defenseBonus
	if PlayerStats.Instance != null:
		b += U.RoundToInt(PlayerStats.Instance.Get(StatType.Defense) * defenseStatScaling)
	return b
