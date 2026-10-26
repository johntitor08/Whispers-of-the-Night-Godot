class_name ScenarioManager
extends Mono

static var Instance: ScenarioManager
signal OnScenarioStart(scenario)
signal OnScenarioComplete(scenario)
signal OnScenarioAborted(scenario)
signal OnStepStart(step)
signal OnStepComplete(step)

var completedScenarios: Dictionary = {}
var _act_gen := 0
var _queuedScenario
var hasStoryStarted := false
var _introPending := false
var _pendingStepDialogue
var _scenarioDialogueStart
var _stepAfterDialogue := -1
var _retreatStep := -1
var currentScenario
var currentStepIndex := 0
var isScenarioActive := false
var availableScenarios: Array = []

var IsWaitingAfterRetreat: bool:
	get:
		return isScenarioActive and _retreatStep >= 0

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)

func GetSaveData() -> Dictionary:
	return {"completedScenarioIDs": completedScenarios.keys()}

func LoadSaveData(data) -> void:
	completedScenarios.clear()
	if data == null or data.get("completedScenarioIDs") == null:
		return
	for id in data.completedScenarioIDs:
		completedScenarios[str(id)] = true

func GetScenarioByID(id):
	if U.empty(id):
		return null
	for s in availableScenarios:
		if s != null and s.scenarioID == id:
			return s
	return null

func CanStartScenario(s) -> bool:
	if s == null or IsScenarioCompleted(s.scenarioID):
		return false
	if ProfileManager.Instance != null and ProfileManager.Instance.profile.level < int(s.requiredLevel):
		return false
	if s.requiredFlags != null:
		for f in s.requiredFlags:
			if not StoryFlags.Has(f):
				return false
	if s.prerequisiteScenarios != null:
		for p in s.prerequisiteScenarios:
			if p != null and not IsScenarioCompleted(p.scenarioID):
				return false
	return true

func _steps() -> Array:
	return currentScenario.steps if currentScenario != null and currentScenario.steps != null else []

func StartScenario(s) -> void:
	if not CanStartScenario(s):
		return
	if isScenarioActive:
		_queuedScenario = s
		return
	StopActiveCoroutine()
	_introPending = false
	_pendingStepDialogue = null
	currentScenario = s
	currentStepIndex = 0
	isScenarioActive = true
	hasStoryStarted = true
	_retreatStep = -1
	OnScenarioStart.emit(s)
	if s.introDialogue != null and DialogueManager.Instance != null:
		_introPending = true
		StartIntroWhenIdle(s, _act_gen)
	else:
		StartNextStep()

func PeekFollowUpDialogue(ended_start):
	if not isScenarioActive or currentScenario == null:
		return null
	if _introPending:
		return currentScenario.introDialogue
	if _pendingStepDialogue != null:
		return _pendingStepDialogue
	var steps := _steps()
	if ended_start == null or ended_start != _scenarioDialogueStart or steps.is_empty():
		return null
	var nx := _stepAfterDialogue
	while nx >= 0 and nx < steps.size() and steps[nx] != null and not ScenarioData.StepApplies(steps[nx]):
		nx += 1
	if nx >= 0 and nx < steps.size():
		return steps[nx].dialogue if int(steps[nx].type) == ScenarioStepType.Dialogue else null
	return currentScenario.outroDialogue if nx == steps.size() else null

func StartIntroWhenIdle(s, g: int) -> void:
	await WaitForDialogueSlot()
	if g != _act_gen:
		return
	_introPending = false
	if not isScenarioActive or currentScenario != s or DialogueManager.Instance == null:
		return
	_scenarioDialogueStart = s.introDialogue
	_stepAfterDialogue = currentStepIndex
	DialogueManager.Instance.StartDialogue(s.introDialogue, StartNextStep)

func ResolveStepIndex(id, saved: int, saved_name) -> int:
	var s = GetScenarioByID(id)
	if s == null or s.steps == null or U.empty(saved_name):
		return saved
	for i in s.steps.size():
		if s.steps[i] != null and s.steps[i].stepName == saved_name:
			return i
	return saved

func ResumeScenario(id, step: int, wait_square := false) -> void:
	var s = GetScenarioByID(id)
	if s == null:
		return
	StopActiveCoroutine()
	currentScenario = s
	currentStepIndex = clampi(step, 0, s.steps.size() if s.steps != null else 0)
	isScenarioActive = true
	_retreatStep = -1
	hasStoryStarted = true
	OnScenarioStart.emit(s)
	if wait_square:
		_retreatStep = currentStepIndex
		if SceneEvent.Instance != null:
			SceneEvent.Instance.ShowHudPanels()
			SceneEvent.Instance.ShowForegroundMessage(Loc.T("The fight you ran from is waiting for you in the village square.", "Kaçtığın dövüş seni köy meydanında bekliyor."), 4.0)
		return
	StartNextStep()

