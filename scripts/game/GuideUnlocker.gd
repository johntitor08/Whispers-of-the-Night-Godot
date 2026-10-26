class_name GuideUnlocker
extends Mono

var _invHooked := false
var _dlgHooked := false

func OnEnable() -> void:
	StoryFlags.OnFlagAdded.RemoveListener(OnFlag)
	StoryFlags.OnFlagAdded.AddListener(OnFlag)

func Start() -> void:
	TryHook()
	CheckLoreAgainstExistingFlags()

func Update() -> void:
	if not _invHooked or not _dlgHooked:
		TryHook()

func TryHook() -> void:
	if not _invHooked and InventoryManager.Instance != null:
		U.off(InventoryManager.Instance.OnInventoryChanged, CheckBooks)
		U.on(InventoryManager.Instance.OnInventoryChanged, CheckBooks)
		_invHooked = true
		CheckBooks()
	if not _dlgHooked and DialogueManager.Instance != null:
		U.off(DialogueManager.Instance.OnDialogueStart, CheckSpeaker)
		U.on(DialogueManager.Instance.OnDialogueStart, CheckSpeaker)
		_dlgHooked = true

func OnDestroy() -> void:
	if InventoryManager.Instance != null:
		U.off(InventoryManager.Instance.OnInventoryChanged, CheckBooks)
	if DialogueManager.Instance != null:
		U.off(DialogueManager.Instance.OnDialogueStart, CheckSpeaker)
	StoryFlags.OnFlagAdded.RemoveListener(OnFlag)

func CheckBooks() -> void:
	if GuideManager.Instance == null or InventoryManager.Instance == null:
		return
	for e in GuideManager.Instance.entries:
		if e == null or int(e.category) != GuideCategory.Book or e.bookItem == null:
			continue
		if InventoryManager.Instance.GetQuantity(e.bookItem) > 0:
			GuideManager.Instance.Unlock(e.id)
			StoryFlags.Add("read_" + str(e.id))

func CheckSpeaker(node) -> void:
	if GuideManager.Instance == null or node == null or U.empty(node.speakerName):
		return
	for e in GuideManager.Instance.entries:
		if e == null or int(e.category) != GuideCategory.Character:
			continue
		if str(e.title).to_lower() == str(node.speakerName).to_lower():
			GuideManager.Instance.Unlock(e.id)

func OnFlag(flag) -> void:
	if GuideManager.Instance == null or U.empty(flag):
		return
	for e in GuideManager.Instance.entries:
		if e != null and not U.empty(e.unlockFlag) and e.unlockFlag == flag:
			GuideManager.Instance.Unlock(e.id)

func CheckLoreAgainstExistingFlags() -> void:
	if GuideManager.Instance == null:
		return
	for e in GuideManager.Instance.entries:
		if e != null and not U.empty(e.unlockFlag) and StoryFlags.Has(e.unlockFlag):
			GuideManager.Instance.Unlock(e.id)
