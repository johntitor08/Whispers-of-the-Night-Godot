class_name AshenveilQuestFactory
extends Mono

static var _instance: AshenveilQuestFactory
const Q10 := "q10_acik_hesap"
var _builtQuests: Array = []
var _scenarioHooked
var assets

func Awake() -> void:
	_instance = self

func OnDestroy() -> void:
	if QuestManager.Instance != null:
		U.off(QuestManager.Instance.OnQuestCompleted, HandleQuestCompleted)
		U.off(QuestManager.Instance.OnObjectiveCompleted, HandleObjectiveCompleted)
	if _scenarioHooked != null:
		U.off(_scenarioHooked.OnStepComplete, HandleScenarioStepComplete)
	if _instance == self:
		_instance = null

func Start() -> void:
	if QuestManager.Instance == null:
		return
	BuildAllQuests()
	ApplySequentialGating()
	InjectIntoQuestManager()
	TryAutoStartAvailableQuests()
	U.on(QuestManager.Instance.OnQuestCompleted, HandleQuestCompleted)
	U.on(QuestManager.Instance.OnObjectiveCompleted, HandleObjectiveCompleted)
	_scenarioHooked = ScenarioManager.Instance
	if _scenarioHooked != null:
		U.on(_scenarioHooked.OnStepComplete, HandleScenarioStepComplete)
	CheckWarehouseCleared()

func HandleQuestCompleted(_q) -> void:
	TryAutoStartAvailableQuests()

func HandleObjectiveCompleted(q, _o) -> void:
	if q != null and q.questID == Q10:
		CheckWarehouseCleared()

static func CheckWarehouseCleared() -> void:
	var qm = QuestManager.Instance
	if qm == null or StoryFlags.Has(QuestFlags.Q10WarehouseCleared) or not qm.IsQuestActive(Q10):
		return
	if qm.GetObjectiveState(Q10, "q10_obj1").isCompleted and qm.GetObjectiveState(Q10, "q10_obj2").isCompleted:
		StoryFlags.Add(QuestFlags.Q10WarehouseCleared)

func HandleScenarioStepComplete(step) -> void:
	var cur = _scenarioHooked.GetCurrentScenario() if _scenarioHooked != null else null
	if step == null or cur == null or cur.scenarioID != "ashenveil_day3" or QuestManager.Instance == null:
		return
	if step.stepName == "d3_confront":
		QuestManager.Instance.UpdateObjectiveProgress(Q10, "q10_obj3")
	elif step.stepName == "d3_voss":
		QuestManager.Instance.UpdateObjectiveProgress(Q10, "q10_obj4")

func ApplySequentialGating() -> void:
	var order := ["q01_bir_fincan_huzur", "q02_hala_duman", "q03_kirik_muhur", "q04_yasli_adamin_itirafi", "q05_acik_el", "q06_tarif_defteri", "q07_corvinin_borcu", "q08_defterdeki_sesler", "q09_bekleyis", "q10_acik_hesap", "q11_fincan_basinda"]
	for i in range(1, order.size()):
		var prev = _find(order[i - 1])
		var cur = _find(order[i])
		if prev == null or cur == null or prev.flagsToSetOnComplete == null or prev.flagsToSetOnComplete.is_empty():
			continue
		cur.d.requiredFlags = [prev.flagsToSetOnComplete[0]]

func _find(id: String):
	for q in _builtQuests:
		if q.questID == id:
			return q
	return null

static func OnOriginApplied() -> void:
	if _instance != null and is_instance_valid(_instance):
		_instance.TryAutoStartAvailableQuests()

func BuildAllQuests() -> void:
	_builtQuests = [BuildQuest1(), BuildQuest2(), BuildQuest3(), BuildQuest4(), BuildQuest5(), BuildQuest6(), BuildQuest7(), BuildQuest8(), BuildQuest9(), BuildQuest10(), BuildQuest11(), BuildSinnedGuardianQuest1(), BuildBoundArchivistQuest1(), BuildForeignEchoQuest1()]

func InjectIntoQuestManager() -> void:
	var existing: Array = QuestManager.Instance.allQuests.duplicate()
	for q in _builtQuests:
		var dup := false
		for e in existing:
			if e != null and e.questID == q.questID:
				dup = true
				break
		if not dup:
			existing.append(q)
	QuestManager.Instance.allQuests = existing

func TryAutoStartAvailableQuests() -> void:
	for q in _builtQuests:
		if QuestManager.Instance.CanStartQuest(q):
			QuestManager.Instance.StartQuest(q)

func A(field: String):
	return assets.get(field) if assets != null else null

