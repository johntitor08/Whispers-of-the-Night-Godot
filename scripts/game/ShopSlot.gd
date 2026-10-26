class_name ShopSlot
extends Mono

const PurchasedTextColor := Color(0.934, 0.897, 0.824)
var currentItem
var isPurchasing := false
var spawnedStatTexts: Array = []
var btnRect: Control
var originalSize := Vector2.ZERO
var originalText := ""
var originalColor := Color.WHITE
var itemIcon
var background
var rarityBadge
var itemNameText
var itemDescriptionText
var priceText
var stockText
var rarityText
var requirementText
var propertiesText
var statsContainer
var statTextPrefab
var statsParent
var maxStatLines := 2
var buyButton
var buyButtonText
var closeButton
var lockedOverlay
var normalColor := Color.BLACK
var lockedColor := Color.GRAY

static func BuyLabel() -> String:
	return Loc.T("BUY", "SATIN AL")

func Awake() -> void:
	if buyButton != null:
		buyButton.onClick.AddListener(OnBuyClicked)
	if closeButton != null:
		closeButton.onClick.AddListener(Close)

func OnEnable() -> void:
	if ProfileManager.Instance != null:
		U.on(ProfileManager.Instance.OnCurrencyChanged, RefreshVisuals)

func OnDisable() -> void:
	if ProfileManager.Instance != null:
		U.off(ProfileManager.Instance.OnCurrencyChanged, RefreshVisuals)
	if isPurchasing:
		ResetVisuals()

func _profile():
	return ProfileManager.Instance.profile if ProfileManager.Instance != null else null

func Setup(shopItem) -> void:
	if shopItem == null or ShopManager.Instance == null:
		return
	currentItem = shopItem
	isPurchasing = false
	if itemIcon != null:
		itemIcon.sprite = shopItem.item.icon
	if itemNameText != null:
		itemNameText.text = shopItem.item.DisplayName
	if itemDescriptionText != null:
		itemDescriptionText.text = shopItem.item.DisplayDescription
	if priceText != null:
		priceText.text = str(int(shopItem.price))
	GetProperties()
	UpdateStockDisplay()
	SetupRarity(shopItem.item)
	SetupRequirements(shopItem)
	SetupStats(shopItem.item)
	SetupProperties(shopItem.item)
	RefreshVisuals(_profile())
	ES.mark_layout_dirty()

func SetupRarity(item) -> void:
	if item == null:
		return
	if rarityText != null:
		rarityText.text = DisplayNames.RarityName(int(item.rarity))
	if rarityBadge != null:
		rarityBadge.color = item.GetRarityColor()

func SetupStats(item) -> void:
	for t in spawnedStatTexts:
		if is_instance_valid(t):
			U.Destroy(U.go_of(t))
	spawnedStatTexts.clear()
	if statsContainer == null:
		return
	var lines: Array[String] = []
	if item is EquipmentData:
		if item.damageBonus > 0:
			lines.append("%s: +%d" % [DisplayNames.Stat(StatType.Damage), item.damageBonus])
		if item.defenseBonus > 0:
			lines.append("%s: +%d" % [DisplayNames.Stat(StatType.Defense), item.defenseBonus])
		if item.primaryStatBonus > 0:
			lines.append("%s: +%d" % [DisplayNames.Stat(int(item.primaryStat)), item.primaryStatBonus])
		if item.secondaryStatBonus > 0:
			lines.append("%s: +%d" % [DisplayNames.Stat(int(item.secondaryStat)), item.secondaryStatBonus])
	elif item is StatModifierItem:
		var sign := "+" if item.modifyAmount >= 0 else ""
		var label: String = ("%s %s" % [Loc.T("Max", "Maks."), DisplayNames.Stat(int(item.targetStat))]) if item.modifyMaxStat else DisplayNames.Stat(int(item.targetStat))
		lines.append("%s: %s%s" % [label, sign, str(item.modifyAmount)])
	var count := mini(lines.size(), maxStatLines)
	if count == 0:
		U.SetActive(statsContainer, false)
		return
	U.SetActive(statsContainer, true)
	var par = statsParent if statsParent != null else statsContainer
	if statTextPrefab == null:
		return
	for i in count:
		var t = U.Instantiate(statTextPrefab, par)
		t.text = lines[i]
		spawnedStatTexts.append(t)

func GetProperties() -> void:
	if buyButton != null:
		btnRect = U.go_of(buyButton)
		originalSize = RT.size_delta(btnRect) if btnRect != null else Vector2.ZERO
	if buyButtonText != null:
		originalText = BuyLabel()
		originalColor = buyButtonText.color

