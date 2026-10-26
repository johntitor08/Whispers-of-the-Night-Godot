class_name BuffUI
extends Mono

var icon
var timerText
var tooltip
var tooltipText
var buffName := ""
var duration := 0.0

func Setup(buff_icon, n: String, d: float) -> void:
	icon.sprite = buff_icon
	buffName = n
	duration = d
	timerText.text = "%.1fs" % d
	if tooltip != null:
		U.SetActive(tooltip, false)
		tooltipText.text = "%s\nDuration: %.1fs" % [buffName, d]

func UpdateTimer(left: float) -> void:
	timerText.text = "%.1fs" % maxf(0.0, left)
	if tooltip != null:
		tooltipText.text = "%s\nDuration: %.1fs" % [buffName, maxf(0.0, left)]

func OnPointerEnter(_e) -> void:
	if tooltip != null:
		U.SetActive(tooltip, true)

func OnPointerExit(_e) -> void:
	if tooltip != null:
		U.SetActive(tooltip, false)
