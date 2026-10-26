class_name EquipmentManager
extends Mono

static var Instance: EquipmentManager
static var OnReady := UEvent.new()
signal OnEquipmentChanged
signal OnEquipmentEquipped(inst)
signal OnEquipmentUnequipped(inst)

var equippedItems: Dictionary = {}
var equipmentSets: Array = []

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)

func Start() -> void:
	OnReady.Invoke()

func GetEquipped(slot: int):
	return equippedItems.get(slot)

func IsEquipped(data) -> bool:
	if data == null:
		return false
	for k in equippedItems:
		var v = equippedItems[k]
		if v != null and v.baseData.itemID == data.itemID:
			return true
	return false

func GetAllEquipped() -> Dictionary:
	return equippedItems.duplicate()

func GetTotalDamageBonus() -> int:
	var t := 0
	for inst in equippedItems.values():
		t += inst.GetDamageBonus()
	return t

func CanEquip(inst) -> bool:
	if inst is EquipmentData:
		inst = EquipmentInstance.new(inst)
	if inst == null or inst.baseData == null or IsEquipped(inst.baseData):
		return false
	if ProfileManager.Instance != null and ProfileManager.Instance.profile.level < int(inst.baseData.requiredLevel):
		return false
	if int(inst.baseData.requiredStatValue) > 0 and PlayerStats.Instance != null:
		if PlayerStats.Instance.Get(int(inst.baseData.requiredStat)) < int(inst.baseData.requiredStatValue):
			return false
	return true

func Equip(inst) -> bool:
	if inst is EquipmentData:
		inst = EquipmentInstance.new(inst)
	if not CanEquip(inst):
		return false
	var before = SnapshotStats()
	var slot := int(inst.baseData.slot)
	if equippedItems.has(slot):
		var existing = equippedItems[slot]
		equippedItems.erase(slot)
		OnEquipmentUnequipped.emit(existing)
		if InventoryManager.Instance != null:
			InventoryManager.Instance.AddInstance(existing, 1)
	if InventoryManager.Instance != null:
		InventoryManager.Instance.RemoveInstance(inst, 1)
	equippedItems[slot] = inst
	OnEquipmentEquipped.emit(inst)
	AfterChange(before)
	SaveSystem.SaveGame()
	return true

func Unequip(slot: int, returnToInventory := true, save := true) -> bool:
	if not equippedItems.has(slot):
		return false
	var inst = equippedItems[slot]
	var before = SnapshotStats()
	equippedItems.erase(slot)
	OnEquipmentUnequipped.emit(inst)
	AfterChange(before)
	if returnToInventory and InventoryManager.Instance != null:
		InventoryManager.Instance.AddInstance(inst, 1)
	if save:
		SaveSystem.SaveGame()
	return true

func RestoreEquipped(items: Array) -> void:
	var before = SnapshotStats()
	equippedItems.clear()
	for inst in items:
		if inst != null and inst.baseData != null:
			equippedItems[int(inst.baseData.slot)] = inst
	AfterChange(before)

func UpgradeEquipped(slot: int) -> bool:
	if not equippedItems.has(slot) or not equippedItems[slot].CanUpgrade():
		return false
	var before = SnapshotStats()
	equippedItems[slot].upgradeLevel += 1
	AfterChange(before)
	SaveSystem.SaveGame()
	return true

func GetStatBonus(stat: int) -> int:
	var total := 0
	for inst in equippedItems.values():
		total += inst.GetStatTotal(stat)
	for s in equipmentSets:
		if s is Dictionary and s.get("data") != null:
			total += EquipmentSetBonus.GetBonus(s, GetEquippedSetPieces(int(s.data.setID)), stat)
	return total

static func SnapshotStats():
	return PlayerStats.Instance.SnapshotStats() if PlayerStats.Instance != null else null

func AfterChange(before) -> void:
	if PlayerStats.Instance != null:
		PlayerStats.Instance.RefreshResourceCaps()
		PlayerStats.Instance.NotifyStatChanges(before)
	OnEquipmentChanged.emit()

func GetEquippedSetPieces(setID: int) -> int:
	var c := 0
	for inst in equippedItems.values():
		var sd = inst.baseData.setData
		if sd != null and int(sd.setID) == setID:
			c += 1
	return c

func GetActiveSetBonusDescriptions() -> Array:
	var list := []
	for s in equipmentSets:
		if not (s is Dictionary) or s.get("data") == null:
			continue
		var pieces := GetEquippedSetPieces(int(s.data.setID))
		if pieces == 0:
			continue
		list.append("%s (%d/%d)" % [s.data.DisplaySetName, pieces, int(s.data.totalPieces)])
		list.append(EquipmentSetBonus.GetDescription(s, pieces))
	return list
