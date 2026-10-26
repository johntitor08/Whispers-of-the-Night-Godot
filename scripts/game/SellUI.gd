class_name SellUI
extends Mono

static var Instance: SellUI
var slots: Array = []
var sellPanel
var sellContent
var sellSlotPrefab
var currencyText
var titleText
var closeButton
var switchToShopButton
var sellScrollRect
var sellPriceRatio := 0.5

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)

func Start() -> void:
	if CurrencyManager.Instance != null:
		U.on(CurrencyManager.Instance.OnCurrencyChanged, OnGoldChanged)
	if closeButton != null:
		closeButton.onClick.AddListener(_close_all)
	if switchToShopButton != null:
		switchToShopButton.onClick.AddListener(_go_shop)
	if sellPanel != null:
		U.SetActive(sellPanel, false)
	UpdateCurrency()

func _close_all() -> void:
	if MarketUI.Instance != null:
		MarketUI.Instance.CloseAll()

func _go_shop() -> void:
	if MarketUI.Instance != null:
		MarketUI.Instance.OpenShop()

func OnDisable() -> void:
	if CurrencyManager.Instance != null:
		U.off(CurrencyManager.Instance.OnCurrencyChanged, OnGoldChanged)

func Open() -> void:
	if sellPanel != null:
		UIPanelAnimator.Show(sellPanel)
		Refresh()

func Close() -> void:
	UIPanelAnimator.Hide(sellPanel)

func Refresh() -> void:
	if InventoryManager.Instance == null or sellPanel == null:
		return
	var idx := 0
	for pair in InventoryManager.Instance.GetEquipmentInstances():
		EnsureSlot(idx)
		slots[idx].SetupEquipment(pair[0].baseData, pair[0].upgradeLevel, pair[1], sellPriceRatio)
		U.SetActive(slots[idx], true)
		idx += 1
	for pair in InventoryManager.Instance.GetNonEquipmentItems():
		if int(pair[0].itemType) == ItemType.Quest:
			continue
		EnsureSlot(idx)
		slots[idx].Setup(pair[0], pair[1], sellPriceRatio)
		U.SetActive(slots[idx], true)
		idx += 1
	for i in range(idx, slots.size()):
		if is_instance_valid(slots[i]):
			U.SetActive(slots[i], false)
	ShopUI.ScrollToTop(sellScrollRect)
	UpdateCurrency()

func EnsureSlot(i: int) -> void:
	if i >= slots.size():
		slots.append(U.Instantiate(sellSlotPrefab, sellContent))

func OnGoldChanged(t: int, _o: int, _n: int) -> void:
	if t == CurrencyType.Gold:
		UpdateCurrency()

func UpdateCurrency() -> void:
	if currencyText == null:
		return
	var gold: int = CurrencyManager.Instance.Get(CurrencyType.Gold) if CurrencyManager.Instance != null else 0
	currencyText.text = "%d %s" % [gold, Loc.T("Gold", "Altın")]
