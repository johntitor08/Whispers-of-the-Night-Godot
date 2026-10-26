class_name CurrencyNotificationUI
extends Mono

static var Instance: CurrencyNotificationUI
var notificationPool: Array = []
var activeNotifications: Array = []
var notificationPrefab
var notificationParent
var notificationDuration := 2.0
var moveSpeed := 50.0
var popScaleMultiplier := 1.2

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func Show(changes: Dictionary, delay_between := 0.1) -> void:
	var i := 0
	for t in changes:
		ShowWithDelay(t, changes[t], delay_between * i)
		i += 1

func ShowWithDelay(t: int, amount: int, delay: float) -> void:
	if delay > 0.0:
		await U.wait(delay)
	ShowSingle(t, amount)

func ShowSingle(t: int, amount: int) -> void:
	var n = GetNotification()
	if n is UText:
		var info = CurrencyManager.Instance.GetCurrencyInfo(t)
		var c: Color = info.displayColor if info != null else Color.WHITE
		n.text = "<color=#%s>%s%d %s</color>" % [c.to_html(false).to_upper(), "+" if amount >= 0 else "-", absi(amount), CurrencyType.name_of(t)]
	U.SetActive(n, true)
	n.scale = Vector2.ZERO
	activeNotifications.append(n)
	AnimateNotification(n)

func GetNotification():
	while not notificationPool.is_empty():
		var p = notificationPool.pop_front()
		if is_instance_valid(p):
			p.position = Vector2.ZERO
			p.anchoredPosition = Vector2.ZERO
			return p
	return U.Instantiate(notificationPrefab, notificationParent)

func AnimateNotification(n) -> void:
	var e := 0.0
	var start: Vector2 = n.anchoredPosition
	var sc: Color = n.color if n is UText else Color.WHITE
	while e < notificationDuration:
		if not is_instance_valid(n):
			return
		e += U.deltaTime
		var t := e / notificationDuration
		n.anchoredPosition = start + Vector2(0, moveSpeed * t)
		if n is UText:
			var c := sc
			c.a = 1.0 - t
			n.color = c
		var s := sin(t * PI) * popScaleMultiplier
		n.scale = Vector2(s, s)
		await U.frame()
	if not is_instance_valid(n):
		return
	U.SetActive(n, false)
	if n is UText:
		n.color = sc
	activeNotifications.erase(n)
	notificationPool.append(n)
