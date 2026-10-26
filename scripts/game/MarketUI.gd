class_name MarketUI
extends HotkeyPanelUI

static var Instance: MarketUI
var marketPanel
var gameStarted := false
var toggleKey := KEY_S

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)

func Update() -> void:
	if not gameStarted or SaveSystem.IsLoading or PanelInputBlocked():
		return
	if U.GetKeyDown(toggleKey) and marketPanel != null:
		if U.activeSelf(marketPanel):
			CloseAll()
		else:
			OpenMarket()

func OnGameStarted() -> void:
	gameStarted = true

func OpenMarket() -> void:
	UIPanelAnimator.Show(marketPanel)
	OpenShop()

func OpenShop() -> void:
	if MarketController.Instance != null and not MarketController.Instance.IsOpen():
		if ShopUI.Instance != null:
			ShopUI.Instance.ShowMarketClosed()
		return
	if SellUI.Instance != null:
		SellUI.Instance.Close()
	if ShopUI.Instance != null:
		ShopUI.Instance.Open()

func OpenSell() -> void:
	if MarketController.Instance != null and not MarketController.Instance.IsOpen():
		if ShopUI.Instance != null:
			ShopUI.Instance.ShowMarketClosed()
		return
	if ShopUI.Instance != null:
		ShopUI.Instance.Close()
	if SellUI.Instance != null:
		SellUI.Instance.Open()

func CloseAll() -> void:
	if ShopUI.Instance != null:
		ShopUI.Instance.Close()
	if SellUI.Instance != null:
		SellUI.Instance.Close()
	UIPanelAnimator.Hide(marketPanel)
