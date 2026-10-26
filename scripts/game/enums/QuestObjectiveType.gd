class_name QuestObjectiveType

enum { KillEnemies, CollectItems, TalkToNPC, GoToLocation, InteractWithObject, CraftItems, SpendCurrency, Custom }

const NAMES := ["KillEnemies", "CollectItems", "TalkToNPC", "GoToLocation", "InteractWithObject", "CraftItems", "SpendCurrency", "Custom"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
