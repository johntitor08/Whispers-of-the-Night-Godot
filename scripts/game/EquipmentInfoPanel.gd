class_name EquipmentInfoPanel
extends Mono

static var Instance: EquipmentInfoPanel
var currentInstance
var panel
var iconImage
var nameText
var descriptionText
var statsText
var requirementsText
var comparisonText
var rarityBackground
var equipButton
var unequipButton
var closeButton

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)
	if panel != null:
		U.SetActive(panel, false)
	FitToBox(statsText)
	FitToBox(comparisonText)

static func FitToBox(t) -> void:
	if t == null or t.enableAutoSizing:
		return
	t.fontSizeMax = t._fontSize
	t.fontSizeMin = minf(16.0, t._fontSize)
	t.enableAutoSizing = true
	t.overflowMode = 3

func Start() -> void:
	for pair in [[equipButton, Equip], [unequipButton, Unequip], [closeButton, Close]]:
		if pair[0] != null:
			pair[0].onClick.RemoveAllListeners()
			pair[0].onClick.AddListener(pair[1])

func OnEnable() -> void:
	if InventoryManager.Instance != null:
		U.on(InventoryManager.Instance.OnInventoryChanged, OnDataChanged)
	if EquipmentManager.Instance != null:
		U.on(EquipmentManager.Instance.OnEquipmentChanged, OnDataChanged)
	if currentInstance != null:
		ShowPanel(currentInstance)

func OnDisable() -> void:
	if InventoryManager.Instance != null:
		U.off(InventoryManager.Instance.OnInventoryChanged, OnDataChanged)
	if EquipmentManager.Instance != null:
		U.off(EquipmentManager.Instance.OnEquipmentChanged, OnDataChanged)

func OnDataChanged() -> void:
	if currentInstance != null and panel != null and panel.visible:
		ShowPanel(currentInstance)

func ShowPanel(inst) -> void:
	if inst is EquipmentData:
		var live = EquipmentManager.Instance.GetEquipped(int(inst.slot)) if EquipmentManager.Instance != null else null
		inst = live if live != null and live.baseData.itemID == inst.itemID else EquipmentInstance.new(inst, 0)
	if inst == null or inst.baseData == null or EquipmentManager.Instance == null:
		return
	currentInstance = inst
	UIPanelAnimator.Show(panel)
	DisplayEquipment(inst)
	var si = EquipmentManager.Instance.GetEquipped(int(inst.baseData.slot))
	var eq: bool = si != null and si.baseData.itemID == inst.baseData.itemID and si.upgradeLevel == inst.upgradeLevel
	if equipButton != null:
		U.SetActive(equipButton, not eq)
		if not eq:
			equipButton.interactable = EquipmentManager.Instance.CanEquip(inst)
	if unequipButton != null:
		U.SetActive(unequipButton, eq)
	DisplayRequirements(inst.baseData)
	if eq:
		DisplayDescriptionInComparison(inst.baseData)
	else:
		DisplayComparison(inst)

func DisplayEquipment(inst) -> void:
	var d = inst.baseData
	if iconImage != null:
		iconImage.sprite = d.icon
	if nameText != null:
		nameText.text = inst.GetDisplayName()
	if descriptionText != null:
		descriptionText.text = d.DisplayDescription
	if statsText != null:
		statsText.text = inst.GetStatsDescription()
	if rarityBackground != null:
		var c: Color = d.GetRarityColor()
		c.a = 0.85
		rarityBackground.color = c

func DisplayRequirements(d) -> void:
	if requirementsText == null:
		return
	var req := Loc.T("Level %d Required" % int(d.requiredLevel), "Seviye %d gerekli" % int(d.requiredLevel))
	if int(d.requiredStatValue) > 0:
		var sn := DisplayNames.Stat(int(d.requiredStat))
		req += "\n" + Loc.T("%s %d Required" % [sn, int(d.requiredStatValue)], "%s %d gerekli" % [sn, int(d.requiredStatValue)])
	var ml: bool = ProfileManager.Instance == null or ProfileManager.Instance.profile.level >= int(d.requiredLevel)
	var ms: bool = int(d.requiredStatValue) <= 0 or PlayerStats.Instance == null or PlayerStats.Instance.Get(int(d.requiredStat)) >= int(d.requiredStatValue)
	requirementsText.text = req
	requirementsText.color = UIPalette.Good if ml and ms else UIPalette.Bad
	U.SetActive(requirementsText, true)

func DisplayComparison(incoming) -> void:
	if comparisonText == null:
		return
	U.SetActive(comparisonText, true)
	var cur = EquipmentManager.Instance.GetEquipped(int(incoming.baseData.slot))
	if cur == null:
		comparisonText.text = "<color=%s>%s</color>" % [UIPalette.Hex(UIPalette.Muted), Loc.T("No item equipped in this slot", "Bu yuvada kuşanılmış eşya yok")]
		return
	var text := "<b>%s</b>\n" % cur.GetDisplayName()
	var stats := []
	for t in cur.GetStatTotals():
		if not stats.has(t[0]):
			stats.append(t[0])
	for t in incoming.GetStatTotals():
		if not stats.has(t[0]):
			stats.append(t[0])
	for s in stats:
		text += CompareValue(DisplayNames.Stat(s), cur.GetStatTotal(s), incoming.GetStatTotal(s))
	comparisonText.text = text

func DisplayDescriptionInComparison(d) -> void:
	if comparisonText == null:
		return
	var desc: String = d.DisplayDescription
	U.SetActive(comparisonText, desc != "")
	comparisonText.text = "<i><color=%s>%s</color></i>" % [UIPalette.Hex(UIPalette.Muted), desc]

static func CompareValue(n: String, cur: int, nv: int) -> String:
	if cur == 0 and nv == 0:
		return ""
	var diff := nv - cur
	var col := UIPalette.Hex(UIPalette.Good if diff > 0 else (UIPalette.Bad if diff < 0 else UIPalette.Cream))
	var arrow := "↑" if diff > 0 else ("↓" if diff < 0 else "=")
	return "%s: %d → <color=%s>%d %s %d</color>\n" % [n, cur, col, nv, arrow, absi(diff)]

func Equip() -> void:
	if currentInstance == null or EquipmentManager.Instance == null or not EquipmentManager.Instance.Equip(currentInstance):
		return
	Close()

func Unequip() -> void:
	if currentInstance == null or EquipmentManager.Instance == null:
		return
	EquipmentManager.Instance.Unequip(int(currentInstance.baseData.slot), true)
	Close()

func Close() -> void:
	UIPanelAnimator.Hide(panel)
	currentInstance = null
