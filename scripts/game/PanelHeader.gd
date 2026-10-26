class_name PanelHeader
extends Mono

var titleEn := "Panel"
var titleTr := "Panel"
var titleLabel
var closeButton
var closeTarget
var onClose := UEvent.new()

func OnEnable() -> void:
	LanguageManager.OnLanguageChanged.AddListener(_lang)
	RefreshTitle()

func OnDisable() -> void:
	LanguageManager.OnLanguageChanged.RemoveListener(_lang)

func _lang(_l) -> void:
	RefreshTitle()

func Start() -> void:
	if closeButton != null:
		closeButton.onClick.RemoveListener(Close)
		closeButton.onClick.AddListener(Close)

func RefreshTitle() -> void:
	if titleLabel != null:
		titleLabel.text = Loc.T(titleEn, titleTr)

func Close() -> void:
	if closeTarget != null:
		UIPanelAnimator.Hide(closeTarget)
	if onClose is UEvent:
		onClose.Invoke()
