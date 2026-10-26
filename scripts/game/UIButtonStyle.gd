class_name UIButtonStyle
extends Mono

enum Kind { Action, Compact, Icon }
var theme
var kind := 0
var primary := false
var applyOnEnable := true
var resizeToMetrics := true
var styleLabel := true
var maxLines := 1
var overrideLabelColor := false
var labelColor := Color.WHITE
var labelFontSize := 0.0
var overrideButtonColor := false
var buttonColor := Color.WHITE

func _on_injected(_root: Node) -> void:
	Apply()

func OnEnable() -> void:
	if applyOnEnable:
		Apply()

func Apply() -> void:
	var button = GetComponent(UButton)
	if theme == null or button == null:
		return
	var image = button.targetGraphic
	if image is UImage:
		image.sprite = UISprites.Rounded(int(theme.radiusSlot) if kind == Kind.Icon else int(theme.radiusButton))
		image.type = UImage.Type.SLICED
		image.color = buttonColor if overrideButtonColor else (theme.accent if primary else theme.buttonSecondary)
	button._colors = {"normalColor": Color.WHITE, "highlightedColor": Color(1.28, 1.28, 1.28, 1), "pressedColor": Color(0.82, 0.82, 0.82, 1), "selectedColor": Color.WHITE, "disabledColor": Color(1, 1, 1, 0.35), "colorMultiplier": 1.0, "fadeDuration": 0.08}
	button.transition = 1
	button._update_state(true)
	var label = U.GetComponentInChildren(gameObject, UText, true)
	if label != null and styleLabel:
		label.color = labelColor if overrideLabelColor else (theme.primaryButtonText if primary else theme.buttonText)
		label.fontSize = labelFontSize if labelFontSize > 0.0 else (float(theme.sizeBody) if kind == Kind.Action else float(theme.sizeLabel))
	if label != null:
		FitLabel(label, maxLines)
	if resizeToMetrics:
		Resize()

static func FitLabel(label, lines: int) -> void:
	var mx: float = maxf(label.fontSizeMax, label._fontSize) if label.enableAutoSizing else label._fontSize
	label.enableWordWrapping = lines > 1
	label.fontSizeMax = mx
	label.fontSizeMin = minf(20.0 if lines > 1 else 14.0, mx)
	label.enableAutoSizing = true
	var am: Vector2 = label.anchorMin
	var ax: Vector2 = label.anchorMax
	var fills: bool = am == Vector2.ZERO and ax == Vector2.ONE and label.offsetMin == Vector2.ZERO and label.offsetMax == Vector2.ZERO
	if fills and label.margin == Vector4.ZERO and label.size.x >= 100.0:
		label.margin = Vector4(12, 2, 12, 2)

func Resize() -> void:
	var go = gameObject
	var s: Vector2 = go.sizeDelta
	match kind:
		Kind.Action:
			s.y = float(theme.buttonHeight)
			s.x = maxf(s.x, float(theme.buttonMinWidth))
		Kind.Compact:
			s.y = float(theme.buttonHeightCompact)
			s.x = maxf(s.x, float(theme.buttonMinWidth))
		Kind.Icon:
			s = Vector2(float(theme.iconButtonSize), float(theme.iconButtonSize))
	go.sizeDelta = s
