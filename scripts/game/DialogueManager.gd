class_name DialogueManager
extends Mono

static var Instance: DialogueManager
signal OnDialogueStart(node)
signal OnChoiceSelected(choice)
signal OnDialogueEnd(node)
signal OnLineShown(node, index: int)
signal OnNodeAdvanced(node)

const ConversationSettleSeconds := 0.4
var State := DialogueState.Idle
var currentNode
var currentLineIndex := 0
var onDialogueEnd = null
var _auto_gen := 0
var _closing := false
var _closingDeadline := 0.0
var _closingNode
var _closingCallback = null
var _lastDialogueEndTime := -10.0
var _endCallbackPending := false
var _pendingEndCallback = null
var _lines: Array = []
var LastStartNode
var PanelAnimator
var audioSource
var _portraitMap = null
var _locMap = null

var dialoguePanel
var speakerNameText
var dialogueText
var speakerPortrait
var backgroundImage
var continueButton
var choicesPanel
var choicesContainer
var choiceButtonPrefab
var enableSpeakerPortraits := false
var portraitsByName: Array = []
var typewriter
var localizationTable
var dialogueOpenSound
var dialogueCloseSound
var choiceSelectSound

static func WorldClicksBlocked() -> bool:
	return Instance != null and is_instance_valid(Instance) and Instance.IsConversationBusy()

func Awake() -> void:
	Instance = self
	audioSource = AddComponent(UAudioSource)
	audioSource.playOnAwake = false
	if typewriter != null:
		U.on(typewriter.OnTypingComplete, OnTypingFinished)
	BuildLocMap()
	LanguageManager.OnLanguageChanged.AddListener(OnLanguageSwitched)

func OnDestroy() -> void:
	LanguageManager.OnLanguageChanged.RemoveListener(OnLanguageSwitched)

func OnLanguageSwitched(_lang) -> void:
	if currentNode == null or State == DialogueState.Idle or State == DialogueState.Closing or State == DialogueState.Opening:
		return
	var rel = Localize(currentNode)
	if rel == null or rel == currentNode:
		return
	currentNode = rel
	ResolveLines()
	SetupVisuals()
	if State == DialogueState.Choices:
		ShowChoicesOrEnd()
	elif currentLineIndex < _lines.size():
		ShowLine()

func Update() -> void:
	if _closing and U.unscaledTime >= _closingDeadline:
		FinalizeClose()
		return
	if State != DialogueState.Typing and State != DialogueState.WaitingInput:
		return
	if not (U.GetKeyDown(KEY_SPACE) or U.GetMouseButtonDown(0)):
		return
	if State == DialogueState.Typing and typewriter != null and typewriter.IsTyping:
		typewriter.Complete()
	elif State == DialogueState.WaitingInput:
		NextLine()

func LookupPortrait(n):
	if U.empty(n) or portraitsByName.is_empty():
		return null
	if _portraitMap == null:
		_portraitMap = {}
		for e in portraitsByName:
			if e != null and not U.empty(e.get("speakerName")) and e.get("portrait") != null:
				_portraitMap[str(e.speakerName).strip_edges().to_lower()] = e.portrait
	return _portraitMap.get(str(n).strip_edges().to_lower())

func IsPanelAnimatorAlive() -> bool:
	return PanelAnimator != null and is_instance_valid(PanelAnimator)

func BuildLocMap() -> void:
	_locMap = {}
	if localizationTable == null or localizationTable.entries == null:
		return
	for e in localizationTable.entries:
		if e == null:
			continue
		if e.get("en") != null:
			_locMap[e.en] = e
		if e.get("tr") != null:
			_locMap[e.tr] = e

func Localize(node):
	if node == null:
		return null
	if _locMap == null:
		BuildLocMap()
	if _locMap.has(node):
		var e = _locMap[node]
		var want = e.get("en") if LanguageManager.Current == GameLanguage.EN else e.get("tr")
		var other = e.get("tr") if LanguageManager.Current == GameLanguage.EN else e.get("en")
		return want if want != null else (other if other != null else node)
	return node

