class_name UIHoverRegion
extends Mono

signal OnRegionClicked
var maxAlpha := 0.2
var fadeSpeed := 6.0
var currentAlpha := 0.0
var _fade_gen := 0
var pressedDuringDialogue := false
var isDialogueSubscribed := false
var hoverShape
var spriteShapeController
var hoverCollider

func Awake() -> void:
	SetAlpha(0.0)

func OnEnable() -> void:
	TrySubscribe()

func OnDisable() -> void:
	_fade_gen += 1
	if isDialogueSubscribed and DialogueManager.Instance != null:
		U.off(DialogueManager.Instance.OnDialogueStart, HandleDialogueStarted)
	isDialogueSubscribed = false

func TrySubscribe() -> void:
	var e := co()
	while DialogueManager.Instance == null:
		await U.frame()
		if dead(e):
			return
	if not isDialogueSubscribed:
		U.on(DialogueManager.Instance.OnDialogueStart, HandleDialogueStarted)
		isDialogueSubscribed = true

func OnPointerEnter(_e) -> void:
	if IsDialogueActive():
		return
	StartFade(1.0)

func OnPointerExit(_e) -> void:
	StartFade(0.0)

func OnPointerDown(_e) -> void:
	pressedDuringDialogue = IsDialogueActive() or IsSceneDark()

func OnPointerClick(_e) -> void:
	if IsDialogueActive() or IsSceneDark() or pressedDuringDialogue:
		return
	_fade_gen += 1
	currentAlpha = 0.0
	SetAlpha(0.0)
	if GameAudioManager.Instance != null and GetComponent(UIClickSound) != null:
		GameAudioManager.Instance.PlayUiClick()
	OnRegionClicked.emit()

func HandleDialogueStarted(_n) -> void:
	StartFade(0.0)

static func IsDialogueActive() -> bool:
	return DialogueManager.WorldClicksBlocked()

static func IsSceneDark() -> bool:
	return SceneEvent.Instance != null and SceneEvent.Instance.IsSceneDarkened

func StartFade(target: float) -> void:
	_fade_gen += 1
	FadeRoutine(target, _fade_gen)

func FadeRoutine(target: float, g: int) -> void:
	var e := co()
	while true:
		if g != _fade_gen or dead(e):
			return
		var dark := IsSceneDark()
		var fin := 0.0 if IsDialogueActive() or dark else target
		currentAlpha = U.MoveTowards(currentAlpha, fin, U.deltaTime * fadeSpeed)
		SetAlpha(currentAlpha)
		if is_equal_approx(currentAlpha, fin) and not (dark and target > 0.0):
			break
		await U.frame()

func SetAlpha(a: float) -> void:
	var go = gameObject
	if go is UImage and go.has_shape:
		var c: Color = go.shape_color
		c.a = a * maxAlpha
		go.shape_color = c
		go.queue_redraw()
