class_name QuestUIHoverBridge
extends Mono

var hoverRegion
var requireQuestActive := true
var triggerOnce := true
var hasFired := false
var kind := 1
var questID := ""
var questTag := ""
var objectiveID := ""
var progressAmount := 1
var dialogue
var waitForDialogueEnd := true
var catalogObjectiveID := ""
var backgroundName := ""

func _on_injected(_root: Node) -> void:
	if U.empty(questTag) and u.has("tag") and u["tag"] != null:
		questTag = str(u["tag"])

func Awake() -> void:
	ApplyCatalogEntry()
	hoverRegion = GetComponent(UIHoverRegion)
	if hoverRegion != null:
		U.on(hoverRegion.OnRegionClicked, OnRegionClicked)

func OnDestroy() -> void:
	if hoverRegion != null and is_instance_valid(hoverRegion):
		U.off(hoverRegion.OnRegionClicked, OnRegionClicked)

func OnRegionClicked() -> void:
	TryFire()

func OnPointerClick(_e) -> void:
	if not DialogueManager.WorldClicksBlocked():
		TryFire()

func TryFire() -> void:
	if QuestManager.Instance == null or (hasFired and triggerOnce) or (requireQuestActive and not U.empty(questID) and not QuestManager.Instance.IsQuestActive(questID)):
		return
	if not U.empty(backgroundName) and SceneEvent.Instance != null:
		SceneEvent.Instance.ShowQuestLocation(backgroundName)
	if dialogue != null and DialogueManager.Instance != null and kind == 0:
		if DialogueManager.Instance.IsInDialogue():
			return
		if waitForDialogueEnd:
			DialogueManager.Instance.StartDialogue(dialogue, ApplyProgress)
			return
		DialogueManager.Instance.StartDialogue(dialogue)
	ApplyProgress()

func ApplyProgress() -> void:
	var qm = QuestManager.Instance
	if qm == null:
		return
	var tag := ResolveTag()
	match kind:
		0:
			qm.NotifyTalkToNPC(tag, progressAmount)
			hasFired = true
		1:
			qm.NotifyObjectInteracted(tag, progressAmount)
			hasFired = true
		2:
			qm.NotifyLocationReached(tag, progressAmount)
			hasFired = true
		3:
			if not U.empty(questID) and not U.empty(objectiveID):
				qm.UpdateObjectiveProgress(questID, objectiveID, progressAmount)
				hasFired = true

func ResolveTag() -> String:
	if not U.empty(questTag):
		return questTag
	if not U.empty(objectiveID):
		return objectiveID
	return go_name

func ApplyCatalogEntry() -> void:
	if U.empty(catalogObjectiveID):
		return
	var e = AshenveilQuestTriggerCatalog.TryGet(catalogObjectiveID)
	if e == null:
		return
	questID = e.questID
	objectiveID = e.objectiveID
	questTag = e.objectiveID if U.empty(e.tag) else e.tag
	kind = e.recommendedKind
	progressAmount = e.progressAmount
	backgroundName = AshenveilQuestTriggerCatalog.BackgroundFor(e.suggestedSceneObjectName)
