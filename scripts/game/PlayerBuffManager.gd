class_name PlayerBuffManager
extends Mono

class Buff:
	var id := ""
	var type := 0
	var multiplier := 1.0
	var duration := 5.0
	var stackable := false
	var fightsRemaining := 0
	var endTime := 0.0
	var uiKey := ""
	var damageMultiplier := 1.0
	var damageReduction := 0.0
	var icon
	var displayName := ""

class BuffType:
	enum { HealthRegen, EnergyRegen, Damage, Defense, Speed, CritChance }

static var Instance: PlayerBuffManager
signal OnBuffsChanged
var activeBuffs: Array = []
var buffUIParent
var buffUIPrefab
var buffUIMap: Dictionary = {}

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)

func Update() -> void:
	UpdateBuffs()

func AddBuff(buff) -> void:
	if not buff.stackable:
		for ex in activeBuffs:
			if ex.id == buff.id:
				if buff.fightsRemaining > 0:
					ex.fightsRemaining = buff.fightsRemaining
				else:
					ex.endTime = U.time + buff.duration
				if buffUIMap.has(buff.id) and is_instance_valid(buffUIMap[buff.id]):
					buffUIMap[buff.id].UpdateTimer(buff.duration)
				OnBuffsChanged.emit()
				return
	buff.endTime = INF if buff.fightsRemaining > 0 else U.time + buff.duration
	activeBuffs.append(buff)
	SpawnBuffUI(buff)
	OnBuffsChanged.emit()

func UpdateBuffs() -> void:
	var changed := false
	for i in range(activeBuffs.size() - 1, -1, -1):
		var b = activeBuffs[i]
		if b.fightsRemaining > 0:
			continue
		var left: float = b.endTime - U.time
		if b.uiKey != "" and buffUIMap.has(b.uiKey) and is_instance_valid(buffUIMap[b.uiKey]):
			buffUIMap[b.uiKey].UpdateTimer(left)
		if U.time >= b.endTime:
			RemoveBuffUI(b.uiKey if b.uiKey != "" else b.id)
			activeBuffs.remove_at(i)
			changed = true
	if changed:
		OnBuffsChanged.emit()

func NotifyCombatEnded() -> void:
	var changed := false
	for i in range(activeBuffs.size() - 1, -1, -1):
		var b = activeBuffs[i]
		if b.fightsRemaining <= 0:
			continue
		b.fightsRemaining -= 1
		if b.fightsRemaining <= 0:
			RemoveBuffUI(b.uiKey if b.uiKey != "" else b.id)
			activeBuffs.remove_at(i)
			changed = true
	if changed:
		OnBuffsChanged.emit()

func SpawnBuffUI(b) -> void:
	if buffUIPrefab == null or buffUIParent == null or U.empty(b.displayName):
		return
	var obj = U.Instantiate(buffUIPrefab, buffUIParent)
	var ui = U.GetComponent(obj, BuffUI)
	if ui == null:
		return
	ui.Setup(b.icon, b.displayName, b.duration)
	var key: String = (b.id + "_" + str(randi())) if b.stackable else b.id
	b.uiKey = key
	buffUIMap[key] = ui

func RemoveBuffUI(id: String) -> void:
	if buffUIMap.has(id):
		var ui = buffUIMap[id]
		if is_instance_valid(ui):
			U.Destroy(ui.gameObject)
		buffUIMap.erase(id)

func GetDamageMultiplier() -> float:
	var m := 1.0
	for b in activeBuffs:
		if b.type == BuffType.Damage:
			m *= b.damageMultiplier
	return m

func GetDamageReduction() -> float:
	var r := 0.0
	for b in activeBuffs:
		if b.type == BuffType.Defense:
			r += b.damageReduction
	return clampf(r, 0.0, 1.0)

func HasBuff(id: String) -> bool:
	for b in activeBuffs:
		if b.id == id:
			return true
	return false

func GetActiveBuffs() -> Array:
	return activeBuffs.duplicate()

func ClearAll() -> void:
	for k in buffUIMap:
		if is_instance_valid(buffUIMap[k]):
			U.Destroy(buffUIMap[k].gameObject)
	buffUIMap.clear()
	activeBuffs.clear()
	OnBuffsChanged.emit()
