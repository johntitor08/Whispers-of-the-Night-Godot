class_name ItemDatabase
extends ItemDatabaseFields

static var Instance: ItemDatabase
var dict: Dictionary = {}

func Initialize() -> void:
	dict.clear()
	for i in d.get("items", []):
		if i == null:
			continue
		var id := str(i.itemID)
		if not dict.has(id):
			dict[id] = i

func GetByID(id):
	if id == null:
		return null
	var v = dict.get(str(id))
	if v == null:
		push_warning("ItemDatabase missing: %s" % id)
	return v

func SetInstance() -> void:
	if Instance == null:
		Instance = self
	Initialize()
