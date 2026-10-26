class_name QuestTrackerUI
extends Mono

static var Instance: QuestTrackerUI
var trackedQuestIDs: Array = []
var trackerEntries: Dictionary = {}
var isSubscribed := false
var trackerPanel
var trackedQuestsContainer
var trackerEntryPrefab
var maxTrackedQuests := 99
var closeButton
var autoTrackNewQuests := true
var persistAcrossScenes := false
var isPanelHiddenByUser := false
var parentScrollRect
var maxParentHeight := 700.0

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func Start() -> void:
	if closeButton != null:
		closeButton.onClick.AddListener(OnCloseClicked)

func OnDestroy() -> void:
	if Instance == self:
		Instance = null

func OnEnable() -> void:
	QuestManager.OnReady.AddListener(TrySubscribe)
	LanguageManager.OnLanguageChanged.AddListener(_on_lang)
	TrySubscribe()

func _on_lang(_l) -> void:
	RefreshEntries()

func OnDisable() -> void:
	var qm = QuestManager.Instance
	if isSubscribed and qm != null:
		U.off(qm.OnQuestStarted, OnQuestStarted)
		U.off(qm.OnQuestCompleted, _untrack_q)
		U.off(qm.OnQuestFailed, _untrack_q)
		U.off(qm.OnObjectiveUpdated, _refresh2)
		U.off(qm.OnObjectiveCompleted, _refresh2)
		U.off(qm.OnTrackingToggleRequested, ToggleQuest)
		U.off(qm.OnSaveDataRequested, OnSaveDataRequested)
		U.off(qm.OnTrackedQuestsLoaded, OnTrackedQuestsLoaded)
		U.off(qm.OnQuestAbandoned, _untrack_q)
		isSubscribed = false
	QuestManager.OnReady.RemoveListener(TrySubscribe)
	LanguageManager.OnLanguageChanged.RemoveListener(_on_lang)

func TrySubscribe() -> void:
	var qm = QuestManager.Instance
	if qm != null and not isSubscribed:
		U.on(qm.OnQuestStarted, OnQuestStarted)
		U.on(qm.OnQuestCompleted, _untrack_q)
		U.on(qm.OnQuestFailed, _untrack_q)
		U.on(qm.OnObjectiveUpdated, _refresh2)
		U.on(qm.OnObjectiveCompleted, _refresh2)
		U.on(qm.OnTrackingToggleRequested, ToggleQuest)
		U.on(qm.OnSaveDataRequested, OnSaveDataRequested)
		U.on(qm.OnTrackedQuestsLoaded, OnTrackedQuestsLoaded)
		U.on(qm.OnQuestAbandoned, _untrack_q)
		isSubscribed = true
		UpdateTracker()

func OnQuestStarted(q) -> void:
	if autoTrackNewQuests and q.trackObjectives:
		TrackQuest(q.questID)

func _untrack_q(q) -> void:
	UntrackQuest(q.questID)

func _refresh2(_q, _o) -> void:
	RefreshEntries()

func OnSaveDataRequested(data) -> void:
	data.trackedQuestIDs = trackedQuestIDs.duplicate()

func OnTrackedQuestsLoaded(ids) -> void:
	if ids == null:
		return
	var qm = QuestManager.Instance
	trackedQuestIDs.clear()
	for id in ids:
		if qm != null and qm.GetActiveQuest(id) != null and trackedQuestIDs.size() < maxTrackedQuests and not trackedQuestIDs.has(id):
			trackedQuestIDs.append(str(id))
	UpdateTracker()

func IsTracked(id) -> bool:
	return trackedQuestIDs.has(id)

func ToggleQuest(q) -> void:
	if IsTracked(q.questID):
		UntrackQuest(q.questID)
	else:
		TrackQuest(q.questID)

func TrackQuest(id) -> bool:
	if trackedQuestIDs.size() >= maxTrackedQuests:
		return false
	var qm = QuestManager.Instance
	if qm == null or qm.GetActiveQuest(id) == null or trackedQuestIDs.has(id):
		return false
	trackedQuestIDs.append(str(id))
	isPanelHiddenByUser = false
	UpdateTracker()
	return true

func UntrackQuest(id) -> void:
	if not trackedQuestIDs.has(id):
		return
	trackedQuestIDs.erase(id)
	UpdateTracker()

func SetTrackedQuests(ids) -> void:
	OnTrackedQuestsLoaded(ids)

func GetTrackedQuests() -> Array:
	return trackedQuestIDs.duplicate()

func OnCloseClicked() -> void:
	isPanelHiddenByUser = true
	if trackerPanel != null:
		U.SetActive(trackerPanel, false)

func UpdateTracker() -> void:
	for id in trackerEntries.keys():
		if not trackedQuestIDs.has(id):
			if is_instance_valid(trackerEntries[id]):
				U.Destroy(trackerEntries[id].gameObject)
			trackerEntries.erase(id)
	for id in trackedQuestIDs:
		if QuestManager.Instance == null:
			break
		var q = QuestManager.Instance.GetActiveQuest(id)
		if q == null:
			continue
		if not trackerEntries.has(id):
			if trackerEntryPrefab == null:
				continue
			trackerEntries[id] = U.Instantiate(trackerEntryPrefab, trackedQuestsContainer)
		trackerEntries[id].Setup(q)
	if trackerPanel != null:
		U.SetActive(trackerPanel, not isPanelHiddenByUser and trackedQuestIDs.size() > 0)
	UpdateParentScrollNextFrame()

func RefreshEntries() -> void:
	var orphaned := []
	var qm = QuestManager.Instance
	for id in trackerEntries:
		var entry = trackerEntries[id]
		if not is_instance_valid(entry):
			orphaned.append(id)
			continue
		var q = qm.GetActiveQuest(id) if qm != null else null
		if q != null:
			entry.Setup(q)
		else:
			orphaned.append(id)
	if not orphaned.is_empty():
		for id in orphaned:
			trackedQuestIDs.erase(id)
		UpdateTracker()

func UpdateParentScrollNextFrame() -> void:
	await U.frame()
	if parentScrollRect == null or not is_instance_valid(parentScrollRect):
		return
	ES.rebuild_layout()
	parentScrollRect.horizontal = false
	parentScrollRect.vertical = true
	parentScrollRect.verticalNormalizedPosition = 1.0
