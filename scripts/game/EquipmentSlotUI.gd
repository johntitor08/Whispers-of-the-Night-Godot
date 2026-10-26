class_name EquipmentSlotUI
extends Mono

signal OnItemClicked(inst)
signal OnDetailClicked(inst)
var iconImage
var backgroundImage
var slotNameText
var upgradeBadgeText
var emptyIndicator
var slotButton
var emptyColor := Color(0.3, 0.3, 0.3, 0.5)
var emptySprite
var commonSprite
var rareSprite
var epicSprite
var legendarySprite
var godlySprite
var slotType := 0
var currentInstance
var iconButton

func Awake() -> void:
	if slotButton != null:
		slotButton.onClick.AddListener(ShowDetailPanel)
	if iconImage != null:
		iconButton = U.GetComponent(iconImage, UButton)
		if iconButton != null:
			iconButton.onClick.AddListener(ShowEquipmentPanel)

func OnEnable() -> void:
	if EquipmentManager.Instance != null:
		U.on(EquipmentManager.Instance.OnEquipmentChanged, Refresh)

func OnDisable() -> void:
	if EquipmentManager.Instance != null:
		U.off(EquipmentManager.Instance.OnEquipmentChanged, Refresh)

func Setup(s: int) -> void:
	slotType = s
	if slotNameText != null:
		slotNameText.text = DisplayNames.Slot(s)
	Refresh()

func Refresh() -> void:
	if EquipmentManager.Instance == null:
		return
	currentInstance = EquipmentManager.Instance.GetEquipped(slotType)
	if currentInstance != null:
		ShowEquipped(currentInstance)
	else:
		ShowEmpty()

func ShowEquipped(inst) -> void:
	var data = inst.baseData
	if iconImage != null:
		iconImage.sprite = data.icon
		iconImage.color = Color.WHITE
		iconImage.enabled = true
	if backgroundImage != null:
		var s = [commonSprite, rareSprite, epicSprite, legendarySprite, godlySprite][int(data.rarity)] if int(data.rarity) < 5 else null
		if s != null:
			backgroundImage.sprite = s
			backgroundImage.color = Color.WHITE
		else:
			backgroundImage.sprite = null
			var c: Color = data.GetRarityColor()
			c.a = 0.7
			backgroundImage.color = c
	if upgradeBadgeText != null:
		U.SetActive(upgradeBadgeText, inst.upgradeLevel > 0)
		upgradeBadgeText.text = "+%d" % inst.upgradeLevel
	if emptyIndicator != null:
		U.SetActive(emptyIndicator, false)
	if slotButton != null:
		slotButton.interactable = true
	if iconButton != null:
		iconButton.interactable = true

func ShowEmpty() -> void:
	if iconImage != null:
		iconImage.sprite = null
		iconImage.color = emptyColor
		iconImage.enabled = false
	if backgroundImage != null:
		if emptySprite != null:
			backgroundImage.sprite = emptySprite
			backgroundImage.color = Color.WHITE
		else:
			backgroundImage.sprite = null
			backgroundImage.color = emptyColor
	if upgradeBadgeText != null:
		U.SetActive(upgradeBadgeText, false)
	if emptyIndicator != null:
		U.SetActive(emptyIndicator, true)
	if slotButton != null:
		slotButton.interactable = false
	if iconButton != null:
		iconButton.interactable = false

func ShowEquipmentPanel() -> void:
	if currentInstance == null:
		return
	if EquipmentUI.Instance != null:
		EquipmentUI.Instance.OpenItemPanel(currentInstance)
	OnItemClicked.emit(currentInstance)

func ShowDetailPanel() -> void:
	if currentInstance == null:
		return
	if EquipmentUI.Instance != null:
		EquipmentUI.Instance.OpenDetailPanel(currentInstance)
	OnDetailClicked.emit(currentInstance)

func GetEquippedItem():
	return currentInstance.baseData if currentInstance != null else null

func GetEquippedInstance():
	return currentInstance

func GetSlotType() -> int:
	return slotType
