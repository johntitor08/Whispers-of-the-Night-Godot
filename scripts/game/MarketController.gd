class_name MarketController
extends Mono

static var Instance: MarketController
var marketClosedPanel

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func Start() -> void:
	if TimePhaseManager.Instance == null:
		return
	U.on(TimePhaseManager.Instance.OnPhaseChanged, OnPhaseChanged)
	OnPhaseChanged(TimePhaseManager.Instance.currentPhase)

func OnDestroy() -> void:
	if TimePhaseManager.Instance != null:
		U.off(TimePhaseManager.Instance.OnPhaseChanged, OnPhaseChanged)

func OnPhaseChanged(p: int) -> void:
	var open := IsOpenDuring(p)
	if marketClosedPanel != null:
		U.SetActive(marketClosedPanel, not open)
	if ShopUI.Instance != null:
		ShopUI.Instance.UpdateMarketStatus()

func IsOpen() -> bool:
	if TimePhaseManager.Instance == null:
		return true
	return IsOpenDuring(TimePhaseManager.Instance.currentPhase)

static func IsOpenDuring(p: int) -> bool:
	return p != TimePhase.Night
