class_name UIPanelAnimator
extends Mono

var duration := 0.15
var animateScale := true
var startScale := 0.95
var _cg
var _gen := 0
var _closeRequested := false

func Awake() -> void:
	_cg = GetComponent(UCanvasGroup)

func OnEnable() -> void:
	PlayOpen()

func OnDisable() -> void:
	_gen += 1
	_closeRequested = false
	if _cg != null:
		_cg.alpha = 1.0
		_cg.blocksRaycasts = false
		_cg.interactable = false
	gameObject.scale = Vector2.ONE

func PlayOpen() -> void:
	if _cg == null:
		_cg = GetComponent(UCanvasGroup)
	_closeRequested = false
	if not U.activeInHierarchy(gameObject) or _cg == null:
		return
	_gen += 1
	_cg.alpha = 0.0
	_cg.blocksRaycasts = true
	_cg.interactable = true
	Animate(0.0, 1.0, true, null, _gen)

func PlayClose(on_complete) -> void:
	if _cg == null:
		_cg = GetComponent(UCanvasGroup)
	if not U.activeInHierarchy(gameObject) or _cg == null:
		if on_complete is Callable:
			on_complete.call()
		return
	_closeRequested = true
	_gen += 1
	_cg.interactable = false
	Animate(_cg.alpha, 0.0, false, on_complete, _gen)

func Animate(from: float, to: float, opening: bool, on_complete, g: int) -> void:
	var go = gameObject
	var t := 0.0
	var dur := maxf(0.0001, duration)
	while t < dur:
		await U.frame()
		if g != _gen:
			return
		t += U.unscaledDeltaTime
		var k := clampf(t / dur, 0.0, 1.0)
		var eased := (1.0 - (1.0 - k) * (1.0 - k)) if opening else k * k
		_cg.alpha = lerpf(from, to, eased)
		if animateScale:
			var s := lerpf(startScale, 1.0, eased) if opening else lerpf(1.0, startScale, eased)
			go.scale = Vector2(s, s)
	if g != _gen:
		return
	go.scale = Vector2.ONE
	_cg.alpha = to
	_cg.interactable = opening
	_cg.blocksRaycasts = opening
	if on_complete is Callable and (opening or _closeRequested):
		on_complete.call()

static func Show(go) -> void:
	go = U.go_of(go)
	if go == null:
		return
	if not go.visible:
		U.SetActive(go, true)
		return
	var a = U.GetComponent(go, UIPanelAnimator)
	if a != null:
		a.PlayOpen()

static func Hide(go) -> void:
	go = U.go_of(go)
	if go == null or not go.visible:
		return
	var a = U.GetComponent(go, UIPanelAnimator)
	if a != null and U.activeInHierarchy(go):
		a.PlayClose(func(): if is_instance_valid(go): U.SetActive(go, false))
	else:
		U.SetActive(go, false)
