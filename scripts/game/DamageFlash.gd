class_name DamageFlash
extends Mono

var _statsTarget
var subscribedTarget
var isSubscribed := false
var flashImage
var damageColor := Color(1, 0, 0, 1)
var healColor := Color(0, 1, 0, 1)
var flashDuration := 0.2
var enableShake := false
var shakeTarget
var shakeMagnitude := 5.0
var shakeDuration := 0.1
var healthBarFill
var originalPosition := Vector2.ZERO
var _flash_gen := 0

var StatsTarget:
	get:
		return _statsTarget
	set(v):
		if _statsTarget != null:
			U.off(_statsTarget.OnStatChanged, HandleStatChanged)
		_statsTarget = v
		isSubscribed = false
		TrySubscribe()

func Awake() -> void:
	if _statsTarget == null:
		var local = GetComponentInParent(StatsBase)
		_statsTarget = local if local != null else PlayerStats.Instance
	if flashImage != null:
		flashImage.color = Color.WHITE
	if shakeTarget == null and flashImage != null:
		shakeTarget = flashImage
	if shakeTarget != null:
		originalPosition = shakeTarget.anchoredPosition

func OnEnable() -> void:
	TrySubscribe()

func OnDisable() -> void:
	if isSubscribed and subscribedTarget != null:
		U.off(subscribedTarget.OnStatChanged, HandleStatChanged)
		isSubscribed = false
		subscribedTarget = null
	_flash_gen += 1
	if flashImage != null:
		flashImage.color = Color.WHITE

func TrySubscribe() -> void:
	if _statsTarget == null:
		var local = GetComponentInParent(StatsBase)
		_statsTarget = local if local != null else PlayerStats.Instance
	if subscribedTarget != null and subscribedTarget != _statsTarget:
		U.off(subscribedTarget.OnStatChanged, HandleStatChanged)
		isSubscribed = false
		subscribedTarget = null
	if _statsTarget != null and not isSubscribed:
		U.on(_statsTarget.OnStatChanged, HandleStatChanged)
		isSubscribed = true
		subscribedTarget = _statsTarget
		if healthBarFill != null:
			healthBarFill.fillAmount = clampf(float(_statsTarget.Get(StatType.Health)) / maxi(1, _statsTarget.Get(StatType.MaxHealth)), 0.0, 1.0)

func HandleStatChanged(type: int, old_v: int, new_v: int) -> void:
	if type != StatType.Health:
		return
	var delta := new_v - old_v
	if delta == 0:
		return
	Flash(damageColor if delta < 0 else healColor)
	if enableShake and delta < 0:
		Shake()
	if healthBarFill != null:
		healthBarFill.fillAmount = clampf(float(new_v) / maxi(1, _statsTarget.Get(StatType.MaxHealth)), 0.0, 1.0)

func Flash(c: Color) -> void:
	if flashImage == null:
		return
	_flash_gen += 1
	var g := _flash_gen
	var e := co()
	flashImage.color = Color.WHITE
	await U.wait(0.05)
	var t := 0.0
	while t < flashDuration:
		if dead(e) or g != _flash_gen:
			return
		t += U.deltaTime
		var cc := Color.WHITE.lerp(c, clampf(t / flashDuration, 0.0, 1.0))
		cc.a = 1.0
		flashImage.color = cc
		await U.frame()
	if g == _flash_gen and not dead(e):
		flashImage.color = Color.WHITE

func Shake() -> void:
	if shakeTarget == null:
		return
	var e := co()
	var t := 0.0
	var start := originalPosition
	while t < shakeDuration:
		if dead(e):
			return
		t += U.deltaTime
		var damp := 1.0 - t / shakeDuration
		var x := sin(t * 40.0) * shakeMagnitude * damp * U.rangef(0.8, 1.2)
		var y := sin(t * 50.0) * shakeMagnitude * damp * U.rangef(0.8, 1.2)
		shakeTarget.anchoredPosition = start + Vector2(x, y)
		await U.frame()
	shakeTarget.anchoredPosition = start

func TriggerFlash(c: Color) -> void:
	Flash(c)
