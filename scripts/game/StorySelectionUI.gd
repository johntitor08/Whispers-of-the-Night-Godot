class_name StorySelectionUI
extends Mono

static var Instance: StorySelectionUI
var _pendingOriginID := ""
var _type_gen := 0
var originButtonTemplate
var originButtonContainer
var buttonSpacing := 70.0
var detailPanel
var detailTitle
var detailText
var continueButton
var mainStoryPanel
var originAButton
var mainStoryText
var originBButton
var originCButton

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func Start() -> void:
	if detailPanel != null:
		U.SetActive(detailPanel, false)
	if continueButton != null:
		continueButton.onClick.RemoveListener(OnContinue)
		continueButton.onClick.AddListener(OnContinue)
	BuildOriginButtons()

func ShowMainPanel() -> void:
	if mainStoryPanel != null:
		var p = U.parent(mainStoryPanel)
		if p != null:
			U.SetActive(p, true)
		U.SetActive(mainStoryPanel, true)
	if detailPanel != null:
		U.SetActive(detailPanel, false)
	if mainStoryText != null:
		StartTypewriter(mainStoryText, mainStoryText.text)

func BuildOriginButtons() -> void:
	if originButtonTemplate == null or originButtonContainer == null or OriginManager.Instance == null:
		return
	U.SetActive(originButtonTemplate, false)
	for c in U.kids(originButtonContainer):
		if str(c.get_meta("u_name", c.name)).begins_with("OriginBtn_"):
			U.Destroy(c)
	var origins: Array = OriginManager.Instance.allOrigins
	var tgo = originButtonTemplate.gameObject
	var has_layout: bool = U.GetComponent(originButtonContainer, ULayoutGroupBase) != null
	var shown := 0
	for o in origins:
		if o == null:
			continue
		var btn = U.Instantiate(originButtonTemplate, originButtonContainer)
		btn.gameObject.set_meta("u_name", "OriginBtn_" + str(o.originID))
		U.SetActive(btn, true)
		if not has_layout:
			btn.gameObject.anchoredPosition = tgo.anchoredPosition + Vector2(0, -buttonSpacing * shown)
		var lbl = btn.GetComponentInChildren(UText)
		if lbl != null:
			lbl.text = o.DisplayName
		var id := str(o.originID)
		btn.onClick.RemoveAllListeners()
		btn.onClick.AddListener(func(): OpenPanel(id))
		shown += 1

func OpenPanel(id: String) -> void:
	_pendingOriginID = id
	var data = OriginManager.Instance.GetOrigin(id) if OriginManager.Instance != null else null
	if mainStoryPanel != null:
		U.SetActive(mainStoryPanel, false)
	if detailPanel != null:
		U.SetActive(detailPanel, true)
	if detailTitle != null and data != null:
		detailTitle.text = data.DisplayName
	if detailText != null:
		StartTypewriter(detailText, data.DisplaySummary if data != null else "")

func StartTypewriter(label, text: String) -> void:
	if label == null or text == "":
		return
	_type_gen += 1
	var g := _type_gen
	if Typewriter.Instance != null and Typewriter.Instance.IsTyping:
		Typewriter.Instance.Complete()
	label.text = ""
	await U.wait(0.15)
	if g != _type_gen:
		return
	if Typewriter.Instance != null:
		Typewriter.Instance.StartTyping(label, text)
	else:
		label.text = text

func OnContinue() -> void:
	if Typewriter.Instance != null and Typewriter.Instance.IsTyping:
		Typewriter.Instance.Complete()
	if U.empty(_pendingOriginID) or OriginManager.Instance == null:
		return
	OriginManager.Instance.SelectOrigin(_pendingOriginID)
	if mainStoryPanel != null:
		var p = U.parent(mainStoryPanel)
		if p != null:
			U.SetActive(p, false)
	if SceneEvent.Instance != null:
		SceneEvent.Instance.InitializeGame()