func Make(id: String, n: String, desc: String, type: int, required := [], on_start := [], on_complete := [], time_limit := false, secs := 0.0, can_fail := false) -> QuestData:
	var q := QuestData.make()
	q.d.questID = id
	q.d.questName = n
	q.d.description = desc
	q.d.questNameTR = AshenveilQuestTR.NameTR(id)
	q.d.descriptionTR = AshenveilQuestTR.DescTR(id)
	q.d.questType = type
	q.d.difficulty = QuestDifficulty.Normal
	q.d.requiredFlags = required
	q.d.flagsToSetOnStart = on_start
	q.d.flagsToSetOnComplete = on_complete
	q.d.hasTimeLimit = 1 if time_limit else 0
	q.d.timeLimitSeconds = secs
	q.d.canFail = 1 if can_fail else 0
	q.d.trackObjectives = 1
	q.d.autoCompleteWhenObjectivesComplete = 1
	q.d.showOnMap = 1
	q.d.icon = assets.GetQuestIcon(id) if assets != null else null
	q.d.name = id
	return q

static func Interact(id: String, desc: String, tag := "", optional := false) -> Dictionary:
	var o := QuestData.NewObjective(id, desc, QuestObjectiveType.InteractWithObject)
	o.descriptionTR = AshenveilQuestTR.ObjTR(id)
	o.interactObjectTag = id if tag == "" else tag
	o.isOptional = 1 if optional else 0
	return o

static func Talk(id: String, desc: String, tag := "", count := 1, optional := false) -> Dictionary:
	var o := QuestData.NewObjective(id, desc, QuestObjectiveType.TalkToNPC)
	o.descriptionTR = AshenveilQuestTR.ObjTR(id)
	o.npcTag = id if tag == "" else tag
	o.targetCount = count
	o.isOptional = 1 if optional else 0
	return o

static func Collect(id: String, desc: String, item, count: int, consume := false) -> Dictionary:
	var o := QuestData.NewObjective(id, desc, QuestObjectiveType.CollectItems)
	o.descriptionTR = AshenveilQuestTR.ObjTR(id)
	o.targetItem = item
	o.itemCount = count
	o.consumeItems = 1 if consume else 0
	return o

static func Kill(id: String, desc: String, enemy, count: int) -> Dictionary:
	var o := QuestData.NewObjective(id, desc, QuestObjectiveType.KillEnemies)
	o.descriptionTR = AshenveilQuestTR.ObjTR(id)
	o.targetEnemy = enemy
	o.targetCount = count
	return o

static func TwoDaySeconds() -> float:
	var pd: float = TimePhaseManager.Instance.phaseDuration if TimePhaseManager.Instance != null else 300.0
	return pd * 4.0 * 2.0

func _rewards(q: QuestData, items: Array, qty: Array, xp: int) -> QuestData:
	var it := []
	var qq := []
	for i in items.size():
		it.append(items[i])
		qq.append(qty[i] if i < qty.size() else 1)
	q.d.itemRewards = it if assets != null else []
	q.d.itemRewardQuantities = qq
	q.d.experienceReward = xp
	return q

func BuildQuest1() -> QuestData:
	var q := Make("q01_bir_fincan_huzur", "A Cup of Peace", "Maren called for you early in the morning.", QuestType.Side, [], [], [QuestFlags.MarenTeaServed])
	q.d.objectives = [Collect("q01_obj1", "Pick 1 Fresh Apple from the garden", A("freshApple"), 1), Collect("q01_obj2", "Take 1 Cinnamon from the kitchen shelf", A("cinnamon"), 1), Interact("q01_obj3", "Brew the tea at the stove"), Interact("q01_obj4", "Give Maren the cup (use it from your inventory)")]
	return _rewards(q, [A("marenNecklace")], [1], 50)

func BuildQuest2() -> QuestData:
	var q := Make("q02_hala_duman", "Still Smoke", "Maren told you that three houses have been emptied.", QuestType.Side, [], [], [QuestFlags.StillSmokeDone])
	q.d.objectives = [Interact("q02_obj1", "Search the blacksmith's house (Torn Contract)"), Interact("q02_obj2", "Search the baker's house (Torn Contract)"), Interact("q02_obj3", "Search the healer's house (Torn Contract)"), Kill("q02_obj4", "Kill 2 Shadow Lurkers outside the village", A("shadowLurker"), 2), Talk("q02_obj5", "Speak with old Corvin")]
	return _rewards(q, [A("rustedKey"), A("blacksmithApron")], [1, 1], 80)

