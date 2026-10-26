class_name TimePhaseManager
extends Mono

static var Instance: TimePhaseManager
signal OnPhaseChanged(phase: int)
var phaseTimer := 0.0
var subscribedCurrency
var subscribedScenarios
var storyStepCounter := 0
var currentPhase := TimePhase.Morning
var autoProgress := false
var phaseDuration := 300.0
var timeScale := 1.0
var advanceOnScenarioSteps := true
var stepsPerPhase := 2
var changeScreenColor := true
var nextPhaseButton
var previousPhaseButton
var previousPhaseCostType := CurrencyType.Gold
var previousPhaseCost := 50

func Awake() -> void:
	Instance = self

func RewirePhaseButtons() -> void:
	if nextPhaseButton != null:
		nextPhaseButton.onClick.RemoveListener(GoNextPhase)
		nextPhaseButton.onClick.AddListener(GoNextPhase)
	if previousPhaseButton != null:
		previousPhaseButton.onClick.RemoveListener(GoPreviousPhase)
		previousPhaseButton.onClick.AddListener(GoPreviousPhase)

func Start() -> void:
	RewirePhaseButtons()
	EnsureCurrencySubscription()
	EnsureScenarioSubscription()
	OnPhaseChanged.emit(currentPhase)
	UpdatePhaseButtons()

func Update() -> void:
	if subscribedCurrency == null:
		EnsureCurrencySubscription()
	if subscribedScenarios == null:
		EnsureScenarioSubscription()
	if not autoProgress:
		return
	phaseTimer += U.deltaTime * timeScale
	if phaseTimer >= phaseDuration:
		phaseTimer = 0.0
		NextPhase()

func OnDestroy() -> void:
	if subscribedCurrency != null:
		U.off(subscribedCurrency.OnCurrencyChanged, OnCurrencyChanged)
	if subscribedScenarios != null:
		U.off(subscribedScenarios.OnStepStart, OnScenarioStepStart)
		U.off(subscribedScenarios.OnStepComplete, OnScenarioStepComplete)

func EnsureScenarioSubscription() -> void:
	var cur = ScenarioManager.Instance
	if cur == subscribedScenarios or cur == null:
		return
	if subscribedScenarios != null and is_instance_valid(subscribedScenarios):
		U.off(subscribedScenarios.OnStepStart, OnScenarioStepStart)
		U.off(subscribedScenarios.OnStepComplete, OnScenarioStepComplete)
	subscribedScenarios = cur
	U.on(cur.OnStepStart, OnScenarioStepStart)
	U.on(cur.OnStepComplete, OnScenarioStepComplete)

static func IsDayScenarioRunning() -> bool:
	var cur = ScenarioManager.Instance.GetCurrentScenario() if ScenarioManager.Instance != null else null
	return cur != null and str(cur.scenarioID).begins_with("ashenveil_day")

func OnScenarioStepStart(step) -> void:
	if not advanceOnScenarioSteps or step == null or not IsDayScenarioRunning():
		return
	var named := PhaseFromStepName(step.get("stepName"))
	if named >= 0 and named > currentPhase:
		storyStepCounter = 0
		SetPhase(named)

func OnScenarioStepComplete(step) -> void:
	if not advanceOnScenarioSteps or currentPhase >= TimePhase.Evening or not IsDayScenarioRunning():
		return
	storyStepCounter += 1
	if storyStepCounter >= stepsPerPhase:
		storyStepCounter = 0
		NextPhase()

static func PhaseFromStepName(n) -> int:
	if U.empty(n):
		return -1
	var s := str(n).to_lower()
	if "dawn" in s or "morning" in s:
		return TimePhase.Morning
	if "noon" in s:
		return TimePhase.Noon
	if "evening" in s or "dusk" in s:
		return TimePhase.Evening
	if "night" in s:
		return TimePhase.Night
	return -1

func EnsureCurrencySubscription() -> void:
	var cur = CurrencyManager.Instance
	if cur == subscribedCurrency:
		return
	if subscribedCurrency != null and is_instance_valid(subscribedCurrency):
		U.off(subscribedCurrency.OnCurrencyChanged, OnCurrencyChanged)
	subscribedCurrency = cur
	if cur != null:
		U.on(cur.OnCurrencyChanged, OnCurrencyChanged)
		UpdatePhaseButtons()

func OnCurrencyChanged(type: int, _o: int, _n: int) -> void:
	if type == previousPhaseCostType:
		UpdatePhaseButtons()

func SetPhase(p: int) -> void:
	if currentPhase == p:
		return
	currentPhase = p
	phaseTimer = 0.0
	storyStepCounter = 0
	OnPhaseChanged.emit(currentPhase)
	UpdatePhaseButtons()

func NextPhase() -> void:
	var prev := currentPhase
	currentPhase = (currentPhase + 1) % 4
	phaseTimer = 0.0
	storyStepCounter = 0
	if prev == TimePhase.Night and currentPhase == TimePhase.Morning:
		TriggerNewDay()
	OnPhaseChanged.emit(currentPhase)
	UpdatePhaseButtons()

func CanChangePhaseManually() -> bool:
	if (CombatManager.Instance != null and CombatManager.Instance.inCombat) or (DialogueManager.Instance != null and DialogueManager.Instance.IsInDialogue()) or InNightOnlyRoom():
		return false
	return true

func GoPreviousPhase() -> void:
	if not CanChangePhaseManually() or currentPhase == TimePhase.Morning or CurrencyManager.Instance == null or not CurrencyManager.Instance.Spend(previousPhaseCostType, previousPhaseCost):
		return
	currentPhase -= 1
	phaseTimer = 0.0
	storyStepCounter = 0
	OnPhaseChanged.emit(currentPhase)
	UpdatePhaseButtons()

func GoNextPhase() -> void:
	if not CanChangePhaseManually():
		return
	if SceneEvent.Instance != null and SceneEvent.Instance.IsDayStoryWaiting:
		SceneEvent.Instance.ShowForegroundMessage(Loc.T("Not yet. Today's story is still waiting for you.", "Henüz değil. Bugünün hikayesi seni bekliyor."), 3.0)
		return
	NextPhase()

func TriggerNewDay() -> void:
	if TimeUI.Instance != null:
		TimeUI.Instance.IncrementDay()

static func InNightOnlyRoom() -> bool:
	return SceneEvent.Instance != null and SceneEvent.Instance.IsInNightOnlyRoom

func UpdatePhaseButtons() -> void:
	if previousPhaseButton != null:
		previousPhaseButton.interactable = not InNightOnlyRoom() and currentPhase != TimePhase.Morning and CurrencyManager.Instance != null and CurrencyManager.Instance.Has(previousPhaseCostType, previousPhaseCost)
	if nextPhaseButton != null:
		nextPhaseButton.interactable = not InNightOnlyRoom() and currentPhase != TimePhase.Night

func GetPhaseProgress() -> float:
	if autoProgress:
		return 0.0 if phaseDuration <= 0.0 else clampf(phaseTimer / phaseDuration, 0.0, 1.0)
	if advanceOnScenarioSteps:
		return 1.0 if currentPhase == TimePhase.Night else clampf(float(storyStepCounter) / stepsPerPhase, 0.0, 1.0)
	return 0.0

func GetTimeRemaining() -> float:
	return maxf(0.0, phaseDuration - phaseTimer)

func SetPhaseProgress(p: float) -> void:
	phaseTimer = clampf(p, 0.0, 1.0) * phaseDuration

func GetTimeRemainingFormatted() -> String:
	var r := GetTimeRemaining()
	return "%02d:%02d" % [floori(r / 60.0), floori(fmod(r, 60.0))]
