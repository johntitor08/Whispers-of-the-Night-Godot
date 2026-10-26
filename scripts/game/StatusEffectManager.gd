class_name StatusEffectManager
extends Mono

signal OnEffectApplied(data)
signal OnEffectRemoved(data)
signal OnEffectTick(data, amount: int)
signal OnEffectHeal(data, amount: int)
signal OnEffectExpired(data)
var particleParent
var activeEffects: Array = []
var statOwner

func _on_injected(_root: Node) -> void:
	activeEffects = []

func Awake() -> void:
	statOwner = GetComponent(StatsBase)
	if particleParent == null:
		particleParent = gameObject

func Update() -> void:
	if activeEffects.is_empty():
		return
	var dt := U.deltaTime
	for i in range(activeEffects.size() - 1, -1, -1):
		if i >= activeEffects.size():
			continue
		var e = activeEffects[i]
		if not e.data.isPermanent and not e.data.isRoundBased:
			e.remainingDuration -= dt
			if e.IsExpired():
				_remove(e)
				continue
		if e.data.hasTicks and float(e.data.tickInterval) > 0.0 and not e.data.isRoundBased:
			e.nextTickTime -= dt
			while e.nextTickTime <= 0.0:
				ProcessTick(e)
				e.nextTickTime += float(e.data.tickInterval)

func OnEnemyTurnStart() -> void:
	TickRoundBasedEffects(false)

func OnPlayerTurnStart() -> void:
	TickRoundBasedEffects(true)

func TickRoundBasedEffects(onPlayerTurn: bool) -> void:
	for i in range(activeEffects.size() - 1, -1, -1):
		if i >= activeEffects.size():
			continue
		var e = activeEffects[i]
		if not e.data.isRoundBased:
			continue
		var should: bool = (not e.data.isDebuff) if onPlayerTurn else bool(e.data.isDebuff)
		if not should:
			continue
		if e.data.hasTicks:
			ProcessTick(e)
		e.remainingRounds -= 1
		if e.remainingRounds <= 0:
			_remove(e)

func ApplyEffect(data) -> void:
	if data == null or statOwner == null:
		return
	var existing = GetActiveEffect(int(data.effectType))
	if existing != null:
		if data.canStack:
			existing.AddStack()
		if data.refreshOnReapply:
			existing.RefreshDuration()
			OnEffectApplied.emit(existing.data)
		return
	var ne := ActiveStatusEffect.new(data)
	activeEffects.append(ne)
	PlaySound(data.applySound)
	OnEffectApplied.emit(data)

func _remove(e) -> void:
	if e == null or statOwner == null:
		return
	activeEffects.erase(e)
	OnEffectExpired.emit(e.data)
	OnEffectRemoved.emit(e.data)

func ProcessTick(e) -> void:
	if e == null or statOwner == null:
		return
	if int(e.data.tickHeal) > 0:
		var heal: int = int(e.data.tickHeal) * e.currentStacks
		statOwner.Modify(StatType.Health, heal, false)
		OnEffectHeal.emit(e.data, heal)
		PlaySound(e.data.tickSound)
	elif int(e.data.tickDamage) != 0:
		var dmg: int = int(e.data.tickDamage) * e.currentStacks
		statOwner.Modify(StatType.Health, -dmg, false)
		OnEffectTick.emit(e.data, dmg)
		PlaySound(e.data.tickSound)

func RemoveEffect(type: int) -> void:
	var e = GetActiveEffect(type)
	if e != null:
		_remove(e)

func RemoveAllEffects() -> void:
	for i in range(activeEffects.size() - 1, -1, -1):
		_remove(activeEffects[i])

func RemoveAllDebuffs() -> void:
	for i in range(activeEffects.size() - 1, -1, -1):
		if activeEffects[i].data.isDebuff and activeEffects[i].data.isPurgeableByPlayer:
			_remove(activeEffects[i])

func RemoveAllBuffs() -> void:
	for i in range(activeEffects.size() - 1, -1, -1):
		if not activeEffects[i].data.isDebuff and activeEffects[i].data.isPurgeableByPlayer:
			_remove(activeEffects[i])

func HasEffect(type: int) -> bool:
	return GetActiveEffect(type) != null

func GetActiveEffect(type: int):
	for e in activeEffects:
		if int(e.data.effectType) == type:
			return e
	return null

func CanAct() -> bool:
	for e in activeEffects:
		if e.data.preventActions:
			return false
	return true

func GetDamageMultiplier() -> float:
	var m := 1.0
	for e in activeEffects:
		if float(e.data.damageMultiplier) > 0.0:
			m *= float(e.data.damageMultiplier)
	return m

func GetDamageReduction() -> float:
	var r := 0.0
	for e in activeEffects:
		r += float(e.data.damageReduction)
	return clampf(r, 0.0, 1.0)

func PlaySound(c) -> void:
	if c != null:
		UAudioSource.PlayClipAtPoint(c, null, 0.5)
