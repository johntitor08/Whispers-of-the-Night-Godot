class_name QuestRuntimeState
extends RefCounted

var questID := ""
var objectiveIDs: Array = []
var objectiveStates: Array = []
var objectives: Dictionary = {}

func _init(id := "") -> void:
	questID = id

func RebuildLookup() -> void:
	objectives.clear()
	for i in mini(objectiveIDs.size(), objectiveStates.size()):
		objectives[objectiveIDs[i]] = objectiveStates[i]

func GetObjective(id: String) -> Dictionary:
	if not objectives.has(id):
		var st := {"objectiveID": id, "currentProgress": 0, "isCompleted": false}
		objectives[id] = st
		objectiveIDs.append(id)
		objectiveStates.append(st)
	return objectives[id]

func to_dict() -> Dictionary:
	return {"questID": questID, "objectiveIDs": objectiveIDs.duplicate(), "objectiveStates": objectiveStates.duplicate(true)}

static func from_dict(d: Dictionary) -> QuestRuntimeState:
	var s := QuestRuntimeState.new(str(d.get("questID", "")))
	for id in d.get("objectiveIDs", []):
		s.objectiveIDs.append(str(id))
	for st in d.get("objectiveStates", []):
		s.objectiveStates.append({"objectiveID": str(st.get("objectiveID", "")), "currentProgress": int(st.get("currentProgress", 0)), "isCompleted": bool(st.get("isCompleted", false))})
	s.RebuildLookup()
	return s
