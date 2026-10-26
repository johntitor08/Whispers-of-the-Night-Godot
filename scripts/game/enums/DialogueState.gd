class_name DialogueState

enum { Idle, Opening, Typing, WaitingInput, Choices, Closing }

const NAMES := ["Idle", "Opening", "Typing", "WaitingInput", "Choices", "Closing"]

static func name_of(v: int) -> String:
	return NAMES[v] if v >= 0 and v < NAMES.size() else str(v)
