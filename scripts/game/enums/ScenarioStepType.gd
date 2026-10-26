class_name ScenarioStepType

enum { Dialogue, Combat, CollectItem, GoToLocation, Wait, Custom }

const NAMES := ["Dialogue", "Combat", "CollectItem", "GoToLocation", "Wait", "Custom"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
