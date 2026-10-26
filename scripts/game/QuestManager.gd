class_name QuestManager
extends Mono

static var Instance: QuestManager
static var OnReady := UEvent.new()
signal OnQuestStarted(quest)
signal OnQuestCompleted(quest)
signal OnQuestFailed(quest)
signal OnQuestAbandoned(quest)
signal OnQuestReadyToComplete(quest)
signal OnObjectiveUpdated(quest, objective)
signal OnObjectiveCompleted(quest, objective)
signal OnTrackingToggleRequested(quest)
signal OnSaveDataRequested(data)
signal OnTrackedQuestsLoaded(ids)

var activeQuests: Array = []
var completedQuests: Array = []
var runtimeStates: Dictionary = {}
var questTimers: Dictionary = {}
var selectedOptionalRewards: Dictionary = {}
var allQuests: Array = []
var maxActiveQuests := 99
var maxDailyQuests := 3

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func Start() -> void:
	OnReady.Invoke()
	if CombatManager.Instance != null:
		U.on(CombatManager.Instance.OnCombatVictory, CheckKillObjectives)
	if InventoryManager.Instance != null:
		U.on(InventoryManager.Instance.OnInventoryChanged, CheckCollectObjectives)
	if CurrencyManager.Instance != null:
		U.on(CurrencyManager.Instance.OnCurrencySpent, CheckSpendObjectives)

func OnDestroy() -> void:
	if Instance == self:
		Instance = null

func Update() -> void:
	var expired := []
	for k in questTimers.keys():
		questTimers[k] -= U.deltaTime
		if questTimers[k] <= 0:
			expired.append(k)
	for id in expired:
		var q = GetActiveQuest(id)
		if q != null:
			FailQuest(q)
		else:
			questTimers.erase(id)

func GetOrCreateRuntimeState(id: String) -> QuestRuntimeState:
	if not runtimeStates.has(id):
		runtimeStates[id] = QuestRuntimeState.new(id)
	return runtimeStates[id]

func GetObjectiveState(questID, objectiveID) -> Dictionary:
	return GetOrCreateRuntimeState(str(questID)).GetObjective(str(objectiveID))

func CanStartQuest(q) -> bool:
	if q == null or U.empty(q.questID):
		return false
	var qt := int(q.questType)
	var done_nonrep: bool = IsQuestCompleted(q.questID) and qt != QuestType.Repeatable and qt != QuestType.Daily
	var dailies := 0
	for a in activeQuests:
		if int(a.questType) == QuestType.Daily:
			dailies += 1
	var daily_full := qt == QuestType.Daily and dailies >= maxDailyQuests
	var low: bool = ProfileManager.Instance != null and ProfileManager.Instance.profile.level < int(q.requiredLevel)
	if IsQuestActive(q.questID) or done_nonrep or activeQuests.size() >= maxActiveQuests or daily_full or low:
		return false
	if q.requiredFlags != null:
		for f in q.requiredFlags:
			if not StoryFlags.Has(f):
				return false
	if q.prerequisiteQuests != null:
		for p in q.prerequisiteQuests:
			if p != null and not IsQuestCompleted(p.questID):
				return false
	return true

func StartQuest(q) -> bool:
	if not CanStartQuest(q):
		return false
	var rs := QuestRuntimeState.new(q.questID)
	for o in GetObjectives(q):
		var st := rs.GetObjective(str(o.objectiveID))
		st.currentProgress = 0
		st.isCompleted = false
	runtimeStates[q.questID] = rs
	activeQuests.append(q)
	if q.flagsToSetOnStart != null:
		for f in q.flagsToSetOnStart:
			StoryFlags.Add(f)
	if q.hasTimeLimit:
		questTimers[q.questID] = float(q.timeLimitSeconds)
	OnQuestStarted.emit(q)
	print("Quest started: ", q.questName)
	SaveSystem.SaveGame()
	return true

