class_name FusionManager
extends Mono

static var Instance: FusionManager
var recipes: Array = []
var upgradeMaterialCommon
var upgradeMaterialRare
var upgradeMaterialEpic
var baseGoldPerLevel := 50

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func FindRecipe(a, b):
	for r in recipes:
		if r == null:
			continue
		if (r.ingredientA.itemID == a.itemID and r.ingredientB.itemID == b.itemID) or (r.ingredientA.itemID == b.itemID and r.ingredientB.itemID == a.itemID):
			return r
	return null

func CanFuse(a, b) -> bool:
	if a == null or b == null or a.itemID == b.itemID:
		return false
	var em = EquipmentManager.Instance
	if em != null and (em.IsEquipped(a) or em.IsEquipped(b)):
		return false
	return InventoryManager.Instance.GetQuantity(a) > 0 and InventoryManager.Instance.GetQuantity(b) > 0 and FindRecipe(a, b) != null

func Fuse(a, b):
	if not CanFuse(a, b):
		return null
	var r = FindRecipe(a, b)
	InventoryManager.Instance.RemoveItem(a, 1)
	InventoryManager.Instance.RemoveItem(b, 1)
	if U.value() > float(r.successChance):
		return null
	InventoryManager.Instance.AddItem(r.result, 1)
	Achievements.Unlock(Achievements.Fusion)
	return r.result

func GetUpgradeCost(data, cur: int) -> Dictionary:
	var rar := int(data.rarity)
	var mat = upgradeMaterialCommon if rar == Rarity.Common else (upgradeMaterialRare if rar == Rarity.Rare else upgradeMaterialEpic)
	var f := 6
	match rar:
		Rarity.Common:
			f = 1
		Rarity.Rare:
			f = 2
		Rarity.Epic:
			f = 3
		Rarity.Legendary:
			f = 5
	return {"gold": baseGoldPerLevel * (cur + 1) * f, "material": mat, "materialQty": cur + 1}

func CanUpgradeFuse(data) -> bool:
	if data == null or CountAllCopies(data) < 1:
		return false
	var lvl := GetHighestLevel(data)
	if lvl + 1 > int(data.maxUpgradeLevel):
		return false
	var cost := GetUpgradeCost(data, lvl)
	var has_gold: bool = CurrencyManager.Instance != null and CurrencyManager.Instance.Has(CurrencyType.Gold, cost.gold)
	var has_mat: bool = cost.material == null or (InventoryManager.Instance != null and InventoryManager.Instance.GetQuantity(cost.material) >= cost.materialQty)
	return has_gold and has_mat

func OwnsUpgradeable(data) -> bool:
	if data == null or CountAllCopies(data) < 1:
		return false
	return GetHighestLevel(data) + 1 <= int(data.maxUpgradeLevel)

func UpgradeFuse(data):
	if not CanUpgradeFuse(data):
		return null
	var cur := GetHighestLevel(data)
	var cost := GetUpgradeCost(data, cur)
	if CurrencyManager.Instance != null:
		CurrencyManager.Instance.Spend(CurrencyType.Gold, cost.gold)
	if cost.material != null and cost.materialQty > 0 and InventoryManager.Instance != null:
		InventoryManager.Instance.RemoveItem(cost.material, cost.materialQty)
	var em = EquipmentManager.Instance
	var equipped = em.GetEquipped(int(data.slot)) if em != null else null
	var result
	if equipped != null and equipped.baseData.itemID == data.itemID and equipped.upgradeLevel == cur:
		em.UpgradeEquipped(int(data.slot))
		result = em.GetEquipped(int(data.slot))
	else:
		InventoryManager.Instance.RemoveUpgradedItem(data, cur, 1)
		result = EquipmentInstance.new(data, cur + 1)
		InventoryManager.Instance.AddInstance(result, 1)
	SaveSystem.SaveGame()
	return result

func CountAllCopies(data) -> int:
	var c := 0
	var em = EquipmentManager.Instance
	if em != null:
		var inst = em.GetEquipped(int(data.slot))
		if inst != null and inst.baseData.itemID == data.itemID:
			c += 1
	if InventoryManager.Instance != null:
		c += InventoryManager.Instance.GetTotalQuantity(data.itemID)
	return c

func GetHighestLevel(data) -> int:
	var m := 0
	var em = EquipmentManager.Instance
	if em != null:
		var inst = em.GetEquipped(int(data.slot))
		if inst != null and inst.baseData.itemID == data.itemID:
			m = maxi(m, inst.upgradeLevel)
	if InventoryManager.Instance != null:
		for pair in InventoryManager.Instance.GetEquipmentInstances():
			if pair[0].baseData.itemID == data.itemID:
				m = maxi(m, pair[0].upgradeLevel)
	return m
