class_name RewardItemUI
extends Mono

var icon
var nameText
var amountText
var selectButton
var selectedIndicator

func Setup(item_name: String, amount: String, item_icon, cb = null, sel := false) -> void:
	if nameText != null:
		nameText.text = item_name
	if amountText != null:
		amountText.text = amount
	if icon != null and item_icon != null:
		icon.sprite = item_icon
		icon.enabled = true
	elif icon != null:
		icon.enabled = false
	if selectButton == null:
		selectButton = GetComponent(UButton)
	if selectButton != null:
		selectButton.onClick.RemoveAllListeners()
		selectButton.interactable = cb != null
		if cb != null:
			selectButton.onClick.AddListener(cb)
	if selectedIndicator != null:
		U.SetActive(selectedIndicator, sel)
