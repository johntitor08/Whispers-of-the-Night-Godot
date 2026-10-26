class_name SellSlot
extends Mono

var icon
var nameText
var descText
var quantityText
var priceText
var rarityBorder
var rarityText
var sellButton
var item
var equipData
var upgradeLevel := 0
var quantity := 0
var sellRatio := 0.0
var isEquipment := false

func Setup(newItem, qty: int, ratio: float) -> void:
	item = newItem
	equipData = null
	upgradeLevel = 0
	quantity = qty
	sellRatio = ratio
	isEquipment = false
	ApplyVisuals()

func SetupEquipment(data, lvl: int, qty: int, ratio: float) -> void:
	item = data
	equipData = data
	upgradeLevel = lvl
	quantity = qty
	sellRatio = ratio
	isEquipment = true
	ApplyVisuals()

func _unit_price() -> int:
	return U.RoundToInt(int(item.basePrice) * item.GetRarityMultiplier() * sellRatio)

func ApplyVisuals() -> void:
	if item == null:
		return
	if icon != null:
		icon.sprite = item.icon
		icon.enabled = item.icon != null
	if nameText != null:
		nameText.text = ("%s +%d" % [item.DisplayName, upgradeLevel]) if isEquipment and upgradeLevel > 0 else item.DisplayName
	if descText != null:
		descText.text = item.DisplayDescription
	if quantityText != null:
		quantityText.text = "x%d" % quantity
	if priceText != null:
		priceText.text = str(_unit_price())
	SetupRarity(item)
	if sellButton != null:
		sellButton.onClick.RemoveAllListeners()
		sellButton.onClick.AddListener(SellOne)
		RefreshButton()

func SetupRarity(it) -> void:
	if it == null:
		return
	if rarityText != null:
		rarityText.text = DisplayNames.RarityName(int(it.rarity))
	if rarityBorder != null:
		rarityBorder.color = it.GetRarityColor()

func RefreshButton() -> void:
	if sellButton == null:
		return
	sellButton.interactable = GetCurrentQuantity() > 0

func GetCurrentQuantity() -> int:
	if InventoryManager.Instance == null:
		return 0
	if isEquipment and equipData != null:
		return InventoryManager.Instance.GetUpgradedQuantity(equipData, upgradeLevel)
	return InventoryManager.Instance.GetQuantity(item) if item != null else 0

func SellOne() -> void:
	if item == null or ShopManager.Instance == null:
		return
	var sold := false
	if isEquipment and equipData != null:
		if InventoryManager.Instance.GetUpgradedQuantity(equipData, upgradeLevel) <= 0:
			return
		var price := _unit_price()
		InventoryManager.Instance.RemoveUpgradedItem(equipData, upgradeLevel, 1)
		if CurrencyManager.Instance != null:
			CurrencyManager.Instance.Add(CurrencyType.Gold, price)
		SaveSystem.SaveGame()
		sold = true
	else:
		sold = ShopManager.Instance.SellItem(item, 1, sellRatio)
	if not sold:
		return
	quantity = GetCurrentQuantity()
	if quantityText != null:
		quantityText.text = "x%d" % quantity
	RefreshButton()
	if SellUI.Instance != null:
		SellUI.Instance.Refresh()
