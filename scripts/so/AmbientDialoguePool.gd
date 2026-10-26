class_name AmbientDialoguePool
extends AmbientDialoguePoolFields

var lastPickedIndex := -1

func PickLine() -> String:
	var day: int = TimeUI.Instance.GetCurrentDay() if TimeUI.Instance != null else 1
	var phase: int = TimePhaseManager.Instance.currentPhase if TimePhaseManager.Instance != null else TimePhase.Morning
	var eligible := []
	var lines = d.get("lines", [])
	if lines != null:
		for i in lines.size():
			if IsEligible(lines[i], day, phase):
				eligible.append(i)
	if eligible.size() > 1:
		eligible.erase(lastPickedIndex)
	if eligible.is_empty():
		return str(d.get("fallbackLine", "..."))
	var picked := PickWeighted(eligible)
	lastPickedIndex = picked
	return str(lines[picked].text)

func IsEligible(line, day: int, phase: int) -> bool:
	if line == null or U.empty(line.get("text")) or day < int(line.get("minDay", 1)):
		return false
	if int(line.get("maxDay", 0)) > 0 and day > int(line.maxDay):
		return false
	var ap = line.get("allowedPhases")
	if ap != null and ap.size() > 0 and not ap.has(phase):
		return false
	for f in line.get("requiredFlags", []) if line.get("requiredFlags") != null else []:
		if not U.empty(f) and not StoryFlags.Has(f):
			return false
	for f in line.get("forbiddenFlags", []) if line.get("forbiddenFlags") != null else []:
		if not U.empty(f) and StoryFlags.Has(f):
			return false
	return true

func PickWeighted(eligible: Array) -> int:
	var lines = d.get("lines")
	var total := 0.0
	for i in eligible:
		total += float(lines[i].get("weight", 1))
	var roll := U.value() * total
	for i in eligible:
		roll -= float(lines[i].get("weight", 1))
		if roll <= 0.0:
			return i
	return eligible[-1]
