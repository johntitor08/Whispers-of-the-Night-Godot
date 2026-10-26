class_name ShopManager
extends Mono

static var Instance: ShopManager
var stock: Dictionary = {}
var _priceMultiplier := 1.0
var shopItems: Array = []

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self
	stock.clear()
	for it in shopItems:
		if it == null or it.item == null:
			continue
		if not it.unlimitedStock:
			stock[it.item.itemID] = int(it.stockAmount)

func ApplyPriceMultiplier(m: float) -> void:
	if m <= 0.0:
		return
	_priceMultiplier *= m
	SaveSystem.SaveGame()

func GetPriceMultiplier() -> float:
	return _priceMultiplier

func GetPriceMultiplierForSave() -> float:
	return _priceMultiplier

func LoadPriceMultiplier(m: float) -> void:
	_priceMultiplier = m if m > 0.0 else 1.0

func CanBuy(s) -> bool:
	if s == null or s.item == null or ProfileManager.Instance == null:
		return false
	var p = ProfileManager.Instance.profile
	var lvl_ok: bool = p.level >= int(s.requiredLevel)
	var flag_ok: bool = not s.requiresFlag or StoryFlags.Has(s.requiredFlag)
	var money: bool = CurrencyManager.Instance != null and CurrencyManager.Instance.Has(CurrencyType.Gold, GetFinalPrice(int(s.price)))
	var stock_ok: bool = s.unlimitedStock or GetStock(s.item.itemID) > 0
	return lvl_ok and flag_ok and money and stock_ok

func BuyItem(s) -> bool:
	if s == null or s.item == null:
		return false
	var price := GetFinalPrice(int(s.price))
	if not CanBuy(s) or not CurrencyManager.Instance.Spend(CurrencyType.Gold, price):
		return false
	if not s.unlimitedStock and not TryReduceStock(s.item.itemID):
		CurrencyManager.Instance.Add(CurrencyType.Gold, price, false)
		return false
	InventoryManager.Instance.AddItem(s.item, 1)
	SaveSystem.SaveGame()
	return true

func CanSell(item, qty: int) -> bool:
	return item != null and int(item.itemType) != ItemType.Quest and InventoryManager.Instance.GetQuantity(item) >= qty

func SellItem(item, qty: int, ratio: float) -> bool:
	if not CanSell(item, qty):
		return false
	var price := U.RoundToInt(int(item.basePrice) * item.GetRarityMultiplier() * ratio) * qty
	InventoryManager.Instance.RemoveItem(item, qty)
	CurrencyManager.Instance.Add(CurrencyType.Gold, price)
	SaveSystem.SaveGame()
	return true

func GetFinalPrice(base: int) -> int:
	return U.RoundToInt(base * _priceMultiplier)

func GetStock(id) -> int:
	return stock.get(id, -1)

func TryReduceStock(id, amount := 1) -> bool:
	if not stock.has(id) or stock[id] < amount:
		return false
	stock[id] -= amount
	return true

func SetStock(id, amount: int) -> void:
	stock[id] = amount

func ApplyLoadedStock(ids, amounts) -> void:
	if ids == null or amounts == null:
		return
	stock.clear()
	for i in mini(ids.size(), amounts.size()):
		stock[str(ids[i])] = int(amounts[i])

func GetStockDataForSave() -> Array:
	var out := []
	for k in stock:
		out.append({"itemID": k, "amount": stock[k]})
	return out
