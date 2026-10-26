class_name ShopUI
extends Mono

static var Instance: ShopUI
var slots: Array = []
var shopPanel
var marketClosedPanel
var shopContent
var shopSlotPrefab
var currencyText
var shopTitleText
var marketStatusText
var closeButton
var refreshButton
var switchToSellButton
var shopScrollRect

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)

func Start() -> void:
	if CurrencyManager.Instance != null:
		U.on(CurrencyManager.Instance.OnCurrencyChanged, OnGoldChanged)
	if closeButton != null:
		closeButton.onClick.AddListener(CloseAll)
	if refreshButton != null:
		refreshButton.onClick.AddListener(Refresh)
	if switchToSellButton != null:
		switchToSellButton.onClick.AddListener(_go_sell)
	if shopPanel != null:
		U.SetActive(shopPanel, false)
	if marketClosedPanel != null:
		U.SetActive(marketClosedPanel, false)
	UpdateCurrency()
	UpdateMarketStatus()

func _go_sell() -> void:
	if MarketUI.Instance != null:
		MarketUI.Instance.OpenSell()

func OnDisable() -> void:
	if CurrencyManager.Instance != null:
		U.off(CurrencyManager.Instance.OnCurrencyChanged, OnGoldChanged)

func Open() -> void:
	SetClosedState(false)
	if shopPanel != null:
		UIPanelAnimator.Show(shopPanel)
		Refresh()
	UpdateMarketStatus()

func Close() -> void:
	UIPanelAnimator.Hide(shopPanel)
	UIPanelAnimator.Hide(marketClosedPanel)

func CloseAll() -> void:
	if MarketUI.Instance != null:
		MarketUI.Instance.CloseAll()

func ShowMarketClosed() -> void:
	SetClosedState(true)
	if shopPanel != null:
		UIPanelAnimator.Show(shopPanel)
	UIPanelAnimator.Show(marketClosedPanel)
	SetClosedMessage()
	UpdateMarketStatus()

func SetClosedMessage() -> void:
	if marketClosedPanel == null:
		return
	var muted := UIPalette.Hex(UIPalette.Muted)
	var en := "Market Closed\n<size=55%%><color=%s>The stalls open again in the morning.</color></size>" % muted
	var tr := "Pazar Kapalı\n<size=55%%><color=%s>Tezgâhlar sabah yeniden açılır.</color></size>" % muted
	var loc = U.GetComponentInChildren(marketClosedPanel, LocalizedText, true)
	if loc != null:
		loc.en = en
		loc.tr = tr
		loc.Apply()
		return
	var t = U.GetComponentInChildren(marketClosedPanel, UText, true)
	if t != null:
		t.text = Loc.T(en, tr)

func SetClosedState(closed: bool) -> void:
	if shopScrollRect != null:
		U.SetActive(shopScrollRect, not closed)
	if refreshButton != null:
		U.SetActive(refreshButton, not closed)
	if switchToSellButton != null:
		U.SetActive(switchToSellButton, not closed)
	if not closed and marketClosedPanel != null:
		U.SetActive(marketClosedPanel, false)

func Refresh() -> void:
	if ShopManager.Instance == null:
		return
	for s in slots:
		if is_instance_valid(s):
			U.SetActive(s, false)
	var idx := 0
	for it in ShopManager.Instance.shopItems:
		if idx >= slots.size():
			slots.append(U.Instantiate(shopSlotPrefab, shopContent))
		slots[idx].Setup(it)
		U.SetActive(slots[idx], true)
		idx += 1
	for i in range(idx, slots.size()):
		if is_instance_valid(slots[i]):
			U.SetActive(slots[i], false)
	ScrollToTop(shopScrollRect)
	UpdateCurrency()

func RefreshShop() -> void:
	Refresh()

func OnGoldChanged(t: int, _o: int, _n: int) -> void:
	if t == CurrencyType.Gold:
		UpdateCurrency()

func UpdateCurrency() -> void:
	if currencyText == null:
		return
	var gold: int = CurrencyManager.Instance.Get(CurrencyType.Gold) if CurrencyManager.Instance != null else 0
	currencyText.text = "%d %s" % [gold, Loc.T("Gold", "Altın")]

func UpdateMarketStatus() -> void:
	if marketStatusText == null:
		return
	var open: bool = MarketController.Instance == null or MarketController.Instance.IsOpen()
	marketStatusText.text = Loc.T("Market Open", "Pazar Açık") if open else Loc.T("Market Closed", "Pazar Kapalı")
	marketStatusText.color = UIPalette.Good if open else UIPalette.Bad

static func ScrollToTop(sr) -> void:
	if sr == null:
		return
	ES.rebuild_layout()
	sr.verticalNormalizedPosition = 1.0
