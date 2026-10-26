class_name EquipmentUI
extends HotkeyPanelUI

static var Instance: EquipmentUI
var slotUIMap: Dictionary = {}
var setBonusTexts: Array = []
var gameStarted := false
var equipmentPanel
var equipmentInfoPanel
var weaponSlot
var armorSlot
var helmetSlot
var accessorySlot
var shieldSlot
var bootsSlot
var totalDamageText
var totalDefenseText
var setBonusesParent
var setBonusTextPrefab
var toggleKey := KEY_E

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)

func Start() -> void:
	if equipmentPanel != null:
		U.SetActive(equipmentPanel, false)
	InitializeSlots()
	if EquipmentManager.Instance != null:
		U.on(EquipmentManager.Instance.OnEquipmentChanged, RefreshUI)
	else:
		EquipmentManager.OnReady.AddListener(OnEquipmentManagerReady)
	if CombatManager.Instance != null:
		U.on(CombatManager.Instance.OnCombatStateChanged, RefreshCombatStats)
	RefreshUI()

func Update() -> void:
	if not gameStarted or PanelInputBlocked():
		return
	if U.GetKeyDown(toggleKey):
		TogglePanel()

func OnDestroy() -> void:
	EquipmentManager.OnReady.RemoveListener(OnEquipmentManagerReady)
	if EquipmentManager.Instance != null:
		U.off(EquipmentManager.Instance.OnEquipmentChanged, RefreshUI)
	if CombatManager.Instance != null:
		U.off(CombatManager.Instance.OnCombatStateChanged, RefreshCombatStats)

func OnEquipmentManagerReady() -> void:
	EquipmentManager.OnReady.RemoveListener(OnEquipmentManagerReady)
	U.on(EquipmentManager.Instance.OnEquipmentChanged, RefreshUI)
	RefreshUI()

func OnGameStarted() -> void:
	gameStarted = true

func InitializeSlots() -> void:
	slotUIMap = {EquipmentSlot.Weapon: weaponSlot, EquipmentSlot.Armor: armorSlot, EquipmentSlot.Helmet: helmetSlot, EquipmentSlot.Accessory: accessorySlot, EquipmentSlot.Shield: shieldSlot, EquipmentSlot.Boots: bootsSlot}
	for s in slotUIMap:
		if slotUIMap[s] != null:
			slotUIMap[s].Setup(s)

func TogglePanel() -> void:
	if equipmentPanel == null:
		return
	var ns: bool = not equipmentPanel.visible
	U.SetActive(equipmentPanel, ns)
	if ns:
		RefreshUI()

func ShowPanel() -> void:
	if equipmentPanel != null:
		U.SetActive(equipmentPanel, true)
	RefreshUI()

func HidePanel() -> void:
	if equipmentPanel != null:
		U.SetActive(equipmentPanel, false)

func IsPanelVisible() -> bool:
	return equipmentPanel != null and equipmentPanel.visible

func OpenItemPanel(inst) -> void:
	if inst is EquipmentData:
		inst = EquipmentInstance.new(inst)
	if equipmentInfoPanel == null or inst == null:
		return
	U.SetActive(equipmentInfoPanel, true)
	EquipmentInfoPanel.Instance.ShowPanel(inst)

func OpenDetailPanel(inst) -> void:
	OpenItemPanel(inst)

func RefreshUI() -> void:
	if EquipmentManager.Instance == null:
		return
	for ui in slotUIMap.values():
		if ui != null:
			ui.Refresh()
	RefreshStats()
	RefreshSetBonuses()

func RefreshCombatStats() -> void:
	if equipmentPanel != null and not equipmentPanel.visible:
		return
	RefreshStats()
	RefreshSetBonuses()

func RefreshStats() -> void:
	if EquipmentManager.Instance == null:
		return
	if totalDamageText != null:
		var totals := []
		for slot in 6:
			var inst = EquipmentManager.Instance.GetEquipped(slot)
			if inst == null or inst.baseData == null:
				continue
			for t in inst.GetStatTotals():
				var found := false
				for x in totals:
					if x[0] == t[0]:
						x[1] += t[1]
						found = true
				if not found:
					totals.append([t[0], t[1]])
		var text := "<b><color=%s>%s</color></b>\n" % [UIPalette.Hex(UIPalette.Gold), Loc.T("Gear Totals", "Ekipman Toplamı")]
		if totals.is_empty():
			text += "\n<color=%s>%s</color>" % [UIPalette.Hex(UIPalette.Muted), Loc.T("Nothing equipped", "Kuşanılmış eşya yok")]
		for t in totals:
			text += "\n%s: +%d" % [DisplayNames.Stat(t[0]), t[1]]
		totalDamageText.text = text
	if totalDefenseText != null:
		U.SetActive(totalDefenseText, false)

func RefreshSetBonuses() -> void:
	if setBonusesParent == null or setBonusTextPrefab == null or EquipmentManager.Instance == null:
		return
	var bonuses := ["<b><color=%s>%s</color></b>" % [UIPalette.Hex(UIPalette.Gold), Loc.T("Set Bonuses", "Set Bonusları")]]
	var active: Array = EquipmentManager.Instance.GetActiveSetBonusDescriptions()
	if active.is_empty():
		bonuses.append("<color=%s>%s</color>" % [UIPalette.Hex(UIPalette.Muted), Loc.T("No set bonuses active", "Etkin set bonusu yok")])
	else:
		bonuses.append_array(active)
	while setBonusTexts.size() < bonuses.size():
		var t = U.Instantiate(setBonusTextPrefab, setBonusesParent)
		t.horizontalAlignment = UText.H_CENTER
		setBonusTexts.append(t)
	for i in setBonusTexts.size():
		if i < bonuses.size():
			setBonusTexts[i].text = bonuses[i]
			U.SetActive(setBonusTexts[i], true)
		else:
			U.SetActive(setBonusTexts[i], false)

func GetSlotUI(s: int):
	return slotUIMap.get(s)
