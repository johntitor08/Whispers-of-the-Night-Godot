class_name InventoryUI
extends HotkeyPanelUI

static var Instance: InventoryUI
var slots: Array = []
var gameStarted := false
var panel
var content
var slotPrefab
var toggleKey := KEY_I

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func Update() -> void:
	if not gameStarted or PanelInputBlocked():
		return
	if U.GetKeyDown(toggleKey) and panel != null:
		if panel.visible:
			UIPanelAnimator.Hide(panel)
		else:
			UIPanelAnimator.Show(panel)

func OnEnable() -> void:
	TrySubscribe()
	InventoryManager.OnReady.AddListener(TrySubscribe)

func OnDisable() -> void:
	if InventoryManager.Instance != null:
		U.off(InventoryManager.Instance.OnInventoryChanged, Refresh)
	InventoryManager.OnReady.RemoveListener(TrySubscribe)

func TrySubscribe() -> void:
	if InventoryManager.Instance == null:
		return
	U.on(InventoryManager.Instance.OnInventoryChanged, Refresh)
	Refresh()

func OnGameStarted() -> void:
	gameStarted = true

func Refresh() -> void:
	var idx := 0
	for pair in InventoryManager.Instance.GetEquipmentInstances():
		EnsureSlot(idx).Setup(pair[0].baseData.itemID, pair[1], pair[0].upgradeLevel)
		idx += 1
	for pair in InventoryManager.Instance.GetNonEquipmentItems():
		EnsureSlot(idx).Setup(pair[0].itemID, pair[1], 0)
		idx += 1
	for i in range(idx, slots.size()):
		U.SetActive(slots[i], false)

func EnsureSlot(i: int):
	if i >= slots.size():
		slots.append(U.Instantiate(slotPrefab, content))
	U.SetActive(slots[i], true)
	return slots[i]
