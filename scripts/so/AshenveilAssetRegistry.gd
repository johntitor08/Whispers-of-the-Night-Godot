class_name AshenveilAssetRegistry
extends AshenveilAssetRegistryFields

func GetQuestIcon(id: String):
	var icons = d.get("questIcons")
	if icons == null:
		return null
	for qi in icons:
		if qi.get("questID") == id:
			return qi.get("icon")
	return null
