class_name CombatTrigger
extends Mono

var enemy
var catalogObjectiveID := ""
var requirePlayerInRange := false
var interactionPrompt
var hasTriggered := false
var questID := ""
var objectiveID := ""
var progressAmount := 1

func Awake() -> void:
	if not U.empty(catalogObjectiveID):
		var e = AshenveilQuestTriggerCatalog.TryGet(catalogObjectiveID)
		if e != null:
			questID = e.questID
			objectiveID = e.objectiveID
			progressAmount = e.progressAmount

func Start() -> void:
	if interactionPrompt != null:
		U.SetActive(interactionPrompt, false)

func OnEnable() -> void:
	if CombatManager.Instance != null:
		U.on(CombatManager.Instance.OnCombatVictory, OnVictory)

func OnDisable() -> void:
	if CombatManager.Instance != null:
		U.off(CombatManager.Instance.OnCombatVictory, OnVictory)

func OnPointerClick(_e) -> void:
	if hasTriggered or requirePlayerInRange:
		return
	TriggerCombat()

func TriggerCombat() -> void:
	if CombatManager.Instance == null or CombatManager.Instance.inCombat:
		return
	hasTriggered = true
	if interactionPrompt != null:
		U.SetActive(interactionPrompt, false)
	CombatManager.Instance.StartCombat(enemy)
	U.SetActive(gameObject, false)

func OnVictory(defeated) -> void:
	if defeated != enemy or U.empty(questID) or QuestManager.Instance == null:
		return
	QuestManager.Instance.UpdateObjectiveProgress(questID, objectiveID, progressAmount)
