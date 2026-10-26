class_name WorldItem
extends Mono

var data
var quantity := 1
var catalogObjectiveID := ""
var questObjectiveTag := ""
var _collected := false

func CollectedFlag() -> String:
	return "world_item_collected:" + go_name

func Persistent() -> bool:
	return data != null and (int(data.itemType) == ItemType.Quest or bool(data.readable))

var IsCollected: bool:
	get:
		return Persistent() and StoryFlags.Has(CollectedFlag())

func OnEnable() -> void:
	if IsCollected:
		U.Destroy(gameObject)

func Awake() -> void:
	if not U.empty(catalogObjectiveID):
		var e = AshenveilQuestTriggerCatalog.TryGet(catalogObjectiveID)
		if e != null:
			questObjectiveTag = e.tag

func OnPointerClick(_e) -> void:
	if not DialogueManager.WorldClicksBlocked():
		Collect()

func Collect() -> void:
	if _collected or data == null or InventoryManager.Instance == null:
		return
	_collected = true
	InventoryManager.Instance.AddItem(data, quantity)
	if Persistent():
		StoryFlags.Add(CollectedFlag())
	if not U.empty(questObjectiveTag) and QuestManager.Instance != null:
		QuestManager.Instance.NotifyObjectInteracted(questObjectiveTag, quantity)
	if ForegroundNotifier.Instance != null:
		ForegroundNotifier.Instance.ShowLoot(data, quantity)
	SaveSystem.SaveGame()
	U.Destroy(gameObject)
