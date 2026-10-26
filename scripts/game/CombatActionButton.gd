class_name CombatActionButton
extends Mono

var button
var actionNameText
var energyCostText
var iconImage
var notEnoughEnergyIndicator
var action

func _on_injected(_root: Node) -> void:
	if action is Dictionary:
		action = CombatAction.from_dict(action)

func Setup(a) -> void:
	action = a
	if actionNameText != null:
		actionNameText.text = a.DisplayActionName
	if energyCostText != null:
		energyCostText.text = "%d %s" % [a.energyCost, Loc.T("Energy", "Enerji")]
	if iconImage != null and a.icon != null:
		iconImage.sprite = a.icon
	if button != null:
		button.onClick.RemoveAllListeners()
		button.onClick.AddListener(OnClick)
	UpdateInteractable(true)

func OnClick() -> void:
	if CombatManager.Instance == null:
		return
	var ci = GetComponent(ClickableIcon)
	if ci != null:
		ci.PlayClickEffect(true)
	if button != null:
		button.interactable = false
	if CombatUI.Instance != null:
		CombatUI.Instance.DisableAllActionButtons()
	CombatManager.Instance.ExecutePlayerAction(action)

func UpdateInteractable(can_use: bool) -> void:
	var enough: bool = PlayerStats.Instance != null and PlayerStats.Instance.HasEnoughEnergy(action.energyCost)
	var disabled: bool = action.isDisabled
	if button != null:
		button.interactable = can_use and enough and not disabled
	if notEnoughEnergyIndicator != null:
		U.SetActive(notEnoughEnergyIndicator, false)
	if energyCostText != null:
		energyCostText.color = UIPalette.Bad if not enough and not disabled else UIPalette.Cream
