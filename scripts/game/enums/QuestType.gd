class_name QuestType

enum { Main, Side, Daily, Repeatable, Event }

const NAMES := ["Main", "Side", "Daily", "Repeatable", "Event"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