func BuildQuest3() -> QuestData:
	var q := Make("q03_kirik_muhur", "Broken Seal", "The contract in the healer's house is missing a piece.", QuestType.Side, [], [], [QuestFlags.MissingContractFound])
	q.d.objectives = [Talk("q03_obj1", "Talk to 3 different NPCs in the village", "", 3), Interact("q03_obj2", "Follow the hidden trail in the village square"), Interact("q03_obj3", "Find the box behind the barn")]
	return _rewards(q, [A("missingContract"), A("villageCoat")], [1, 1], 60)

func BuildQuest4() -> QuestData:
	var q := Make("q04_yasli_adamin_itirafi", "The Old Man's Confession", "Corvin is waiting for you in the evening.", QuestType.Main, [QuestFlags.StillSmokeDone], [], [QuestFlags.ElderTruthKnown, QuestFlags.VossContractPlayerAware])
	q.d.objectives = [Talk("q04_obj1", "Listen to Corvin"), Interact("q04_obj2", "Find the old square fountain"), Interact("q04_obj3", "Take the hidden document beneath the fountain")]
	return _rewards(q, [A("vossDiary")], [1], 120)

func BuildQuest5() -> QuestData:
	var q := Make("q05_acik_el", "Open Hand", "The first name in the ledger is at the mill. Find and rescue the captive.", QuestType.Main, [QuestFlags.ElderTruthKnown], [], [QuestFlags.FirstPrisonerRescued], true, TwoDaySeconds(), true)
	q.d.objectives = [Interact("q05_obj1", "Investigate the village mill"), Interact("q05_obj2", "Go to the cave the miller spoke of"), Kill("q05_obj3", "Kill the 3 Shadow Guards in the cave", A("shadowGuard"), 3), Interact("q05_obj4", "Rescue the captive in the cave"), Interact("q05_obj5", "Take the captive back to the village")]
	q.d.experienceReward = 200
	return q

func BuildQuest6() -> QuestData:
	var q := Make("q06_tarif_defteri", "The Recipe Book", "The rescued captive wants to give Maren an old recipe.", QuestType.Side, [QuestFlags.FirstPrisonerRescued], [], [QuestFlags.MarenRecipeGiven])
	q.d.objectives = [Collect("q06_obj1", "Find the Recipe Page in the field", A("recipePage"), 1), Talk("q06_obj2", "Take the recipe to Maren")]
	return _rewards(q, [A("applePie")], [1], 80)

func BuildQuest7() -> QuestData:
	var q := Make("q07_corvinin_borcu", "Corvin's Debt", "After finding the missing contract, Corvin called for you.", QuestType.Side, [QuestFlags.MissingContractFound], [], [QuestFlags.CorvinDebtSettled])
	q.d.objectives = [Interact("q07_obj1", "Go to the old church ruins"), Kill("q07_obj2", "Kill the 3 Cursed Guards in the ruins", A("cursedGuard"), 3), Interact("q07_obj3", "Open the chest (Rusted Key required)"), Collect("q07_obj4", "Bring the document from the chest to Corvin", A("corvinsDocument"), 1)]
	return _rewards(q, [A("corvinSeal")], [1], 150)

func BuildQuest8() -> QuestData:
	var q := Make("q08_defterdeki_sesler", "Voices in the Ledger", "In the evening, a stranger approached the one carrying Voss's ledger.", QuestType.Side, [QuestFlags.VossContractPlayerAware], [], [QuestFlags.VossWeakPointKnown])
	q.d.objectives = [Talk("q08_obj1", "Speak with the mysterious NPC"), Interact("q08_obj2", "Find the symbol they described in the village"), Interact("q08_obj3", "Press Corvin's Seal onto the symbol", "", true)]
	q.d.experienceReward = 100
	return q

func BuildQuest9() -> QuestData:
	var q := Make("q09_bekleyis", "The Wait", "Wait for Voss at the village entrance at night.", QuestType.Main, [QuestFlags.ElderTruthKnown], [], [QuestFlags.Q09VossWarehouseFound])
	q.d.objectives = [Interact("q09_obj1", "Wait for Voss at the village entrance"), Interact("q09_obj2", "Don't buy anything from Voss's stall", "", true), Interact("q09_obj3", "Follow Voss"), Interact("q09_obj4", "Find Voss's hidden warehouse")]
	q.d.experienceReward = 120
	return q

