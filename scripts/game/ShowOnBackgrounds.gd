class_name ShowOnBackgrounds
extends Mono

var target
var visibleOnBackgrounds: Array = []
var minimumDay := 1
var restrictToPhases: Array = []
var hover
var hoverHiddenByFlag := ""
var hoverMinimumDay := 1
var fadeDuration := 0.35
var bgSubscribed := false
var phaseSubscribed := false
var flagSubscribed := false
var lastBackgroundIndex := -1
var covered := false
var group
var ownTalk
var _fade_gen := 0

func Start() -> void:
	TrySubscribe()

func OnEnable() -> void:
	TrySubscribe()

func OnDisable() -> void:
	if bgSubscribed and SceneEvent.Instance != null:
		U.off(SceneEvent.Instance.OnBackgroundChanged, HandleBackgroundChanged)
	if phaseSubscribed and TimePhaseManager.Instance != null:
		U.off(TimePhaseManager.Instance.OnPhaseChanged, HandlePhaseChanged)
	if flagSubscribed:
		StoryFlags.OnFlagAdded.RemoveListener(HandleFlagAdded)
	bgSubscribed = false
	phaseSubscribed = false
	flagSubscribed = false

func Update() -> void:
	if not bgSubscribed or not phaseSubscribed:
		TrySubscribe()
	var now := IsSceneCovered()
	if now != covered:
		covered = now
		var dm = DialogueManager.Instance
		var started = dm.LastStartNode if dm != null else null
		var replaced: bool = (CombatManager.Instance != null and CombatManager.Instance.inCombat) or (SceneEvent.Instance != null and SceneEvent.Instance.IsShowingQuestLocation) or (ScenarioManager.Instance != null and ScenarioManager.Instance.IsScenarioActive()) or (DialogueManager.WorldClicksBlocked() and started != null and started.backgroundImage != null)
		Refresh(not replaced)

func IsSceneCovered() -> bool:
	return ((DialogueManager.WorldClicksBlocked() or (SceneEvent.Instance != null and SceneEvent.Instance.IsHudReturning)) and not OwnTalkJustEnded()) or (ScenarioManager.Instance != null and ScenarioManager.Instance.IsScenarioActive()) or (CombatManager.Instance != null and CombatManager.Instance.inCombat) or (SceneEvent.Instance != null and SceneEvent.Instance.IsShowingQuestLocation)

func OwnTalkJustEnded() -> bool:
	var dm = DialogueManager.Instance
	if dm == null or dm.IsInDialogue() or hover == null:
		return false
	if ownTalk == null:
		ownTalk = U.GetComponent(hover, NPCDialogue)
	return ownTalk != null and ownTalk.startNode != null and ownTalk.startNode.backgroundImage == null and dm.LastStartNode == ownTalk.startNode

func TrySubscribe() -> void:
	if not bgSubscribed and SceneEvent.Instance != null:
		U.on(SceneEvent.Instance.OnBackgroundChanged, HandleBackgroundChanged)
		bgSubscribed = true
		if target != null:
			U.SetActive(target, false)
	if not phaseSubscribed and TimePhaseManager.Instance != null:
		U.on(TimePhaseManager.Instance.OnPhaseChanged, HandlePhaseChanged)
		phaseSubscribed = true
	if not flagSubscribed:
		StoryFlags.OnFlagAdded.AddListener(HandleFlagAdded)
		flagSubscribed = true

func HandleBackgroundChanged(i: int) -> void:
	lastBackgroundIndex = i
	Refresh(false)

func HandlePhaseChanged(_p) -> void:
	Refresh(true)

func HandleFlagAdded(f) -> void:
	if f == hoverHiddenByFlag:
		ApplyHover()

func Refresh(animate: bool) -> void:
	if target == null:
		return
	covered = IsSceneCovered()
	var show: bool = not covered and visibleOnBackgrounds.has(lastBackgroundIndex) and DayOk() and PhaseOk()
	ApplyHover()
	_fade_gen += 1
	if not animate or fadeDuration <= 0.0 or not _active:
		Group().alpha = 1.0
		U.SetActive(target, show)
		return
	if show == target.visible and Group().alpha >= 1.0:
		return
	Fade(show, _fade_gen)

func ApplyHover() -> void:
	if hover == null:
		return
	var offer: bool = TimeUI.Instance == null or TimeUI.Instance.GetCurrentDay() >= hoverMinimumDay
	U.SetActive(hover, offer and (U.empty(hoverHiddenByFlag) or not StoryFlags.Has(hoverHiddenByFlag)))

func Fade(show: bool, g: int) -> void:
	var cg = Group()
	var from: float = cg.alpha if target.visible else 0.0
	var to := 1.0 if show else 0.0
	if show:
		U.SetActive(target, true)
	var t := 0.0
	while t < fadeDuration:
		if g != _fade_gen:
			return
		cg.alpha = lerpf(from, to, t / fadeDuration)
		await U.frame()
		t += U.unscaledDeltaTime
	if g != _fade_gen:
		return
	cg.alpha = to
	if not show:
		U.SetActive(target, false)
		cg.alpha = 1.0

func Group():
	if group == null or not is_instance_valid(group):
		group = U.GetComponent(target, UCanvasGroup)
		if group == null:
			group = U.AddComponent(target, UCanvasGroup)
	return group

func DayOk() -> bool:
	return TimeUI.Instance == null or TimeUI.Instance.GetCurrentDay() >= minimumDay

func PhaseOk() -> bool:
	if restrictToPhases.is_empty() or TimePhaseManager.Instance == null:
		return true
	return restrictToPhases.has(TimePhaseManager.Instance.currentPhase)