func StartNextStep() -> void:
	if not isScenarioActive or currentScenario == null:
		return
	var steps := _steps()
	while currentStepIndex < steps.size() and steps[currentStepIndex] != null and not ScenarioData.StepApplies(steps[currentStepIndex]):
		currentStepIndex += 1
	if currentStepIndex >= steps.size():
		CompleteScenario()
		return
	var step = steps[currentStepIndex]
	OnStepStart.emit(step)
	match int(step.type):
		ScenarioStepType.Dialogue:
			if step.dialogue != null and DialogueManager.Instance != null:
				_pendingStepDialogue = step.dialogue
				StartStepDialogueWhenIdle(step, currentStepIndex, _act_gen)
			else:
				CompleteCurrentStep()
		ScenarioStepType.Combat:
			if step.enemy != null and CombatManager.Instance != null:
				SubscribeCombatHandlers()
				CombatManager.Instance.StartCombat(step.enemy)
			else:
				CompleteCurrentStep()
		ScenarioStepType.CollectItem:
			ExecuteCollectItemStep(step)
		ScenarioStepType.GoToLocation:
			CompleteCurrentStep()
		ScenarioStepType.Wait:
			WaitStep(float(step.waitDuration), currentStepIndex, _act_gen)
		_:
			CompleteCurrentStep()

func CompleteCurrentStep() -> void:
	if not isScenarioActive or currentScenario == null:
		return
	var step = _steps()[currentStepIndex]
	OnStepComplete.emit(step)
	currentStepIndex += 1
	StartNextStep()

func WaitForDialogueSlot() -> void:
	var t := 0.0
	while DialogueManager.Instance != null and (DialogueManager.Instance.IsInDialogue() or (DialogueManager.Instance.IsSceneTransitionBusy() and t < 3.0)):
		t += U.unscaledDeltaTime
		await U.frame()

func StartStepDialogueWhenIdle(step, idx: int, g: int) -> void:
	await WaitForDialogueSlot()
	if g != _act_gen:
		return
	_pendingStepDialogue = null
	if not isScenarioActive or currentStepIndex != idx or DialogueManager.Instance == null:
		return
	_scenarioDialogueStart = step.dialogue
	_stepAfterDialogue = idx + 1
	DialogueManager.Instance.StartDialogue(step.dialogue, CompleteCurrentStep)

func SubscribeCombatHandlers() -> void:
	var cm = CombatManager.Instance
	if cm == null:
		return
	UnsubscribeCombatHandlers()
	U.on(cm.OnCombatVictory, OnCombatVictory)
	U.on(cm.OnCombatDefeat, OnCombatDefeat)
	U.on(cm.OnCombatFled, OnCombatFled)

func UnsubscribeCombatHandlers() -> void:
	var cm = CombatManager.Instance
	if cm == null:
		return
	U.off(cm.OnCombatVictory, OnCombatVictory)
	U.off(cm.OnCombatDefeat, OnCombatDefeat)
	U.off(cm.OnCombatFled, OnCombatFled)

func _wait_combat_closed() -> void:
	var cm = CombatManager.Instance
	while cm != null and cm.inCombat:
		await U.frame()
	var ui = CombatUI.Instance
	while ui != null and ui.combatPanel != null and ui.combatPanel.visible:
		await U.frame()

func OnCombatVictory(_e) -> void:
	UnsubscribeCombatHandlers()
	var idx := currentStepIndex
	var g := _act_gen
	await _wait_combat_closed()
	if g == _act_gen and isScenarioActive and currentStepIndex == idx:
		CompleteCurrentStep()

func OnCombatDefeat() -> void:
	UnsubscribeCombatHandlers()
	var g := _act_gen
	if currentScenario != null and not U.empty(currentScenario.retryFlagOnDefeat):
		EndSideScenarioAfterLostCombat(currentScenario, g)
		return
	if currentScenario != null and str(currentScenario.scenarioID).begins_with("ashenveil_day") and SceneEvent.Instance != null:
		WakeUpAfterLostDayFight(g)
		return
	await _wait_combat_closed()
	if g != _act_gen:
		return
	if PlayerStats.Instance != null:
		PlayerStats.Instance.FullRestore()
	if isScenarioActive and currentScenario != null:
		StartNextStep()

func OnCombatFled() -> void:
	UnsubscribeCombatHandlers()
	var g := _act_gen
	if currentScenario != null and not U.empty(currentScenario.retryFlagOnDefeat):
		EndSideScenarioAfterLostCombat(currentScenario, g)
		return
	await _wait_combat_closed()
	if g != _act_gen:
		return
	if PlayerStats.Instance != null:
		PlayerStats.Instance.FullRestore()
	if not isScenarioActive or currentScenario == null:
		return
	_retreatStep = LeadInStep(currentStepIndex)
	currentStepIndex = _retreatStep
	if SceneEvent.Instance != null:
		SceneEvent.Instance.ShowHudPanels()
		SceneEvent.Instance.ShowForegroundMessage(Loc.T("You got away. Rest, change your gear or shop, then come back to the village square from the map to face it again.", "Kaçmayı başardın. Dinlen, ekipmanını değiştir ya da alışveriş yap; hazır olunca haritadan köy meydanına dönüp yeniden yüzleş."), 5.0)
	SaveSystem.SaveGame()

