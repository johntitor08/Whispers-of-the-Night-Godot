class_name EnemyAIPattern

enum { Random, Aggressive, Defensive, Finisher }

const NAMES := ["Random", "Aggressive", "Defensive", "Finisher"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
