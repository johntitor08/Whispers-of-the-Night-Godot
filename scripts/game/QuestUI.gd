class_name QuestUI
extends HotkeyPanelUI

static var Instance: QuestUI
var selectedQuest
var questSlots: Array = []
var isSubscribed := false
var rewardCount := 0
var questPanel
var questLogPanel
var questDetailsPanel
var activeQuestsContainer
var availableQuestsContainer
var completedQuestsContainer
var questSlotPrefab
var activeQuestsScrollRect
var availableQuestsScrollRect
var completedQuestsScrollRect
var maxLogPanelWidth := 750.0
var questTitleText
var questDescriptionText
var questTypeText
var questIcon
var objectivesContainer
var objectivePrefab
var rewardsContainer
var rewardItemPrefab
var acceptButton
var abandonButton
var trackButton
var objectivesScrollRect
var rewardsScrollRect
var experienceIcon
var maxDetailsHeight := 300.0
var toggleKey := KEY_Q

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func Start() -> void:
	if questPanel != null:
		U.SetActive(questPanel, false)
	if questDetailsPanel != null:
		U.SetActive(questDetailsPanel, false)
	for pair in [[acceptButton, OnAcceptClicked], [abandonButton, OnAbandonClicked], [trackButton, OnTrackClicked]]:
		if pair[0] != null:
			pair[0].onClick.AddListener(pair[1])
			U.SetActive(pair[0], false)

func OnDestroy() -> void:
	if Instance == self:
		Instance = null

func OnEnable() -> void:
	QuestManager.OnReady.AddListener(TrySubscribe)
	LanguageManager.OnLanguageChanged.AddListener(OnLanguageChanged)
	TrySubscribe()

func OnLanguageChanged(_l) -> void:
	RefreshQuestLog()
	if selectedQuest != null:
		ShowQuestDetails(selectedQuest)

func OnDisable() -> void:
	LanguageManager.OnLanguageChanged.RemoveListener(OnLanguageChanged)
	var qm = QuestManager.Instance
	if isSubscribed and qm != null:
		U.off(qm.OnQuestStarted, _on_q)
		U.off(qm.OnQuestCompleted, _on_q)
		U.off(qm.OnQuestFailed, _on_q)
		U.off(qm.OnQuestAbandoned, _on_q)
		U.off(qm.OnObjectiveUpdated, _on_obj)
		U.off(qm.OnObjectiveCompleted, _on_obj)
		isSubscribed = false
	QuestManager.OnReady.RemoveListener(TrySubscribe)

func TrySubscribe() -> void:
	var qm = QuestManager.Instance
	if qm != null and not isSubscribed:
		U.on(qm.OnQuestStarted, _on_q)
		U.on(qm.OnQuestCompleted, _on_q)
		U.on(qm.OnQuestFailed, _on_q)
		U.on(qm.OnQuestAbandoned, _on_q)
		U.on(qm.OnObjectiveUpdated, _on_obj)
		U.on(qm.OnObjectiveCompleted, _on_obj)
		isSubscribed = true
		RefreshQuestLog()

func _on_q(_q) -> void:
	RefreshQuestLog()

func _on_obj(q, _o) -> void:
	if selectedQuest != null and selectedQuest.questID == q.questID:
		ShowQuestDetails(selectedQuest)

func Update() -> void:
	if PanelInputBlocked():
		return
	if U.GetKeyDown(toggleKey) and questPanel != null:
		var now: bool = not questPanel.visible
		U.SetActive(questPanel, now)
		if questLogPanel != null:
			U.SetActive(questLogPanel, now)
		if now:
			RefreshQuestLog()

func RefreshQuestLog() -> void:
	var qm = QuestManager.Instance
	if qm == null or questSlotPrefab == null:
		return
	for s in questSlots:
		if is_instance_valid(s):
			U.SetActive(s, false)
	var idx := 0
	idx = RefreshSlots(qm.GetActiveQuests(), activeQuestsContainer, false, idx)
	idx = RefreshSlots(qm.GetAvailableQuests(), availableQuestsContainer, false, idx)
	RefreshSlots(qm.GetCompletedQuests(), completedQuestsContainer, true, idx)
	UpdateLogScrollsNextFrame()
	if selectedQuest != null and questDetailsPanel != null and questDetailsPanel.visible:
		ShowQuestDetails(selectedQuest)