func UpdateObjectiveProgress(questID, objectiveID, amount := 1) -> void:
	if amount <= 0:
		return
	var q = GetActiveQuest(questID)
	if q == null:
		return
	var o = GetObjective(q, objectiveID)
	if o == null:
		return
	var st := GetObjectiveState(questID, objectiveID)
	if st.isCompleted:
		return
	st.currentProgress += amount
	var req := QuestData.ObjRequired(o)
	if st.currentProgress >= req:
		st.currentProgress = req
		CompleteObjective(q, o, st)
	else:
		OnObjectiveUpdated.emit(q, o)
	SaveSystem.SaveGame()

func NotifyTalkToNPC(tag, amount := 1) -> void:
	UpdateMatchingObjectives(QuestObjectiveType.TalkToNPC, func(o): return MatchesTag(o.get("npcTag"), tag), amount)

func NotifyLocationReached(tag, amount := 1) -> void:
	UpdateMatchingObjectives(QuestObjectiveType.GoToLocation, func(o): return MatchesTag(o.get("locationTag"), tag), amount)

func NotifyObjectInteracted(tag, amount := 1) -> void:
	UpdateMatchingObjectives(QuestObjectiveType.InteractWithObject, func(o): return MatchesTag(o.get("interactObjectTag"), tag), amount)

func NotifyItemCrafted(item, amount := 1) -> void:
	if item == null:
		return
	UpdateMatchingObjectives(QuestObjectiveType.CraftItems, func(o): return o.get("craftTarget") == item, amount)

func NotifyCustomObjective(id, amount := 1) -> void:
	if U.empty(id):
		return
	UpdateMatchingObjectives(QuestObjectiveType.Custom, func(o): return o.get("objectiveID") == id, amount)

func CompleteObjective(q, o, st: Dictionary) -> void:
	st.isCompleted = true
	OnObjectiveCompleted.emit(q, o)
	if not AreRequiredObjectivesComplete(q):
		return
	if q.autoCompleteWhenObjectivesComplete:
		CompleteQuest(q)
	else:
		OnQuestReadyToComplete.emit(q)

func CompleteQuest(q, selected = null) -> void:
	if selected == null and q != null:
		selected = GetSelectedOptionalReward(q.questID)
	if q == null or not IsQuestActive(q.questID):
		return
	activeQuests.erase(q)
	if int(q.questType) != QuestType.Repeatable and int(q.questType) != QuestType.Daily:
		completedQuests.append(q)
	questTimers.erase(q.questID)
	var opt = ResolveOptionalReward(q, selected)
	GiveQuestRewards(q, opt)
	selectedOptionalRewards.erase(q.questID)
	if q.flagsToSetOnComplete != null:
		for f in q.flagsToSetOnComplete:
			StoryFlags.Add(f)
	OnQuestCompleted.emit(q)
	if q.completeDialogue != null and DialogueManager.Instance != null:
		DialogueManager.Instance.StartDialogue(q.completeDialogue)
	print("Quest completed: ", q.questName)
	SaveSystem.SaveGame()

func GiveQuestRewards(q, opt) -> void:
	if int(q.experienceReward) > 0 and ProfileManager.Instance != null:
		ProfileManager.Instance.AddExperience(int(q.experienceReward))
	if q.currencyRewards != null:
		for r in q.currencyRewards:
			CurrencyReward.Grant(r)
	if q.itemRewards != null and InventoryManager.Instance != null:
		var qty_list = q.itemRewardQuantities
		for i in q.itemRewards.size():
			if q.itemRewards[i] == null:
				continue
			var qty: int = int(qty_list[i]) if qty_list != null and i < qty_list.size() else 1
			InventoryManager.Instance.AddItem(q.itemRewards[i], qty)
	if opt != null and InventoryManager.Instance != null:
		InventoryManager.Instance.AddItem(opt, 1)
	if QuestRewardUI.Instance != null:
		QuestRewardUI.Instance.ShowRewards(q, opt)

