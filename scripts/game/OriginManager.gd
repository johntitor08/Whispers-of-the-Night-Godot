class_name OriginManager
extends Mono

static var Instance: OriginManager
const OriginBoundArchivist := "bound_archivist"
const OriginForeignEcho := "foreign_echo"
const OriginSinnedGuardian := "sinned_guardian"
const OriginStoryUnlockScenario := "ashenveil_day2"
const ChapterPollInterval := 0.5
var CurrentOrigin
var OriginSelected := false
var _originStoryPending := false
var _chapterPollTimer := 0.0
var allOrigins: Array = []
var boundArchivistQuest
var foreignEchoQuest
var sinnedGuardianQuest

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func Start() -> void:
	if ScenarioManager.Instance != null:
		U.on(ScenarioManager.Instance.OnScenarioComplete, HandleScenarioComplete)
	TryRestoreFromFlags()

func OnDestroy() -> void:
	if Instance == self and ScenarioManager.Instance != null:
		U.off(ScenarioManager.Instance.OnScenarioComplete, HandleScenarioComplete)

func SelectOrigin(o) -> void:
	if o is String:
		for x in allOrigins:
			if x.originID == o:
				SelectOrigin(x)
				return
		return
	if o == null:
		return
	CurrentOrigin = o
	OriginSelected = true
	SaveSystem.SavingEnabled = true
	StoryFlags.Add(QuestFlags.OriginPrefix + str(o.originID))
	ApplyStats(o)
	GrantStartingItems(o)
	if IsOriginStoryUnlocked():
		StartOriginStory(o)
	else:
		_originStoryPending = true

func GetOrigin(id):
	for o in allOrigins:
		if o.originID == id:
			return o
	return null

func GetSaveID() -> String:
	return CurrentOrigin.GetSaveID() if CurrentOrigin != null else ""

func LoadFromSaveID(id: String) -> void:
	if U.empty(id):
		return
	var o = GetOrigin(id)
	if o == null:
		return
	CurrentOrigin = o
	OriginSelected = true
	ResumeOrDeferOriginStory(o)

func TryRestoreFromFlags() -> void:
	for o in allOrigins:
		if not StoryFlags.Has(QuestFlags.OriginPrefix + str(o.originID)):
			continue
		CurrentOrigin = o
		OriginSelected = true
		ResumeOrDeferOriginStory(o)
		return

func ResumeOrDeferOriginStory(o) -> void:
	if HasOriginStoryStarted(o):
		if not IsOriginOpeningComplete(o.originID):
			RunOriginOpeningScene(o.originID)
		ApplyOriginFlags(o)
		AshenveilQuestFactory.OnOriginApplied()
		return
	_originStoryPending = true

func StartOriginStory(o) -> void:
	_originStoryPending = false
	RunOriginOpeningScene(o.originID)
	ApplyOriginFlags(o)
	AshenveilQuestFactory.OnOriginApplied()

func HandleScenarioComplete(_s) -> void:
	_chapterPollTimer = 0.0

func Update() -> void:
	if not OriginSelected or CurrentOrigin == null:
		return
	_chapterPollTimer -= U.unscaledDeltaTime
	if _chapterPollTimer > 0.0:
		return
	_chapterPollTimer = ChapterPollInterval
	if IsStoryBusy():
		return
	if _originStoryPending:
		if IsOriginStoryUnlocked():
			StartOriginStory(CurrentOrigin)
		return
	UnlockNextChapter(CurrentOrigin.originID)

static func UnlockNextChapter(id) -> void:
	var f := ChapterDoneFlags(id)
	if f[0] == null or (SceneEvent.Instance != null and not SceneEvent.Instance.IsInTownSquare):
		return
	if not StoryFlags.Has(QuestFlags.OriginChapter2Ready):
		if StoryFlags.Has(f[0]) and CurrentDay() >= 3 and (SceneEvent.Instance == null or not SceneEvent.Instance.IsSleeping):
			StoryFlags.Add(QuestFlags.OriginChapter2Ready)
		return
	if not StoryFlags.Has(QuestFlags.OriginChapter3Ready) and StoryFlags.Has(f[1]) and StoryFlags.Has(QuestFlags.Q09VossWarehouseFound):
		StoryFlags.Add(QuestFlags.OriginChapter3Ready)

