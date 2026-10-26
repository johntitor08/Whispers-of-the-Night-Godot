class_name QuestTrackerEntry
extends Mono

var questNameText
var objectivesContainer
var objectiveTextPrefab
var scrollRect
var objectiveTexts: Array = []
const maxVisibleRows := 4
const objectiveTextHeight := 50

func Setup(q) -> void:
	if QuestManager.Instance == null:
		return
	if questNameText != null:
		questNameText.text = q.DisplayName
	var inc := []
	for o in q.objectives:
		var st = QuestManager.Instance.GetObjectiveState(q.questID, o.objectiveID)
		if not st.isCompleted:
			inc.append([o, st])
	var count := inc.size()
	while objectiveTexts.size() < count and objectiveTextPrefab != null and objectivesContainer != null:
		objectiveTexts.append(U.Instantiate(objectiveTextPrefab, objectivesContainer))
	for i in objectiveTexts.size():
		if i < count:
			var o = inc[i][0]
			var st = inc[i][1]
			objectiveTexts[i].text = "- %s (%d/%d)" % [QuestData.ObjDesc(o), int(st.currentProgress), QuestData.ObjRequired(o)]
			U.SetActive(objectiveTexts[i], true)
		else:
			U.SetActive(objectiveTexts[i], false)
	var needs := count > maxVisibleRows
	var vis := float(maxVisibleRows * objectiveTextHeight) if needs else float(count * objectiveTextHeight)
	if scrollRect != null:
		scrollRect.horizontal = false
		scrollRect.vertical = needs
		if not needs:
			scrollRect.verticalScrollbar = null
		scrollRect.verticalNormalizedPosition = 1.0
		var sgo = scrollRect.gameObject
		sgo.sizeDelta = Vector2(sgo.sizeDelta.x, vis)
	var self_go = gameObject
	var rows := maxVisibleRows if count > maxVisibleRows else count
	self_go.sizeDelta = Vector2(self_go.sizeDelta.x, rows * objectiveTextHeight + 100.0)