func SetupVisuals() -> void:
	if currentNode == null:
		return
	if speakerNameText != null:
		speakerNameText.text = currentNode.DisplaySpeaker
		var c = currentNode.speakerNameColor
		if c is Color:
			speakerNameText.color = c
	if speakerPortrait != null:
		var portrait = null
		if enableSpeakerPortraits:
			portrait = currentNode.speakerPortrait if currentNode.speakerPortrait != null else LookupPortrait(currentNode.speakerName)
		speakerPortrait.sprite = portrait
		speakerPortrait.enabled = true
		speakerPortrait.preserveAspect = true
		U.SetActive(speakerPortrait, portrait != null)
	if backgroundImage != null and currentNode.characterImage == null:
		if SceneEvent.Instance != null:
			SceneEvent.Instance.ShowDialogueBackdrop(SceneEvent.Instance.PhaseVariantOf(currentNode.backgroundImage))
		else:
			backgroundImage.sprite = currentNode.backgroundImage
			backgroundImage.enabled = currentNode.backgroundImage != null

func StartDialogue(start_node, callback = null) -> void:
	if start_node == null:
		return
	FlushPendingEndCallback()
	if State != DialogueState.Idle:
		return
	StopAllCoroutines()
	_auto_gen += 1
	LastStartNode = start_node
	currentNode = Localize(start_node)
	ResolveLines()
	currentLineIndex = 0
	onDialogueEnd = callback
	State = DialogueState.Opening
	_invoke_event(currentNode.onEnter)
	OnDialogueStart.emit(currentNode)
	SetupVisuals()
	ClearChoices()
	OpenPanelAfterTransition()

func _invoke_event(ev) -> void:
	if ev is UEvent:
		ev.Invoke()

func OpenPanelAfterTransition() -> void:
	var e := co()
	await WaitForSceneTransition()
	if dead(e):
		return
	U.SetActive(dialoguePanel, true)
	PlaySound(dialogueOpenSound)
	var od := 0.0
	if IsPanelAnimatorAlive():
		PanelAnimator.OpenDialoguePanel()
		od = PanelAnimator.DialogueOpenAnimationDuration()
	await WaitThenShowLine(od, e)

func WaitThenShowLine(delay: float, e: int) -> void:
	if delay > 0.0:
		await U.wait(delay)
		if dead(e):
			return
	await WaitForSceneTransition()
	if dead(e):
		return
	ShowLine()

func WaitTransitionThenSetupAndShow() -> void:
	var e := co()
	await WaitForSceneTransition()
	if dead(e):
		return
	SetupVisuals()
	ShowLine()

func ReopenPanelForNextNode() -> void:
	var e := co()
	if dialogueText != null:
		dialogueText.text = ""
	if IsPanelAnimatorAlive():
		PanelAnimator.CloseDialoguePanel()
		await U.wait(PanelAnimator.DialogueCloseAnimationDuration())
		if dead(e):
			return
	await WaitForSceneTransition()
	if dead(e):
		return
	SetupVisuals()
	var od := 0.0
	if IsPanelAnimatorAlive():
		PanelAnimator.OpenDialoguePanel()
		od = PanelAnimator.DialogueOpenAnimationDuration()
	await WaitThenShowLine(od, e)

func WaitForSceneTransition() -> void:
	var t := 0.0
	while IsPanelAnimatorAlive() and PanelAnimator.IsSceneTransitionActive() and t < 3.0:
		t += U.unscaledDeltaTime
		await U.frame()

func IsInDialogue() -> bool:
	return State != DialogueState.Idle

func IsConversationBusy() -> bool:
	return IsInDialogue() or _endCallbackPending or U.unscaledTime - _lastDialogueEndTime < ConversationSettleSeconds or (ScenarioManager.Instance != null and ScenarioManager.Instance.IsPlayingSequence())

func IsSceneTransitionBusy() -> bool:
	return _endCallbackPending or (IsPanelAnimatorAlive() and PanelAnimator.IsSceneTransitionActive())