func FailQuest(q) -> void:
	if q == null or not IsQuestActive(q.questID):
		return
	if not q.canFail:
		questTimers.erase(q.questID)
		return
	activeQuests.erase(q)
	selectedOptionalRewards.erase(q.questID)
	questTimers.erase(q.questID)
	OnQuestFailed.emit(q)
	if q.failureDialogue != null and DialogueManager.Instance != null:
		DialogueManager.Instance.StartDialogue(q.failureDialogue)
	SaveSystem.SaveGame()

func AbandonQuest(q) -> void:
	if q == null or not IsQuestActive(q.questID):
		return
	activeQuests.erase(q)
	selectedOptionalRewards.erase(q.questID)
	questTimers.erase(q.questID)
	OnQuestAbandoned.emit(q)
	SaveSystem.SaveGame()

func ToggleTracking(q) -> void:
	OnTrackingToggleRequested.emit(q)

func SelectOptionalReward(q, reward) -> bool:
	if q == null or reward == null or not ContainsOptionalReward(q, reward):
		return false
	selectedOptionalRewards[q.questID] = reward
	SaveSystem.SaveGame()
	return true

func GetSelectedOptionalReward(id):
	if U.empty(id):
		return null
	return selectedOptionalRewards.get(id)

func CheckKillObjectives(enemy) -> void:
	if enemy == null:
		return
	for q in activeQuests.duplicate():
		for o in GetObjectives(q):
			if int(o.type) == QuestObjectiveType.KillEnemies and o.get("targetEnemy") == enemy:
				if not GetObjectiveState(q.questID, o.objectiveID).isCompleted:
					UpdateObjectiveProgress(q.questID, o.objectiveID, 1)

func CheckCollectObjectives() -> void:
	for q in activeQuests.duplicate():
		for o in GetObjectives(q):
			if int(o.type) != QuestObjectiveType.CollectItems:
				continue
			var st := GetObjectiveState(q.questID, o.objectiveID)
			var cur: int = InventoryManager.Instance.GetQuantity(o.get("targetItem"))
			var req := QuestData.ObjRequired(o)
			var np := mini(cur, req)
			if not st.isCompleted and np > st.currentProgress:
				UpdateObjectiveProgress(q.questID, o.objectiveID, np - st.currentProgress)
				if GetObjectiveState(q.questID, o.objectiveID).isCompleted and o.get("consumeItems"):
					InventoryManager.Instance.RemoveItem(o.targetItem, int(o.itemCount))
			elif np < st.currentProgress and not o.get("consumeItems") and not st.isCompleted:
				st.currentProgress = np
				OnObjectiveUpdated.emit(q, o)
				SaveSystem.SaveGame()

func CheckSpendObjectives(type: int, amount: int) -> void:
	for q in activeQuests.duplicate():
		for o in GetObjectives(q):
			if int(o.type) == QuestObjectiveType.SpendCurrency and int(o.currencyType) == type:
				if not GetObjectiveState(q.questID, o.objectiveID).isCompleted:
					UpdateObjectiveProgress(q.questID, o.objectiveID, amount)

func GetSaveData() -> Dictionary:
	var data := {"activeQuestIDs": [], "completedQuestIDs": [], "runtimeStates": [], "trackedQuestIDs": [], "questTimerKeys": [], "questTimerValues": [], "selectedOptionalRewardQuestIDs": [], "selectedOptionalRewardItemIDs": []}
	for q in activeQuests:
		data.activeQuestIDs.append(q.questID)
	for q in completedQuests:
		data.completedQuestIDs.append(q.questID)
	for k in runtimeStates:
		data.runtimeStates.append(runtimeStates[k].to_dict())
	for k in questTimers:
		data.questTimerKeys.append(k)
		data.questTimerValues.append(questTimers[k])
	for k in selectedOptionalRewards:
		var r = selectedOptionalRewards[k]
		if r == null or U.empty(r.itemID):
			continue
		data.selectedOptionalRewardQuestIDs.append(k)
		data.selectedOptionalRewardItemIDs.append(r.itemID)
	OnSaveDataRequested.emit(data)
	return data

