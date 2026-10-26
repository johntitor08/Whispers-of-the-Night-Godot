class_name InventoryManager
extends Mono

static var Instance: InventoryManager
static var OnReady := UEvent.new()
signal OnInventoryChanged
signal OnItemUsed(item)
var stock: Dictionary = {}
var totalByItemID: Dictionary = {}

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self
	OnReady.Invoke()

static func Key(id: String, lvl: int) -> String:
	return "%s:%d" % [id, lvl]

func AddItem(item, amount := 1) -> void:
	if item == null or amount <= 0:
		return
	AddInternal(Key(str(item.itemID), 0), amount)

func AddUpgradedItem(data, lvl: int, amount := 1) -> void:
	if data == null or amount <= 0:
		return
	AddInternal(Key(str(data.itemID), lvl), amount)

func AddInstance(inst, amount := 1) -> void:
	if inst == null or amount <= 0:
		return
	AddInternal(Key(str(inst.baseData.itemID), inst.upgradeLevel), amount)

func AddInternal(key: String, amount: int) -> void:
	stock[key] = stock.get(key, 0) + amount
	var id := key.substr(0, key.rfind(":"))
	totalByItemID[id] = totalByItemID.get(id, 0) + amount
	OnInventoryChanged.emit()

func RemoveItem(item, amount := 1) -> bool:
	return item != null and RemoveInternal(Key(str(item.itemID), 0), amount)

func RemoveInstance(inst, amount := 1) -> bool:
	return RemoveInternal(Key(str(inst.baseData.itemID), inst.upgradeLevel), amount)

func RemoveUpgradedItem(data, lvl: int, amount := 1) -> bool:
	return RemoveInternal(Key(str(data.itemID), lvl), amount)

func NotifyItemUsed(item) -> void:
	OnItemUsed.emit(item)

func RemoveInternal(key: String, amount: int) -> bool:
	var cur: int = stock.get(key, -1)
	if cur < amount:
		return false
	if cur == amount:
		stock.erase(key)
	else:
		stock[key] = cur - amount
	var id := key.substr(0, key.rfind(":"))
	if totalByItemID.has(id):
		var nt: int = totalByItemID[id] - amount
		if nt <= 0:
			totalByItemID.erase(id)
		else:
			totalByItemID[id] = nt
	OnInventoryChanged.emit()
	return true

func GetQuantity(item) -> int:
	if item == null:
		return 0
	if item is EquipmentInstance:
		return stock.get(Key(str(item.baseData.itemID), item.upgradeLevel), 0)
	return stock.get(Key(str(item.itemID), 0), 0)

func GetUpgradedQuantity(data, lvl: int) -> int:
	return 0 if data == null else stock.get(Key(str(data.itemID), lvl), 0)

func GetTotalQuantity(id) -> int:
	return totalByItemID.get(str(id), 0)

func HasDuplicates(data) -> bool:
	return GetTotalQuantity(data.itemID) >= 2

func _parse(key: String) -> Array:
	var sep := key.rfind(":")
	if sep < 0:
		return []
	var lvl := key.substr(sep + 1)
	if not lvl.is_valid_int():
		return []
	return [key.substr(0, sep), int(lvl)]

func GetEquipmentInstances() -> Array:
	var res := []
	var db = ItemDatabase.Instance
	if db == null:
		return res
	for k in stock:
		if stock[k] <= 0:
			continue
		var p := _parse(k)
		if p.is_empty():
			continue
		var data = db.GetByID(p[0])
		if not (data is EquipmentData):
			continue
		res.append([EquipmentInstance.new(data, p[1]), stock[k]])
	return res

func GetNonEquipmentItems() -> Array:
	var res := []
	var db = ItemDatabase.Instance
	if db == null:
		return res
	for k in stock:
		if stock[k] <= 0:
			continue
		var p := _parse(k)
		if p.is_empty():
			continue
		var item = db.GetByID(p[0])
		if item == null or item is EquipmentData:
			continue
		res.append([item, stock[k]])
	return res

func GetItems() -> Dictionary:
	var out := {}
	for k in stock:
		var p := _parse(k)
		if p.is_empty() or p[1] != 0:
			continue
		out[p[0]] = stock[k]
	return out

func GetRawStock() -> Dictionary:
	return stock

func GetItem(id):
	if U.empty(id) or ItemDatabase.Instance == null:
		return null
	return ItemDatabase.Instance.GetByID(id)

func Clear() -> void:
	stock.clear()
	totalByItemID.clear()
	OnInventoryChanged.emit()