func ShowLine() -> void:
	if currentNode == null:
		return
	if currentLineIndex >= _lines.size():
		ShowChoicesOrEnd()
		return
	OnLineShown.emit(currentNode, currentLineIndex)
	State = DialogueState.Typing
	if continueButton != null:
		U.SetActive(continueButton, false)
	var line := ParseLine()
	if typewriter != null:
		typewriter.StartTyping(dialogueText, line)
	else:
		dialogueText.text = line
		FinishTyping()
		if currentNode.autoAdvance:
			AutoAdvanceRoutine(float(currentNode.autoAdvanceDelay))

func FinishTyping() -> void:
	State = DialogueState.WaitingInput
	if continueButton != null:
		U.SetActive(continueButton, true)

func OnTypingFinished() -> void:
	if State != DialogueState.Typing or (typewriter != null and typewriter.CurrentTarget != dialogueText):
		return
	FinishTyping()
	if currentNode != null and currentNode.autoAdvance:
		AutoAdvanceRoutine(float(currentNode.autoAdvanceDelay))

func AutoAdvanceRoutine(delay: float) -> void:
	_auto_gen += 1
	var g := _auto_gen
	var e := co()
	await U.wait(delay)
	if g != _auto_gen or dead(e):
		return
	NextLine()

func NextLine() -> void:
	if State != DialogueState.WaitingInput:
		return
	_auto_gen += 1
	currentLineIndex += 1
	ShowLine()

func ShowChoicesOrEnd() -> void:
	ClearChoices()
	var choices = currentNode.choices if currentNode != null else null
	if currentNode == null or choices == null or choices.is_empty():
		EndDialogue()
		return
	State = DialogueState.Choices
	if choicesPanel == null or choicesContainer == null or choiceButtonPrefab == null:
		EndDialogue()
		return
	for choice in choices:
		var btn = U.Instantiate(choiceButtonPrefab, choicesContainer)
		var lbl = btn.GetComponentInChildren(UText)
		var locked: bool = bool(choice.get("requiresAffinity", 0)) and (AffinityManager.Instance == null or AffinityManager.Instance.Get(choice.get("affinityCharacter")) < int(choice.get("requiredAffinity", 0)))
		if locked:
			lbl.text = "%s  <color=%s>(%s %s %d)</color>" % [DialogueNode.ChoiceText(choice), UIPalette.Hex(UIPalette.Muted), Loc.T("needs", "gerekli"), str(choice.affinityCharacter), int(choice.requiredAffinity)]
			btn.interactable = false
		else:
			lbl.text = DialogueNode.ChoiceText(choice)
			var cap = choice
			btn.onClick.AddListener(func(): SelectChoice(cap))
	var h: float = choices.size() * 100.0
	if choicesPanel is Control:
		var sd: Vector2 = RT.size_delta(choicesPanel)
		RT.set_size_delta(choicesPanel, Vector2(sd.x, h))
		if choicesContainer is Control:
			var sd2: Vector2 = RT.size_delta(choicesContainer)
			RT.set_size_delta(choicesContainer, Vector2(sd2.x, h))
	U.SetActive(choicesPanel, true)

func SelectChoice(choice) -> void:
	if State != DialogueState.Choices:
		return
	if choicesPanel != null:
		U.SetActive(choicesPanel, false)
	ClearChoices()
	PlaySound(choiceSelectSound)
	OnChoiceSelected.emit(choice)
	if choice.get("setFlag") and not U.empty(choice.get("flagToSet")):
		StoryFlags.Add(choice.flagToSet)
	if not U.empty(choice.get("affinityTarget")) and int(choice.get("affinityDelta", 0)) != 0 and AffinityManager.Instance != null:
		AffinityManager.Instance.Add(choice.affinityTarget, int(choice.affinityDelta))
	if choice.get("changeStat") and int(choice.get("statDelta", 0)) != 0 and PlayerStats.Instance != null:
		PlayerStats.Instance.Modify(int(choice.statToChange), int(choice.statDelta), true)
		if SceneEvent.Instance != null:
			var dlt := int(choice.statDelta)
			SceneEvent.Instance.ShowForegroundMessage("%s %s%d" % [DisplayNames.Stat(int(choice.statToChange)), "+" if dlt > 0 else "", dlt], 3.0)
	_invoke_event(currentNode.onExit)
	ApplyExitFlags(currentNode)
	if choice.get("nextNode") != null:
		var prev_char = currentNode.characterImage
		currentNode = Localize(choice.nextNode)
		ResolveLines()
		currentLineIndex = 0
		_invoke_event(currentNode.onEnter)
		OnNodeAdvanced.emit(currentNode)
		State = DialogueState.Opening
		var changes: bool = currentNode.characterImage != null and currentNode.characterImage != prev_char
		if changes:
			ReopenPanelForNextNode()
		else:
			WaitTransitionThenSetupAndShow()
	else:
		EndDialogue()

