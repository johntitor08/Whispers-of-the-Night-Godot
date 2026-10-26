class_name OriginQuestBase
extends Mono

static func TryAutoStartQuest(id: String) -> void:
	if QuestManager.Instance == null:
		return
	for q in QuestManager.Instance.allQuests:
		if q != null and q.questID == id:
			if QuestManager.Instance.CanStartQuest(q):
				QuestManager.Instance.StartQuest(q)
			return

static func UpdateObjective(qid: String, oid: String) -> void:
	if QuestManager.Instance != null:
		QuestManager.Instance.UpdateObjectiveProgress(qid, oid, 1)

static func Flags(list: Array) -> void:
	for f in list:
		StoryFlags.Add(f)

static func CompleteOr(qid: String, flags: Array) -> void:
	var q = QuestManager.Instance.GetActiveQuest(qid) if QuestManager.Instance != null else null
	if q != null:
		QuestManager.Instance.CompleteQuest(q)
	else:
		Flags(flags)
