class_name LootNotification
extends Mono

var iconImage
var messageText
var canvasGroup
var duration := 3.0
var elapsed := 0.0

func Setup(msg: String, c: Color, icon, dur: float) -> void:
	if messageText != null:
		messageText.text = msg
		messageText.color = c
	if iconImage != null and icon != null:
		iconImage.sprite = icon
		iconImage.enabled = true
	elif iconImage != null:
		iconImage.enabled = false
	duration = dur
	elapsed = 0.0
	if canvasGroup != null:
		canvasGroup.alpha = 1.0

func Update() -> void:
	elapsed += U.deltaTime
	if elapsed > duration - 1.0 and canvasGroup != null:
		canvasGroup.alpha = 1.0 - (elapsed - (duration - 1.0))
	if elapsed >= duration and LootNotificationUI.Instance != null:
		LootNotificationUI.Instance.ReturnToPool(gameObject)
