class_name ItemDetailPanel
extends Mono

static var Instance: ItemDetailPanel
var currentItem
var currentUpgradeLevel := 0
var isProcessingUse := false
var itemDetailPanel
var title
var icon
var quantityText
var description
var actionButton
var closeButton
var upgradeFusionButton

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func OnEnable() -> void:
	if InventoryManager.Instance != null:
		U.on(InventoryManager.Instance.OnInventoryChanged, RefreshQuantity)

func OnDisable() -> void:
	if InventoryManager.Instance != null:
		U.off(InventoryManager.Instance.OnInventoryChanged, RefreshQuantity)

func ShowItemDetail(item, qty: int, lvl := 0) -> void:
	currentItem = item
	currentUpgradeLevel = lvl
	isProcessingUse = false
	if actionButton != null:
		actionButton.interactable = false
	if title != null:
		title.text = item.DisplayName + ((" <color=%s>+%d</color>" % [UIPalette.Hex(UIPalette.Gold), lvl]) if lvl > 0 else "")
	if description != null:
		description.text = item.DisplayDescription
	if icon != null:
		icon.sprite = item.icon
	var q := ResolveQuantity(item, qty, lvl)
	if quantityText != null:
		quantityText.text = "%s: %d" % [Loc.T("Owned", "Sahip olunan"), q]
	if upgradeFusionButton != null:
		upgradeFusionButton.SetItem(item if item is EquipmentData else null)
	ConfigureButtons(item, q)
	UIPanelAnimator.Show(itemDetailPanel)

func RefreshPanel() -> void:
	if currentItem == null or itemDetailPanel == null or not itemDetailPanel.visible:
		return
	ShowItemDetail(currentItem, -1, currentUpgradeLevel)

func ResolveQuantity(item, qty: int, lvl: int) -> int:
	if qty >= 0:
		return qty
	if item is EquipmentData:
		return InventoryManager.Instance.GetUpgradedQuantity(item, lvl) if lvl > 0 else InventoryManager.Instance.GetQuantity(item)
	return InventoryManager.Instance.GetQuantity(item)

func ConfigureButtons(item, qty: int) -> void:
	if closeButton != null:
		closeButton.onClick.RemoveAllListeners()
		closeButton.onClick.AddListener(Close)
	if actionButton == null:
		return
	U.SetActive(actionButton, true)
	actionButton.onClick.RemoveAllListeners()
	if item.readable and not item.IsEquipment():
		SetActionButtonLabel("Read", "Oku")
		actionButton.interactable = true
		actionButton.onClick.AddListener(ReadItem)
	else:
		if item.IsEquipment():
			SetActionButtonLabel("Equip", "Kuşan")
		else:
			SetActionButtonLabel("Use", "Kullan")
		actionButton.interactable = CanUse(item) and qty > 0
		actionButton.onClick.AddListener(UseItem)

static func CanUse(item) -> bool:
	return item.IsEquipment() or bool(item.useable)

func SetActionButtonLabel(en: String, tr: String) -> void:
	if actionButton == null:
		return
	var loc = U.GetComponentInChildren(actionButton.gameObject, LocalizedText, true)
	if loc != null:
		loc.en = en
		loc.tr = tr
		loc.Apply()
		return
	var t = U.GetComponentInChildren(actionButton.gameObject, UText, true)
	if t != null:
		t.text = Loc.T(en, tr)

func ReadItem() -> void:
	if currentItem != null and ReadingPanel.Instance != null:
		ReadingPanel.Instance.Show(currentItem.DisplayName, currentItem.DisplayReadText, currentItem.icon)

func UseItem() -> void:
	if isProcessingUse or currentItem == null or not CanUse(currentItem):
		return
	isProcessingUse = true
	if actionButton != null:
		actionButton.interactable = false
	var item = currentItem
	if item.IsEquipment():
		if item is EquipmentData and EquipmentManager.Instance != null:
			EquipmentManager.Instance.Equip(EquipmentInstance.new(item, currentUpgradeLevel))
		RefreshQuantity()
		return
	if item.consumeOnUse and (InventoryManager.Instance == null or not InventoryManager.Instance.RemoveItem(item, 1)):
		isProcessingUse = false
		if actionButton != null:
			actionButton.interactable = true
		return
	if item is StatModifierItem:
		item.Use()
	if item is ConsumableBuffItem:
		item.Use()
	if not U.empty(item.questObjectiveOnUse) and QuestManager.Instance != null:
		QuestManager.Instance.NotifyObjectInteracted(item.questObjectiveOnUse, 1)
	if InventoryManager.Instance != null:
		InventoryManager.Instance.NotifyItemUsed(item)
	SaveSystem.SaveGame()
	RefreshQuantity()

func RefreshQuantity() -> void:
	if currentItem == null or InventoryManager.Instance == null:
		return
	var q := ResolveQuantity(currentItem, -1, currentUpgradeLevel)
	if quantityText != null:
		quantityText.text = "%s: %d" % [Loc.T("Owned", "Sahip olunan"), q]
	isProcessingUse = false
	if q <= 0:
		Close()
		return
	if actionButton != null and (currentItem.readable or CanUse(currentItem)):
		actionButton.interactable = true

func Close() -> void:
	if actionButton != null:
		actionButton.onClick.RemoveAllListeners()
		actionButton.interactable = false
	if upgradeFusionButton != null:
		upgradeFusionButton.SetItem(null)
	currentItem = null
	currentUpgradeLevel = 0
	isProcessingUse = false
	UIPanelAnimator.Hide(itemDetailPanel)