func BuildQuest10() -> QuestData:
	var q := Make("q10_acik_hesap", "Open Account", "You've entered Voss's warehouse. Take out the guards and free the captives. Then Voss will come for you.", QuestType.Main, [QuestFlags.ElderTruthKnown, QuestFlags.Q09VossWarehouseFound], [], [QuestFlags.VossDefeatedClean])
	q.d.objectives = [Kill("q10_obj1", "Kill the 3 Shadow Guards in the warehouse", A("shadowGuard"), 3), Interact("q10_obj2", "Free the captives in the cages"), Talk("q10_obj3", "Return to the village square to confront Voss"), Kill("q10_obj4", "Defeat Voss (boss)", A("vossBoss"), 1)]
	q.d.experienceReward = 500
	return q

func BuildQuest11() -> QuestData:
	var q := Make("q11_fincan_basinda", "Over a Cup", "In the morning, Maren is waiting at your door.", QuestType.Side, [QuestFlags.VossDefeatedClean], [], [QuestFlags.ScenarioCompleted])
	q.d.objectives = [Talk("q11_obj1", "Talk with Maren"), Interact("q11_obj2", "Go to the garden together"), Interact("q11_obj3", "Drink one last cup of apple tea")]
	q.d.experienceReward = 0
	q.d.currencyRewards = []
	q.d.itemRewards = []
	return q

func BuildSinnedGuardianQuest1() -> QuestData:
	var q := Make(QuestIds.Q_SG01, "The Debt That Breathes", "Three families. Three names on a list. Your hand, your choice. Shadow Garden believes they are still reachable — held somewhere east of Dragsimo.", QuestType.Main, [QuestFlags.SinnedGuardianStart], [], [QuestFlags.ThreeFamiliesLocated, QuestFlags.ShadowGardenRank1])
	q.d.objectives = [Talk("q_sg01_obj1", "Speak with Maren at night"), Talk("q_sg01_obj2", "Meet Aslude at the well"), Talk("q_sg01_obj3", "Speak with Corvin (optional)", "", 1, true), Interact("q_sg01_obj4", "Learn the village's western edge (2 of 3 locations)"), Interact("q_sg01_obj5", "Track Voss from the western road"), Talk("q_sg01_obj6", "Speak with Voss"), Interact("q_sg01_obj7", "Find the second wall east of Dragsimo and see what it hides"), Talk("q_sg01_obj9", "Return to Aslude with the discovery")]
	var r := []
	var qty := []
	if A("corvinSeal") != null:
		r.append(A("corvinSeal"))
		qty.append(1)
	if A("corvinsTestimony") != null:
		r.append(A("corvinsTestimony"))
		qty.append(1)
	q.d.itemRewards = r
	q.d.itemRewardQuantities = qty
	q.d.experienceReward = 420
	return q

func BuildBoundArchivistQuest1() -> QuestData:
	var q := Make(QuestIds.Q_BA01, "The Reversal Clause", "The file Brahma left behind carries the trail of a lost record. Start with Maren — Ashenveil's past is asked of her.", QuestType.Main, [QuestFlags.BoundArchivistStart], [], [QuestFlags.BoundArchivistQuest1Done])
	q.d.objectives = [Talk("obj_speak_maren_gate", "Speak with Maren at the gate"), Talk("obj_learn_maren_knowledge", "Learn the past in Maren's kitchen"), Talk("obj_find_elis", "Find Elis and learn the three locations", "", 1, true), Talk("obj_handle_eow_operative", "Deal with the EoW operative"), Talk("obj_speak_voss_day3", "Speak with Voss on day 3"), Interact("obj_cross_reference", "Narrow down the record's location by cross-reference")]
	q.d.experienceReward = 380
	return q

func BuildForeignEchoQuest1() -> QuestData:
	var q := Make(QuestIds.Q_FE01, "The Originating Record", "The Axios anomaly drew you to Ashenveil. Follow the shadow at Maren's door — no one knows what lies inside the chamber.", QuestType.Main, [QuestFlags.ForeignEchoStart], [], [QuestFlags.ForeignEchoQuest1Done, QuestFlags.ChamberInteriorSeen])
	q.d.objectives = [Interact("obj_follow_shadow_maren", "Follow the shadow at Maren's door"), Talk("obj_understand_maren_need", "Understand Maren's mission"), Talk("obj_speak_mireya", "Speak with Mireya — get the patrol data", "", 1, true), Talk("obj_meet_chico", "Meet with Chico", "", 1, true), Talk("obj_speak_voss_day3", "Speak with Voss on day 3"), Interact("obj_identify_axios_anomaly", "Identify the record source on the chamber floor")]
	if A("axiosCrystal") != null:
		q.d.itemRewards = [A("axiosCrystal")]
		q.d.itemRewardQuantities = [1]
	q.d.experienceReward = 360
	return q
