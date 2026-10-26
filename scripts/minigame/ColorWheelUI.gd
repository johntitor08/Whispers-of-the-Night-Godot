class_name ColorWheelUI
extends Mono

var colorPreview
var hueSlider
var satSlider
var valSlider
var hexInput

func Start() -> void:
	if hueSlider != null:
		hueSlider.onValueChanged.AddListener(_on_slider)
	if satSlider != null:
		satSlider.onValueChanged.AddListener(_on_slider)
	if valSlider != null:
		valSlider.onValueChanged.AddListener(_on_slider)
	if hexInput != null:
		hexInput.onEndEdit.AddListener(OnHexInput)
	SyncFromBrush()

func _on_slider(_v) -> void:
	OnHSVChanged()

func OnHSVChanged() -> void:
	var h: float = hueSlider.value if hueSlider != null else 0.0
	var s: float = satSlider.value if satSlider != null else 1.0
	var v: float = valSlider.value if valSlider != null else 1.0
	var c := Color.from_hsv(h, s, v)
	BrushSettings.Instance.color = c
	if colorPreview != null:
		colorPreview.color = c
	if hexInput != null:
		hexInput.text = c.to_html(false).to_upper()

func OnHexInput(hex: String) -> void:
	if not Color.html_is_valid("#" + hex):
		return
	var c := Color.html("#" + hex)
	BrushSettings.Instance.color = c
	if colorPreview != null:
		colorPreview.color = c
	_set_sliders(c)

func _set_sliders(c: Color) -> void:
	if hueSlider != null:
		hueSlider.value = c.h
	if satSlider != null:
		satSlider.value = c.s
	if valSlider != null:
		valSlider.value = c.v

func SyncFromBrush() -> void:
	var c: Color = BrushSettings.Instance.color
	_set_sliders(c)
	if colorPreview != null:
		colorPreview.color = c
