class_name ProfileIconDatabase
extends ProfileIconDatabaseFields

static var _instance: ProfileIconDatabase

func OnLoaded() -> void:
	_instance = self

func GetIconSprite(id):
	for e in d.get("icons", []):
		if str(e.get("id")) == str(id):
			return e.get("sprite")
	return null

static func GetSprite(id):
	return _instance.GetIconSprite(id) if _instance != null else null
