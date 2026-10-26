class_name ClickableIcon
extends Mono

var enableHoverEffect := true
var enableClickEffect := true
var enablePulseEffect := false
var hoverScale := 1.15
var hoverDuration := 0.2
var hoverTintColor := Color(1, 1, 0.8)
var clickScale := 0.9
var clickDuration := 0.1
var pulseSpeed := 2.0
var pulseAmount := 0.1
var hoverSound
var clickSound
var originalScale := Vector2.ONE
var iconImage
var originalColor := Color.WHITE
var isHovering := false
var _lastClickFrame := -1
var _gen := 0

func Awake() -> void:
	originalScale = gameObject.scale
	iconImage = gameObject if gameObject is UImage else null
	if iconImage != null:
		originalColor = iconImage.color

func Update() -> void:
	if enablePulseEffect and not isHovering:
		gameObject.scale = originalScale * (1.0 + sin(U.time * pulseSpeed) * pulseAmount)

func OnDisable() -> void:
	ResetVisual()

func OnPointerEnter(_e) -> void:
	if not _active or not enableHoverEffect:
		return
	isHovering = true
	_gen += 1
	ScaleEffect(hoverScale, hoverDuration, _gen)
	if iconImage != null:
		iconImage.color = originalColor * hoverTintColor
	PlaySound(hoverSound)

func OnPointerExit(_e) -> void:
	if not _active or not enableHoverEffect:
		return
	isHovering = false
	_gen += 1
	ScaleEffect(1.0, hoverDuration, _gen)
	if iconImage != null:
		iconImage.color = originalColor

func OnPointerClick(_e) -> void:
	PlayClickEffect()

func PlayClickEffect(back_normal := false) -> void:
	if not _active or not enableClickEffect or U.frameCount == _lastClickFrame:
		return
	_lastClickFrame = U.frameCount
	_gen += 1
	ClickEffect(back_normal, _gen)
	PlaySound(clickSound)

func ScaleEffect(target: float, dur: float, g: int) -> void:
	var go = gameObject
	var start: Vector2 = go.scale
	var end := originalScale * target
	var t := 0.0
	while t < dur:
		await U.frame()
		if g != _gen or not is_instance_valid(go):
			return
		t += U.deltaTime
		go.scale = start.lerp(end, clampf(t / dur, 0.0, 1.0))
	go.scale = end

func ClickEffect(back_normal: bool, g: int) -> void:
	var go = gameObject
	var was_hover := isHovering and not back_normal
	var start: Vector2 = go.scale
	var clicked := originalScale * clickScale
	var t := 0.0
	while t < clickDuration:
		await U.frame()
		if g != _gen:
			return
		t += U.deltaTime
		go.scale = start.lerp(clicked, clampf(t / clickDuration, 0.0, 1.0))
	t = 0.0
	var end := originalScale * (hoverScale if was_hover else 1.0)
	while t < clickDuration:
		await U.frame()
		if g != _gen:
			return
		t += U.deltaTime
		go.scale = clicked.lerp(end, clampf(t / clickDuration, 0.0, 1.0))
	go.scale = end

func PlaySound(c) -> void:
	if c != null:
		UAudioSource.PlayClipAtPoint(c, null, 0.5)

func SetBaseColor(c: Color) -> void:
	originalColor = c
	if iconImage != null:
		iconImage.color = c * hoverTintColor if isHovering else c

func ResetVisual() -> void:
	_gen += 1
	gameObject.scale = originalScale
	if iconImage != null:
		iconImage.color = originalColor
	isHovering = false
