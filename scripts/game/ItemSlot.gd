class_name ItemSlot
extends Mono

var icon
var title
var quantityText
var rarityBorder
var upgradeLevelText
var upgradeButtonText
var upgradeButton
var tooltip
var currentItem
var currentUpgradeLevel := 0
var currentQuantity := 0

func Awake() -> void:
	if upgradeButton != null:
		upgradeButton.onClick.AddListener(OnUpgradeClicked)

func OnEnable() -> void:
	if InventoryManager.Instance != null:
		U.on(InventoryManager.Instance.OnInventoryChanged, RefreshUpgradeButton)
	if EquipmentManager.Instance != null:
		U.on(EquipmentManager.Instance.OnEquipmentChanged, RefreshUpgradeButton)

func OnDisable() -> void:
	if InventoryManager.Instance != null:
		U.off(InventoryManager.Instance.OnInventoryChanged, RefreshUpgradeButton)
	if EquipmentManager.Instance != null:
		U.off(EquipmentManager.Instance.OnEquipmentChanged, RefreshUpgradeButton)

func Setup(id, qty := 1, lvl := 0) -> void:
	currentItem = ItemDatabase.Instance.GetByID(id)
	if currentItem == null:
		Clear()
		return
	currentUpgradeLevel = lvl
	currentQuantity = qty
	icon.sprite = currentItem.icon
	icon.enabled = true
	title.text = ("%s <color=%s>+%d</color>" % [currentItem.DisplayName, UIPalette.Hex(UIPalette.Gold), lvl]) if lvl > 0 else currentItem.DisplayName
	var c: Color = currentItem.GetRarityColor()
	if rarityBorder != null:
		rarityBorder.color = c
	if title != null:
		title.color = c
	if currentItem.stackable and qty > 1:
		U.SetActive(quantityText, true)
		quantityText.text = "x%d" % qty
	else:
		U.SetActive(quantityText, false)
	if upgradeLevelText != null:
		U.SetActive(upgradeLevelText, lvl > 0)
		upgradeLevelText.text = "+%d" % lvl
	RefreshUpgradeButton()

func RefreshUpgradeButton() -> void:
	if upgradeButton == null or not (currentItem is EquipmentData):
		return
	var can: bool = FusionManager.Instance != null and FusionManager.Instance.CanUpgradeFuse(currentItem)
	U.SetActive(upgradeButton, can)
	if not can or upgradeButtonText == null:
		return
	var best := currentUpgradeLevel
	var em = EquipmentManager.Instance
	if em != null:
		var eq = em.GetEquipped(int(currentItem.slot))
		if eq != null and eq.baseData.itemID == currentItem.itemID:
			best = maxi(best, eq.upgradeLevel)
	if InventoryManager.Instance != null:
		for pair in InventoryManager.Instance.GetEquipmentInstances():
			if pair[0].baseData.itemID == currentItem.itemID:
				best = maxi(best, pair[0].upgradeLevel)
	upgradeButtonText.text = "+%d" % (best + 1)

func OnUpgradeClicked() -> void:
	if currentItem is EquipmentData and FusionManager.Instance != null:
		FusionManager.Instance.UpgradeFuse(currentItem)

func OnClick() -> void:
	if currentItem != null:
		ItemDetailPanel.Instance.ShowItemDetail(currentItem, currentQuantity, currentUpgradeLevel)

func OnPointerEnter(_e) -> void:
	if currentItem != null and tooltip != null:
		tooltip.Show(currentItem, currentUpgradeLevel)

func OnPointerExit(_e) -> void:
	if tooltip != null:
		tooltip.Hide()

func Clear() -> void:
	icon.sprite = null
	icon.enabled = false
	title.text = ""
	U.SetActive(quantityText, false)
	if upgradeLevelText != null:
		U.SetActive(upgradeLevelText, false)
	if upgradeButton != null:
		U.SetActive(upgradeButton, false)
	currentItem = null
	currentUpgradeLevel = 0
	currentQuantity = 0