func EndDialogue() -> void:
	if State == DialogueState.Closing:
		return
	State = DialogueState.Closing
	_auto_gen += 1
	var ended = currentNode
	if ended != null:
		_invoke_event(ended.onExit)
		ApplyExitFlags(ended)
	currentNode = null
	if dialogueText != null:
		dialogueText.text = ""
	ClearChoices()
	PlaySound(dialogueCloseSound)
	if IsPanelAnimatorAlive():
		PanelAnimator.CloseDialoguePanel()
	var cd: float = PanelAnimator.DialogueCloseAnimationDuration() if IsPanelAnimatorAlive() else 0.25
	_closingNode = ended
	_closingCallback = onDialogueEnd
	_closingDeadline = U.unscaledTime + maxf(cd, 0.0)
	_closing = true

func FinalizeClose() -> void:
	if not _closing:
		return
	_closing = false
	if dialoguePanel != null:
		U.SetActive(dialoguePanel, false)
	State = DialogueState.Idle
	_lastDialogueEndTime = U.unscaledTime
	var ended = _closingNode
	var cb = _closingCallback
	_closingNode = null
	_closingCallback = null
	OnDialogueEnd.emit(ended)
	if cb == null:
		return
	_endCallbackPending = true
	_pendingEndCallback = cb
	InvokeEndCallbackAfterTransition()

func InvokeEndCallbackAfterTransition() -> void:
	await WaitForSceneTransition()
	if not _endCallbackPending:
		return
	var cb = _pendingEndCallback
	_endCallbackPending = false
	_pendingEndCallback = null
	if SceneEvent.Instance != null:
		SceneEvent.Instance.TransitionScene(cb)
	elif cb is Callable:
		cb.call()

func FlushPendingEndCallback() -> void:
	if not _endCallbackPending:
		return
	var cb = _pendingEndCallback
	_endCallbackPending = false
	_pendingEndCallback = null
	if cb is Callable:
		cb.call()

func ClearChoices() -> void:
	if choicesPanel != null:
		U.SetActive(choicesPanel, false)
	if choicesContainer == null:
		return
	for c in U.kids(choicesContainer):
		U.SetActive(c, false)
		U.Destroy(c)

func ResolveLines() -> void:
	_lines.clear()
	if currentNode == null:
		return
	var base_lines = currentNode.lines
	var base_count: int = base_lines.size() if base_lines != null else 0
	var extra := []
	var cls = currentNode.conditionalLines
	if cls != null:
		for c in cls:
			if c != null and DialogueNode.CondApplies(c):
				extra.append(c)
	for i in base_count + 1:
		for c in extra:
			var ib := int(c.get("insertBefore", -1))
			var at := base_count if ib < 0 or ib > base_count else ib
			if at == i:
				_lines.append(DialogueNode.CondLine(c))
		if i < base_count:
			_lines.append(currentNode.GetDisplayLine(i))

func ParseLine() -> String:
	if currentNode == null or currentLineIndex < 0 or currentLineIndex >= _lines.size():
		return ""
	var line: String = _lines[currentLineIndex]
	if ProfileManager.Instance != null:
		line = line.replace("{playerName}", ProfileManager.Instance.profile.playerName)
	return line

func ApplyExitFlags(node) -> void:
	if node == null or node.flagsToSetOnExit == null:
		return
	for f in node.flagsToSetOnExit:
		if not U.empty(f):
			StoryFlags.Add(f)

func PlaySound(clip) -> void:
	if clip == null or audioSource == null:
		return
	audioSource.PlayOneShot(clip, 0.5)
