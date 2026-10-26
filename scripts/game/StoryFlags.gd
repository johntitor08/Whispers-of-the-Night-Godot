class_name StoryFlags

static var flags: Dictionary = {}
static var OnFlagAdded := UEvent.new()

static func Add(flag) -> void:
	if flag == null:
		return
	var f := str(flag)
	if flags.has(f):
		return
	flags[f] = true
	OnFlagAdded.Invoke(f)

static func Has(flag) -> bool:
	return flag != null and flags.has(str(flag))

static func Remove(flag) -> void:
	flags.erase(str(flag))

static func Load(saved) -> void:
	flags.clear()
	if saved != null:
		for f in saved:
			flags[str(f)] = true

static func Reset() -> void:
	flags.clear()

static func GetAll() -> Array:
	return flags.keys()