func LeadInStep(fight: int) -> int:
	var steps := _steps()
	for i in range(fight - 1, -1, -1):
		var s = steps[i]
		if s == null or not ScenarioData.StepApplies(s):
			continue
		return i if int(s.type) == ScenarioStepType.Dialogue else fight
	return fight

func ResumeAfterRetreat() -> void:
	if not IsWaitingAfterRetreat:
		return
	_retreatStep = -1
	StartNextStep()

func EndSideScenarioAfterLostCombat(s, g: int) -> void:
	await _wait_combat_closed()
	if g != _act_gen:
		return
	if PlayerStats.Instance != null:
		PlayerStats.Instance.FullRestore()
	AbortScenario()
	StoryFlags.Remove(s.retryFlagOnDefeat)
	if SceneEvent.Instance != null:
		SceneEvent.Instance.ShowHudPanels()
	SaveSystem.SaveGame()

func WakeUpAfterLostDayFight(g: int) -> void:
	await _wait_combat_closed()
	if g != _act_gen:
		return
	if PlayerStats.Instance != null:
		PlayerStats.Instance.FullRestore()
	AbortScenario()
	if SceneEvent.Instance != null:
		SceneEvent.Instance.WakeUpInBedToRetryDay()

func ExecuteCollectItemStep(step) -> void:
	var inv = InventoryManager.Instance
	if inv != null and inv.GetQuantity(step.requiredItem) >= int(step.requiredQuantity):
		inv.RemoveItem(step.requiredItem, int(step.requiredQuantity))
		CompleteCurrentStep()
		return
	WaitForItem(step, currentStepIndex, _act_gen)

func WaitForItem(step, idx: int, g: int) -> void:
	while isScenarioActive and currentStepIndex == idx and g == _act_gen:
		var inv = InventoryManager.Instance
		if inv != null and inv.GetQuantity(step.requiredItem) >= int(step.requiredQuantity):
			inv.RemoveItem(step.requiredItem, int(step.requiredQuantity))
			CompleteCurrentStep()
			return
		await U.wait(0.5)

func WaitStep(dur: float, idx: int, g: int) -> void:
	await U.wait(dur)
	if g == _act_gen and isScenarioActive and currentStepIndex == idx:
		CompleteCurrentStep()

func CompleteScenario() -> void:
	completedScenarios[currentScenario.scenarioID] = true
	var s = currentScenario
	if ProfileManager.Instance != null and int(s.experienceReward) > 0:
		ProfileManager.Instance.AddExperience(int(s.experienceReward))
	if s.currencyRewards != null:
		for r in s.currencyRewards:
			CurrencyReward.Grant(r)
	if s.itemRewards != null and InventoryManager.Instance != null:
		for r in s.itemRewards:
			InventoryManager.Instance.AddItem(r.get("item"), int(r.get("quantity", 1)))
	if s.flagsToSet != null:
		for f in s.flagsToSet:
			StoryFlags.Add(f)
	if s.outroDialogue != null and DialogueManager.Instance != null:
		DialogueManager.Instance.StartDialogue(s.outroDialogue, FinalizeScenario)
	else:
		FinalizeScenario()

func FailScenario() -> void:
	if not isScenarioActive or not currentScenario.canFail:
		return
	StopActiveCoroutine()
	if currentScenario.failureDialogue != null and DialogueManager.Instance != null:
		DialogueManager.Instance.StartDialogue(currentScenario.failureDialogue, FinalizeScenario)
	else:
		FinalizeScenario()

func FinalizeScenario() -> void:
	_retreatStep = -1
	UnsubscribeCombatHandlers()
	OnScenarioComplete.emit(currentScenario)
	currentScenario = null
	currentStepIndex = 0
	isScenarioActive = false
	StopActiveCoroutine()
	SaveSystem.SaveGame()
	if _queuedScenario != null:
		var nx = _queuedScenario
		_queuedScenario = null
		if CanStartScenario(nx):
			StartScenario(nx)

func AbortScenario() -> void:
	if not isScenarioActive:
		return
	StopActiveCoroutine()
	UnsubscribeCombatHandlers()
	_introPending = false
	_pendingStepDialogue = null
	_retreatStep = -1
	var ab = currentScenario
	currentScenario = null
	currentStepIndex = 0
	isScenarioActive = false
	OnScenarioAborted.emit(ab)

func StopActiveCoroutine() -> void:
	_act_gen += 1
	_pendingStepDialogue = null

func IsScenarioCompleted(id) -> bool:
	return completedScenarios.has(str(id))

func GetCompletedScenarios() -> Array:
	return completedScenarios.keys()

func IsScenarioActive() -> bool:
	return isScenarioActive and currentScenario != null

func GetCurrentScenario():
	return currentScenario

func GetCurrentStepIndex() -> int:
	return currentStepIndex

func IsPlayingSequence() -> bool:
	if not isScenarioActive or currentScenario == null:
		return false
	var steps := _steps()
	if currentStepIndex >= steps.size():
		return false
	return int(steps[currentStepIndex].type) == ScenarioStepType.Wait

func SetCompletedScenarios(ids) -> void:
	completedScenarios.clear()
	if ids != null:
		for id in ids:
			completedScenarios[str(id)] = true
