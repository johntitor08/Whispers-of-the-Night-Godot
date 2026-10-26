class_name CurrencyUI
extends Mono

static var Instance: CurrencyUI
var _anim_gen: Dictionary = {}
var displayDict: Dictionary = {}
var panel
var _subscribed := false
var gameStarted := false
var currencyDisplays: Array = []

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self
	for d in currencyDisplays:
		displayDict[int(d.get("type", 0))] = d

func Start() -> void:
	Subscribe()

func Update() -> void:
	if not gameStarted:
		return
	if U.GetKeyDown(KEY_C) and panel != null:
		if panel.visible:
			UIPanelAnimator.Hide(panel)
		else:
			UIPanelAnimator.Show(panel)

func OnEnable() -> void:
	if not _subscribed:
		Subscribe()

func OnDisable() -> void:
	Unsubscribe()

func OnDestroy() -> void:
	Unsubscribe()

func Subscribe() -> void:
	if CurrencyManager.Instance == null:
		return
	U.on(CurrencyManager.Instance.OnCurrencyChanged, OnCurrencyChanged)
	_subscribed = true
	RefreshAll()

func Unsubscribe() -> void:
	if CurrencyManager.Instance == null:
		return
	U.off(CurrencyManager.Instance.OnCurrencyChanged, OnCurrencyChanged)
	_subscribed = false

func OnGameStarted() -> void:
	gameStarted = true

func OnCurrencyChanged(t: int, old_a: int, new_a: int) -> void:
	UpdateDisplay(t, new_a)
	var d = displayDict.get(t)
	if d != null and d.get("animateOnChange", 1):
		_anim_gen[t] = _anim_gen.get(t, 0) + 1
		AnimateCountUp(d.get("amountText"), old_a, new_a, 0.5, t, _anim_gen[t])

func UpdateMultiple(amounts: Dictionary) -> void:
	for t in amounts:
		UpdateDisplay(t, amounts[t])

func UpdateDisplay(t: int, amount: int) -> void:
	var d = displayDict.get(t)
	if d == null:
		return
	if d.get("amountText") != null:
		d.amountText.text = FormatCurrency(amount)
	if d.get("icon") != null:
		var info = CurrencyManager.Instance.GetCurrencyInfo(t)
		if info != null and info.get("icon") != null:
			d.icon.sprite = info.icon

func AnimateCountUp(text, start: int, end: int, dur: float, t: int, g: int) -> void:
	if start == end or text == null:
		return
	var e := 0.0
	while e < dur:
		if _anim_gen.get(t) != g:
			return
		e += U.deltaTime
		text.text = FormatCurrency(U.RoundToInt(lerpf(start, end, clampf(e / dur, 0.0, 1.0))))
		await U.frame()
	text.text = FormatCurrency(end)

static func FormatCurrency(a: int) -> String:
	if a >= 1000000:
		return "%.1fM" % (a / 1000000.0)
	if a >= 1000:
		return "%.1fK" % (a / 1000.0)
	return str(a)

func RefreshAll() -> void:
	for t in displayDict:
		UpdateDisplay(t, CurrencyManager.Instance.Get(t))