static func ChapterDoneFlags(id) -> Array:
	match id:
		OriginBoundArchivist:
			return [QuestFlags.BoundArchivistQuest1Done, "archivist_quest2_done", "archivist_quest3_done"]
		OriginForeignEcho:
			return [QuestFlags.ForeignEchoQuest1Done, "echo_quest2_done", "echo_quest3_done"]
		OriginSinnedGuardian:
			return [QuestFlags.SinnedGuardianQuest1Done, "sinned_guardian_quest2_done", "sinned_guardian_quest3_done"]
	return [null, null, null]

func ShouldHoldDayScenario(id) -> bool:
	if id != "ashenveil_day3" or not OriginSelected or CurrentOrigin == null:
		return false
	var f := ChapterDoneFlags(CurrentOrigin.originID)
	return f[0] != null and StoryFlags.Has(f[0]) and not StoryFlags.Has(f[2])

static func CurrentDay() -> int:
	return TimeUI.Instance.GetCurrentDay() if TimeUI.Instance != null else 1

static func IsStoryBusy() -> bool:
	return (ScenarioManager.Instance != null and ScenarioManager.Instance.IsScenarioActive()) or (DialogueManager.Instance != null and DialogueManager.Instance.IsInDialogue()) or (CombatManager.Instance != null and CombatManager.Instance.inCombat)

static func IsOriginStoryUnlocked() -> bool:
	return ScenarioManager.Instance != null and ScenarioManager.Instance.IsScenarioCompleted(OriginStoryUnlockScenario)

static func HasOriginStoryStarted(o) -> bool:
	if o == null or o.flagsOnSelect == null:
		return false
	for f in o.flagsOnSelect:
		if StoryFlags.Has(f):
			return true
	return false

func ApplyOriginFlags(o) -> void:
	if o.flagsOnSelect == null:
		return
	for f in o.flagsOnSelect:
		StoryFlags.Add(f)

func ApplyStats(o) -> void:
	var ps = PlayerStats.Instance
	if ps == null:
		return
	ps.Set(StatType.MaxHealth, int(o.baseHP), false)
	ps.Set(StatType.Health, int(o.baseHP), false)
	ps.Set(StatType.MaxEnergy, int(o.baseMANA), false)
	ps.Set(StatType.Energy, int(o.baseMANA), false)
	ps.Set(StatType.Strength, int(o.baseATK), false)
	ps.Set(StatType.Defense, int(o.baseDEF), false)
	ps.Set(StatType.Speed, int(o.baseSPD), false)
	SaveSystem.SaveGame()

func GrantStartingItems(o) -> void:
	if o.startingItems == null or InventoryManager.Instance == null:
		return
	for i in o.startingItems.size():
		if o.startingItems[i] == null:
			continue
		var q = o.startingItemQty
		InventoryManager.Instance.AddItem(o.startingItems[i], int(q[i]) if q != null and i < q.size() else 1)

func RunOriginOpeningScene(id) -> void:
	match id:
		OriginBoundArchivist:
			var c = _resolve("boundArchivistQuest", BoundArchivistQuestController)
			if c != null:
				c.OnOpeningSceneComplete()
		OriginForeignEcho:
			var c2 = _resolve("foreignEchoQuest", ForeignEchoQuestController)
			if c2 != null:
				c2.OnOpeningSceneComplete()
		OriginSinnedGuardian:
			var c3 = _resolve("sinnedGuardianQuest", SinnedGuardianQuestController)
			if c3 != null:
				c3.OnOpeningSceneComplete()

func _resolve(field: String, cls):
	var v = get(field)
	if v != null and is_instance_valid(v):
		return v
	v = U.FindAnyObjectByType(cls, true)
	set(field, v)
	return v

static func IsOriginOpeningComplete(id) -> bool:
	match id:
		OriginBoundArchivist:
			return StoryFlags.Has(QuestFlags.BoundArchivistOpeningComplete)
		OriginForeignEcho:
			return StoryFlags.Has(QuestFlags.ForeignEchoOpeningComplete)
		OriginSinnedGuardian:
			return StoryFlags.Has(QuestFlags.SinnedGuardianOpeningComplete)
	return true