func SetupProperties(item) -> void:
	if propertiesText == null:
		return
	if item is EquipmentData:
		var props := "%s: %s" % [Loc.T("Slot", "Yuva"), DisplayNames.Slot(int(item.slot))]
		if item.setData != null and not U.empty(item.setData.setName):
			props += "\n%s: %s" % [Loc.T("Set", "Set"), item.setData.DisplaySetName]
		U.SetActive(propertiesText, true)
		propertiesText.text = props
	else:
		U.SetActive(propertiesText, false)

func SetupRequirements(shopItem) -> void:
	if requirementText == null or ProfileManager.Instance == null or ShopManager.Instance == null:
		return
	var unmet: Array[String] = []
	var profile = ProfileManager.Instance.profile
	var req := int(shopItem.requiredLevel)
	if profile.level < req:
		unmet.append(Loc.T("Requires Level %d" % req, "Seviye %d gerekli" % req))
	if shopItem.requiresFlag and not StoryFlags.Has(shopItem.requiredFlag):
		unmet.append(Loc.T("Story Progress Required", "Hikâyede ilerleme gerekli"))
	var stockAmount := ShopManager.Instance.GetStock(shopItem.item.itemID)
	if not shopItem.unlimitedStock and stockAmount <= 0:
		unmet.append(Loc.T("Out of Stock", "Stokta yok"))
	if unmet.size() > 0:
		U.SetActive(requirementText, true)
		requirementText.text = "\n".join(unmet)
		requirementText.color = UIPalette.Bad
	else:
		U.SetActive(requirementText, false)

func UpdateVisuals(canBuy: bool) -> void:
	if buyButton == null or buyButtonText == null or background == null or ProfileManager.Instance == null:
		return
	buyButton.interactable = canBuy and not isPurchasing
	buyButtonText.text = BuyLabel() if canBuy else Loc.T("LOCKED", "KİLİTLİ")
	background.color = normalColor if canBuy else lockedColor
	if lockedOverlay != null:
		U.SetActive(lockedOverlay, not canBuy)

func UpdateStockDisplay() -> void:
	if currentItem == null or stockText == null or ShopManager.Instance == null:
		return
	var amount := ShopManager.Instance.GetStock(currentItem.item.itemID)
	var stock := Loc.T("Stock", "Stok")
	stockText.text = ("%s: ∞" % stock) if amount == -1 else ("%s: %d" % [stock, amount])

func RefreshVisuals(profile) -> void:
	if currentItem == null or ShopManager.Instance == null or profile == null:
		return
	var canBuy := ShopManager.Instance.CanBuy(currentItem)
	SetupRequirements(currentItem)
	UpdateVisuals(canBuy)

func ResetVisuals() -> void:
	isPurchasing = false
	if buyButtonText != null:
		buyButtonText.text = originalText
		buyButtonText.color = originalColor
	if btnRect != null:
		RT.set_size_delta(btnRect, originalSize)
	if currentItem != null:
		RefreshVisuals(_profile())

func Close() -> void:
	StopAllCoroutines()
	isPurchasing = false
	U.SetActive(gameObject, false)

func OnBuyClicked() -> void:
	if isPurchasing or ShopManager.Instance == null or currentItem == null:
		return
	if not ShopManager.Instance.BuyItem(currentItem):
		FailureFeedback()
		return
	isPurchasing = true
	PurchaseFeedback()

func PurchaseFeedback() -> void:
	var e := co()
	if not U.activeInHierarchy(gameObject) or buyButtonText == null or btnRect == null:
		isPurchasing = false
		return
	buyButtonText.text = Loc.T("Purchased!", "Satın Alındı!")
	buyButtonText.color = PurchasedTextColor
	buyButton.interactable = false
	await U.wait(0.5)
	if dead(e):
		return
	if not U.activeInHierarchy(gameObject):
		isPurchasing = false
		return
	RT.set_size_delta(btnRect, originalSize)
	buyButtonText.text = originalText
	buyButtonText.color = originalColor
	UpdateStockDisplay()
	RefreshVisuals(_profile())
	isPurchasing = false
	if ShopUI.Instance != null:
		ShopUI.Instance.RefreshShop()

func FailureFeedback() -> void:
	var e := co()
	if not U.activeInHierarchy(gameObject) or background == null:
		isPurchasing = false
		return
	var original: Color = background.color
	var flash := original.lerp(UIPalette.Bad, 0.45)
	for i in 3:
		background.color = flash
		await U.wait(0.1)
		if dead(e):
			return
		if not U.activeInHierarchy(gameObject):
			isPurchasing = false
			return
		background.color = original
		await U.wait(0.1)
		if dead(e):
			return
	isPurchasing = false
