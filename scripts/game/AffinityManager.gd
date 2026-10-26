class_name AffinityManager
extends Mono

static var Instance: AffinityManager
static var _cache: Dictionary = {}
const Characters := ["Serena", "Maren", "Voss", "Awamori"]
signal OnAffinityChanged(character_id: String, value: int)
var maxAffinity := 100

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self
	var any := false
	for id in Characters:
		if U.HasKey("affinity_" + id):
			U.DeleteKey("affinity_" + id)
			any = true
	if any:
		U.PrefsSave()

func Get(id) -> int:
	if U.empty(id):
		return 0
	return _cache.get(str(id), 0)

func Add(id, delta: int) -> void:
	if U.empty(id) or delta == 0:
		return
	Set(id, Get(id) + delta)

func Set(id, value: int) -> void:
	if U.empty(id):
		return
	var v := clampi(value, 0, maxAffinity)
	_cache[str(id)] = v
	OnAffinityChanged.emit(str(id), v)

static func ResetAll() -> void:
	_cache.clear()

func ExportTo(keys: Array, values: Array) -> void:
	keys.clear()
	values.clear()
	for id in Characters:
		keys.append(id)
		values.append(Get(id))

func ImportFrom(keys, values) -> void:
	_cache.clear()
	if keys == null:
		return
	for id in Characters:
		var i: int = keys.find(id)
		Set(id, int(values[i]) if i >= 0 and i < values.size() else 0)

func HeartBar(id) -> String:
	var v := Get(id)
	var filled := clampi(ceili((v / float(maxi(1, maxAffinity))) * 10.0), 0, 10)
	return "[" + "=".repeat(filled) + "-".repeat(10 - filled) + "]"

func Tier(id) -> String:
	var v := Get(id)
	if v >= 80:
		return Loc.T("Devoted", "Sadık")
	if v >= 60:
		return Loc.T("Close", "Yakın")
	if v >= 40:
		return Loc.T("Friendly", "Dost")
	if v >= 20:
		return Loc.T("Acquaintance", "Tanıdık")
	return Loc.T("Stranger", "Yabancı")
