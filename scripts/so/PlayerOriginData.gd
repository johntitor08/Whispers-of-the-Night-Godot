class_name PlayerOriginData
extends PlayerOriginDataFields

var DisplayName: String:
	get:
		return Loc.Pick(d.get("displayName"), d.get("displayNameTR"))

var DisplaySummary: String:
	get:
		return Loc.Pick(d.get("summary"), d.get("summaryTR"))

func GetSaveID() -> String:
	return str(d.get("originID", ""))