func LoadSaveData(data) -> void:
	if data == null:
		return
	activeQuests.clear()
	completedQuests.clear()
	runtimeStates.clear()
	questTimers.clear()
	selectedOptionalRewards.clear()
	var lookup := {}
	for q in allQuests:
		if q != null and not U.empty(q.questID):
			lookup[q.questID] = q
	for id in data.get("activeQuestIDs", []):
		if lookup.has(id):
			activeQuests.append(lookup[id])
	for id in data.get("completedQuestIDs", []):
		if lookup.has(id):
			completedQuests.append(lookup[id])
	for st in data.get("runtimeStates", []):
		if st is Dictionary:
			var rs := QuestRuntimeState.from_dict(st)
			runtimeStates[rs.questID] = rs
	var tk: Array = data.get("questTimerKeys", [])
	var tv: Array = data.get("questTimerValues", [])
	for i in mini(tk.size(), tv.size()):
		questTimers[tk[i]] = float(tv[i])
	var rq: Array = data.get("selectedOptionalRewardQuestIDs", [])
	var ri: Array = data.get("selectedOptionalRewardItemIDs", [])
	for i in mini(rq.size(), ri.size()):
		if not lookup.has(rq[i]):
			continue
		var r = ResolveOptionalRewardByID(lookup[rq[i]], ri[i])
		if r != null:
			selectedOptionalRewards[rq[i]] = r
	OnTrackedQuestsLoaded.emit(data.get("trackedQuestIDs", []))

func IsQuestActive(id) -> bool:
	for q in activeQuests:
		if q.questID == id:
			return true
	return false

func IsQuestCompleted(id) -> bool:
	for q in completedQuests:
		if q.questID == id:
			return true
	return false

func GetActiveQuest(id):
	for q in activeQuests:
		if q.questID == id:
			return q
	return null

func GetObjective(q, id):
	for o in GetObjectives(q):
		if o.objectiveID == id:
			return o
	return null

func GetActiveQuests() -> Array:
	return activeQuests.duplicate()

func GetCompletedQuests() -> Array:
	return completedQuests.duplicate()

func GetAvailableQuests() -> Array:
	return allQuests.filter(func(q): return q != null and CanStartQuest(q))

func GetQuestTimeRemaining(id) -> float:
	return questTimers.get(id, 0.0)

func AreRequiredObjectivesComplete(q) -> bool:
	if q == null:
		return false
	for o in GetObjectives(q):
		if not o.get("isOptional") and not GetObjectiveState(q.questID, o.objectiveID).isCompleted:
			return false
	return true

func GetObjectives(q) -> Array:
	if q == null or q.objectives == null:
		return []
	return q.objectives.filter(func(o): return o != null)

func UpdateMatchingObjectives(type: int, pred: Callable, amount: int) -> void:
	if amount <= 0:
		return
	for q in activeQuests.duplicate():
		for o in GetObjectives(q):
			if int(o.type) != type or not pred.call(o):
				continue
			if not GetObjectiveState(q.questID, o.objectiveID).isCompleted:
				UpdateObjectiveProgress(q.questID, o.objectiveID, amount)

func MatchesTag(expected, actual) -> bool:
	return not U.empty(expected) and str(expected) == str(actual)

func ContainsOptionalReward(q, r) -> bool:
	return q.optionalRewards != null and q.optionalRewards.has(r)

func ResolveOptionalReward(q, sel):
	if sel != null and ContainsOptionalReward(q, sel):
		return sel
	if q.optionalRewards != null:
		for r in q.optionalRewards:
			if r != null:
				return r
	return null

func ResolveOptionalRewardByID(q, id):
	if q == null or q.optionalRewards == null or U.empty(id):
		return null
	for r in q.optionalRewards:
		if r != null and r.itemID == id:
			return r
	return null
