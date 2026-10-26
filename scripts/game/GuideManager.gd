class_name GuideManager
extends Mono

signal OnGuideChanged
const LegacyPrefsKey := "guide_unlocked"
static var Instance: GuideManager
static var Unlocked: Dictionary = {}
var entries: Array = []

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self
	if U.HasKey(LegacyPrefsKey):
		U.DeleteKey(LegacyPrefsKey)
		U.PrefsSave()
	AddDefaults()

func AddDefaults() -> void:
	for e in entries:
		if e != null and e.unlockedByDefault and not U.empty(e.id):
			Unlocked[e.id] = true

func IsUnlocked(id) -> bool:
	return not U.empty(id) and Unlocked.has(id)

func Unlock(id) -> void:
	if U.empty(id) or Unlocked.has(id):
		return
	Unlocked[id] = true
	OnGuideChanged.emit()

static func _inst_valid() -> bool:
	return Instance != null and is_instance_valid(Instance)

static func ResetAll() -> void:
	Unlocked.clear()
	if _inst_valid():
		Instance.AddDefaults()
		Instance.OnGuideChanged.emit()

static func ExportTo(ids: Array) -> void:
	ids.clear()
	ids.append_array(Unlocked.keys())

static func ImportFrom(ids) -> void:
	Unlocked.clear()
	if ids != null:
		for id in ids:
			if not U.empty(id):
				Unlocked[str(id)] = true
	if _inst_valid():
		Instance.AddDefaults()
		for e in Instance.entries:
			if e != null and not U.empty(e.unlockFlag) and StoryFlags.Has(e.unlockFlag):
				Unlocked[e.id] = true
		Instance.OnGuideChanged.emit()

func GetEntries(category: int) -> Array:
	var out := []
	for e in entries:
		if e != null and int(e.category) == category and IsUnlocked(e.id):
			out.append(e)
	return out