func RefreshSlots(quests: Array, parent_go, done: bool, start: int) -> int:
	if parent_go == null:
		return start
	var idx := start
	for q in quests:
		var slot
		if idx < questSlots.size():
			slot = questSlots[idx]
			if slot.gameObject.get_parent() != parent_go:
				U.SetParent(slot.gameObject, parent_go)
		else:
			slot = U.Instantiate(questSlotPrefab, parent_go)
			questSlots.append(slot)
		U.SetActive(slot, true)
		slot.Setup(q, done)
		idx += 1
	return idx

func UpdateLogScrollsNextFrame() -> void:
	await U.frame()
	UpdateHorizontalScrollRect(activeQuestsContainer, activeQuestsScrollRect, maxLogPanelWidth)
	UpdateHorizontalScrollRect(availableQuestsContainer, availableQuestsScrollRect, maxLogPanelWidth)
	UpdateHorizontalScrollRect(completedQuestsContainer, completedQuestsScrollRect, maxLogPanelWidth)

func ShowQuestDetails(q) -> void:
	var qm = QuestManager.Instance
	if qm == null or q == null:
		return
	selectedQuest = q
	if questDetailsPanel != null:
		U.SetActive(questDetailsPanel, true)
	if questTitleText != null:
		questTitleText.text = q.DisplayName
	if questDescriptionText != null:
		questDescriptionText.text = q.DisplayDescription
	if questTypeText != null:
		questTypeText.text = BuildQuestInfo(q, qm)
	if questIcon != null:
		questIcon.sprite = q.icon
	if objectivesContainer != null and objectivePrefab != null:
		ClearContainer(objectivesContainer)
		for o in qm.GetObjectives(q):
			var ui = U.Instantiate(objectivePrefab, objectivesContainer)
			ui.Setup(o, qm.GetObjectiveState(q.questID, o.objectiveID))
	PopulateRewards(q)
	if rewardsScrollRect != null:
		U.SetActive(rewardsScrollRect, rewardCount > 0)
	var active: bool = qm.IsQuestActive(q.questID)
	var done: bool = qm.IsQuestCompleted(q.questID)
	var tracked: bool = QuestTrackerUI.Instance != null and QuestTrackerUI.Instance.IsTracked(q.questID)
	if acceptButton != null and abandonButton != null:
		U.SetActive(acceptButton, not active and not done)
		U.SetActive(abandonButton, active)
	if trackButton != null:
		U.SetActive(trackButton, active)
		var lbl = trackButton.GetComponentInChildren(UText)
		if lbl != null:
			lbl.text = Loc.T("Untrack", "Takibi Bırak") if tracked else Loc.T("Track", "Takip Et")
	UpdateDetailsScrollsNextFrame()

func BuildQuestInfo(q, qm) -> String:
	var label := "<color=%s>" % UIPalette.Hex(UIPalette.Muted)
	var total := 0
	var done := 0
	for o in qm.GetObjectives(q):
		total += 1
		if qm.GetObjectiveState(q.questID, o.objectiveID).isCompleted:
			done += 1
	var s := "%s%s:</color> %s      " % [label, Loc.T("Type", "Tür"), QuestData.TypeName(int(q.questType))]
	s += "%s%s:</color> %s" % [label, Loc.T("Difficulty", "Zorluk"), QuestData.DifficultyName(int(q.difficulty))]
	s += "\n%s%s:</color> %d      " % [label, Loc.T("Level", "Seviye"), int(q.requiredLevel)]
	s += "%s%s:</color> %d/%d" % [label, Loc.T("Objectives", "Hedefler"), done, total]
	var rewards := []
	if int(q.experienceReward) > 0:
		rewards.append("%d XP" % int(q.experienceReward))
	if q.currencyRewards != null:
		for r in q.currencyRewards:
			rewards.append("%d %s" % [int(r.amount), CurrencyName(int(r.type))])
	var items := 0
	if q.itemRewards != null:
		for it in q.itemRewards:
			if it != null:
				items += 1
	if items > 0:
		rewards.append(Loc.T("1 item" if items == 1 else "%d items" % items, "%d eşya" % items))
	if not rewards.is_empty():
		s += "\n%s%s:</color> %s" % [label, Loc.T("Reward", "Ödül"), "  ·  ".join(rewards)]
	return s

static func CurrencyName(t: int) -> String:
	match t:
		CurrencyType.Gold:
			return Loc.T("Gold", "Altın")
		CurrencyType.Gems:
			return Loc.T("Gems", "Mücevher")
		CurrencyType.Tokens:
			return Loc.T("Tokens", "Jeton")
	return Loc.T("Credits", "Kredi")

