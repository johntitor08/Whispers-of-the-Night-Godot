class_name QuestDifficulty

enum { Easy, Normal, Hard, Elite, Epic }

const NAMES := ["Easy", "Normal", "Hard", "Elite", "Epic"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
