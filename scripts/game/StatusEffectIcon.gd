class_name StatusEffectIcon
extends Mono

var iconImage
var backgroundImage
var durationText
var stackText
var fillImage
var effectType := 0
var currentEffect

func Setup(e) -> void:
	currentEffect = e
	effectType = int(e.data.effectType)
	if iconImage != null and e.data.icon != null:
		iconImage.sprite = e.data.icon
	if backgroundImage != null:
		var c: Color = e.data.effectColor
		c.a = 0.5
		backgroundImage.color = c
	if fillImage != null:
		fillImage.color = e.data.effectColor
	UpdateEffect(e)

func UpdateEffect(e) -> void:
	currentEffect = e
	if durationText != null:
		if e.data.isPermanent:
			durationText.text = "∞"
		elif e.data.isRoundBased:
			durationText.text = str(e.remainingRounds)
		else:
			durationText.text = str(ceili(e.remainingDuration))
	if stackText != null:
		if e.data.canStack and e.currentStacks > 1:
			U.SetActive(stackText, true)
			stackText.text = "x%d" % e.currentStacks
		else:
			U.SetActive(stackText, false)
	if fillImage != null and not e.data.isPermanent:
		var f := 0.0
		if e.data.isRoundBased:
			f = float(e.remainingRounds) / int(e.data.durationRounds) if int(e.data.durationRounds) > 0 else 0.0
		else:
			f = e.remainingDuration / float(e.data.duration) if float(e.data.duration) > 0.0 else 0.0
		fillImage.fillAmount = f
