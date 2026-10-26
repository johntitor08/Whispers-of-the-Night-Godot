class_name QuestData
extends QuestDataFields

static func make() -> QuestData:
	var q := QuestData.new()
	q.d = {"questID": "", "questName": "", "questNameTR": "", "description": "", "descriptionTR": "", "icon": null, "questType": QuestType.Main, "difficulty": QuestDifficulty.Normal, "requiredLevel": 1, "requiredFlags": [], "prerequisiteQuests": [], "objectives": [], "startDialogue": null, "progressDialogue": null, "completionDialogue": null, "completeDialogue": null, "failureDialogue": null, "experienceReward": 100, "currencyRewards": [], "itemRewards": [], "itemRewardQuantities": [], "optionalRewards": [], "trackObjectives": 1, "showOnMap": 1, "autoCompleteWhenObjectivesComplete": 0, "hasTimeLimit": 0, "timeLimitSeconds": 300.0, "canFail": 0, "flagsToSetOnStart": [], "flagsToSetOnComplete": [], "name": "Quest"}
	return q

var DisplayName: String:
	get:
		return Loc.Pick(d.get("questName"), d.get("questNameTR"))

var DisplayDescription: String:
	get:
		return Loc.Pick(d.get("description"), d.get("descriptionTR"))

static func TypeName(t: int) -> String:
	match t:
		QuestType.Main:
			return Loc.T("Main", "Ana")
		QuestType.Side:
			return Loc.T("Side", "Yan")
		QuestType.Daily:
			return Loc.T("Daily", "Günlük")
		QuestType.Repeatable:
			return Loc.T("Repeatable", "Tekrarlanabilir")
		QuestType.Event:
			return Loc.T("Event", "Etkinlik")
	return QuestType.name_of(t)

static func DifficultyName(t: int) -> String:
	match t:
		QuestDifficulty.Easy:
			return Loc.T("Easy", "Kolay")
		QuestDifficulty.Normal:
			return Loc.T("Normal", "Normal")
		QuestDifficulty.Hard:
			return Loc.T("Hard", "Zor")
		QuestDifficulty.Elite:
			return Loc.T("Elite", "Elit")
		QuestDifficulty.Epic:
			return Loc.T("Epic", "Destansı")
	return QuestDifficulty.name_of(t)

static func ObjDesc(o) -> String:
	return Loc.Pick(o.get("description"), o.get("descriptionTR"))

static func ObjRequired(o) -> int:
	var tc := int(o.get("targetCount", 1))
	match int(o.get("type", 0)):
		QuestObjectiveType.KillEnemies:
			return tc
		QuestObjectiveType.CollectItems:
			return int(o.get("itemCount", 1))
		QuestObjectiveType.CraftItems:
			return int(o.get("craftCount", 1))
		QuestObjectiveType.SpendCurrency:
			return int(o.get("currencyAmount", 100))
		QuestObjectiveType.TalkToNPC, QuestObjectiveType.InteractWithObject, QuestObjectiveType.GoToLocation:
			return tc if tc > 0 else 1
	return 1

static func NewObjective(id: String, desc: String, type: int) -> Dictionary:
	return {"targetItem": null, "itemCount": 1, "consumeItems": 1, "npcTag": "", "locationTag": "", "locationRadius": 2.0, "interactObjectTag": "", "craftTarget": null, "craftCount": 1, "currencyType": 0, "currencyAmount": 100, "objectiveID": id, "description": desc, "descriptionTR": "", "type": type, "targetEnemy": null, "targetCount": 1, "isOptional": 0}
