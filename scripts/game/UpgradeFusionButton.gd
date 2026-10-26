class_name UpgradeFusionButton
extends Mono

var upgradeButton
var upgradeButtonText
var watchedItem

func Awake() -> void:
	if upgradeButton != null:
		upgradeButton.onClick.AddListener(OnUpgradeClicked)

func OnEnable() -> void:
	if EquipmentManager.Instance != null:
		U.on(EquipmentManager.Instance.OnEquipmentChanged, Refresh)
	if InventoryManager.Instance != null:
		U.on(InventoryManager.Instance.OnInventoryChanged, Refresh)

func OnDisable() -> void:
	if EquipmentManager.Instance != null:
		U.off(EquipmentManager.Instance.OnEquipmentChanged, Refresh)
	if InventoryManager.Instance != null:
		U.off(InventoryManager.Instance.OnInventoryChanged, Refresh)

func SetItem(item) -> void:
	watchedItem = item
	Refresh()

func Refresh() -> void:
	if upgradeButton == null:
		return
	if watchedItem == null:
		U.SetActive(upgradeButton, false)
		return
	var fm = FusionManager.Instance
	var show: bool = fm != null and fm.OwnsUpgradeable(watchedItem)
	U.SetActive(upgradeButton, show)
	if not show:
		return
	upgradeButton.interactable = fm.CanUpgradeFuse(watchedItem)
	if upgradeButtonText == null:
		return
	var best := 0
	var em = EquipmentManager.Instance
	if em != null:
		var e = em.GetEquipped(int(watchedItem.slot))
		if e != null and e.baseData.itemID == watchedItem.itemID:
			best = maxi(best, e.upgradeLevel)
	if InventoryManager.Instance != null:
		for pair in InventoryManager.Instance.GetEquipmentInstances():
			if pair[0].baseData.itemID == watchedItem.itemID:
				best = maxi(best, pair[0].upgradeLevel)
	var cost: Dictionary = fm.GetUpgradeCost(watchedItem, best)
	var mat := (" + %d %s" % [cost.materialQty, cost.material.DisplayName]) if cost.material != null else ""
	upgradeButtonText.text = "%s +%d→+%d  (%dg%s)" % [Loc.T("Upgrade", "Yükselt"), best, best + 1, cost.gold, mat]

func OnUpgradeClicked() -> void:
	if watchedItem == null or FusionManager.Instance == null:
		return
	var r = FusionManager.Instance.UpgradeFuse(watchedItem)
	if r != null and ItemDetailPanel.Instance != null:
		ItemDetailPanel.Instance.ShowItemDetail(r.baseData, -1, r.upgradeLevel)
	Refresh()