func UpdateDetailsScrollsNextFrame() -> void:
	await U.frame()
	UpdateVerticalScrollRect(objectivesContainer, objectivesScrollRect, maxDetailsHeight)
	UpdateVerticalScrollRect(rewardsContainer, rewardsScrollRect, maxDetailsHeight)

func UpdateHorizontalScrollRect(content, sr, threshold: float) -> void:
	if sr == null or content == null or not is_instance_valid(sr):
		return
	var needs: bool = content.size.x > threshold
	sr.vertical = false
	sr.horizontal = needs
	if not needs:
		sr.horizontalScrollbar = null
	sr.horizontalNormalizedPosition = 0.0

func UpdateVerticalScrollRect(content, sr, threshold: float) -> void:
	if sr == null or content == null or not is_instance_valid(sr):
		return
	ES.rebuild_layout()
	var vh: float = sr.viewport.size.y if sr.viewport != null else threshold
	var needs: bool = content.size.y > vh + 1.0
	sr.horizontal = false
	sr.vertical = needs
	if not needs:
		sr.verticalScrollbar = null
	sr.verticalNormalizedPosition = 1.0

func OnAcceptClicked() -> void:
	if selectedQuest == null or QuestManager.Instance == null:
		return
	QuestManager.Instance.StartQuest(selectedQuest)
	selectedQuest = null
	RefreshQuestLog()
	if questDetailsPanel != null:
		U.SetActive(questDetailsPanel, false)

func OnAbandonClicked() -> void:
	if selectedQuest == null or QuestManager.Instance == null:
		return
	QuestManager.Instance.AbandonQuest(selectedQuest)
	selectedQuest = null
	RefreshQuestLog()
	if questDetailsPanel != null:
		U.SetActive(questDetailsPanel, false)

func OnTrackClicked() -> void:
	if selectedQuest == null or QuestManager.Instance == null:
		return
	QuestManager.Instance.ToggleTracking(selectedQuest)
	ShowQuestDetails(selectedQuest)

func CloseQuestPanel() -> void:
	UIPanelAnimator.Hide(questPanel)
	UIPanelAnimator.Hide(questDetailsPanel)

func PopulateRewards(q) -> void:
	if rewardsContainer == null or rewardItemPrefab == null:
		return
	ClearContainer(rewardsContainer)
	rewardCount = 0
	if int(q.experienceReward) > 0:
		SpawnRewardItem(Loc.T("Experience", "Deneyim"), str(int(q.experienceReward)), experienceIcon)
	if q.currencyRewards != null:
		for r in q.currencyRewards:
			var info = CurrencyManager.Instance.GetCurrencyInfo(int(r.type)) if CurrencyManager.Instance != null else null
			SpawnRewardItem(CurrencyType.name_of(int(r.type)), str(int(r.amount)), info.icon if info != null else null)
	if q.itemRewards != null:
		for i in q.itemRewards.size():
			var it = q.itemRewards[i]
			if it == null:
				continue
			var ql = q.itemRewardQuantities
			var qty: int = int(ql[i]) if ql != null and i < ql.size() else 1
			SpawnRewardItem(it.DisplayName, "x%d" % qty, it.icon)
	if q.optionalRewards != null:
		var qm = QuestManager.Instance
		var can_sel: bool = qm != null and qm.IsQuestActive(q.questID)
		var sel = qm.GetSelectedOptionalReward(q.questID) if qm != null else null
		for it in q.optionalRewards:
			if it == null:
				continue
			var reward = it
			var is_sel: bool = sel == reward
			var v := (Loc.T("Selected", "Seçildi") if is_sel else Loc.T("Choose", "Seç")) if can_sel else "x1"
			var cb = null
			if can_sel:
				cb = func():
					if QuestManager.Instance != null and QuestManager.Instance.SelectOptionalReward(q, reward):
						ShowQuestDetails(q)
			SpawnRewardItem("%s (%s)" % [reward.DisplayName, Loc.T("Optional", "İsteğe bağlı")], v, reward.icon, cb, is_sel)

func SpawnRewardItem(label: String, value: String, icon, cb = null, sel := false) -> void:
	rewardCount += 1
	var ui = U.Instantiate(rewardItemPrefab, rewardsContainer)
	ui.Setup(label, value, icon, cb, sel)

func ClearContainer(c) -> void:
	if c == null:
		return
	for k in U.kids(c):
		U.Destroy(k)
