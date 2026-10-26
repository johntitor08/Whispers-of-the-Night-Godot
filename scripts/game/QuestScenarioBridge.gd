class_name QuestScenarioBridge
extends Mono

var branches: Array = []
var _sm

func Start() -> void:
	TryHook()

func OnEnable() -> void:
	StoryFlags.OnFlagAdded.AddListener(OnFlagAdded)
	TryHook()

func OnDisable() -> void:
	StoryFlags.OnFlagAdded.RemoveListener(OnFlagAdded)
	if _sm != null:
		U.off(_sm.OnStepComplete, OnStepComplete)
		_sm = null

func TryHook() -> void:
	if _sm == null and ScenarioManager.Instance != null:
		_sm = ScenarioManager.Instance
		U.on(_sm.OnStepComplete, OnStepComplete)

func OnFlagAdded(flag) -> void:
	for b in branches:
		if b.get("startFlag") == flag:
			StartBranch(b.get("scenarioID"))

func StartBranch(id) -> void:
	TryHook()
	var sm = ScenarioManager.Instance
	var data = sm.GetScenarioByID(id) if sm != null else null
	if data != null and sm.CanStartScenario(data):
		sm.StartScenario(data)
		var qid = QuestForScenario(id)
		if U.empty(qid) or QuestManager.Instance == null:
			return
		for q in QuestManager.Instance.allQuests:
			if q != null and q.questID == qid:
				if QuestManager.Instance.CanStartQuest(q):
					QuestManager.Instance.StartQuest(q)
				break

func OnStepComplete(step) -> void:
	if step == null or U.empty(step.get("stepName")) or step.stepName == "complete" or QuestManager.Instance == null:
		return
	var cur = ScenarioManager.Instance.GetCurrentScenario() if ScenarioManager.Instance != null else null
	if cur == null:
		return
	var qid = QuestForScenario(cur.scenarioID)
	if not U.empty(qid):
		QuestManager.Instance.UpdateObjectiveProgress(qid, step.stepName, 1)

func QuestForScenario(id):
	for b in branches:
		if b.get("scenarioID") == id:
			return b.get("questID")
	return null
