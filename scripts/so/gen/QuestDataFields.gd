class_name QuestDataFields
extends SO

var questID:
	get:
		return d.get("questID", "")
	set(v):
		d["questID"] = v

var questName:
	get:
		return d.get("questName", "")
	set(v):
		d["questName"] = v

var questNameTR:
	get:
		return d.get("questNameTR", "")
	set(v):
		d["questNameTR"] = v

var description:
	get:
		return d.get("description", "")
	set(v):
		d["description"] = v

var descriptionTR:
	get:
		return d.get("descriptionTR", "")
	set(v):
		d["descriptionTR"] = v

var icon:
	get:
		return d.get("icon", null)
	set(v):
		d["icon"] = v

var questType:
	get:
		return d.get("questType", QuestType.Main)
	set(v):
		d["questType"] = v

var difficulty:
	get:
		return d.get("difficulty", QuestDifficulty.Normal)
	set(v):
		d["difficulty"] = v

var requiredLevel:
	get:
		return d.get("requiredLevel", 1)
	set(v):
		d["requiredLevel"] = v

var requiredFlags:
	get:
		return d.get("requiredFlags", [])
	set(v):
		d["requiredFlags"] = v

var prerequisiteQuests:
	get:
		return d.get("prerequisiteQuests", [])
	set(v):
		d["prerequisiteQuests"] = v

var objectives:
	get:
		return d.get("objectives", [])
	set(v):
		d["objectives"] = v

var startDialogue:
	get:
		return d.get("startDialogue", null)
	set(v):
		d["startDialogue"] = v

var progressDialogue:
	get:
		return d.get("progressDialogue", null)
	set(v):
		d["progressDialogue"] = v

var completionDialogue:
	get:
		return d.get("completionDialogue", null)
	set(v):
		d["completionDialogue"] = v

var completeDialogue:
	get:
		return d.get("completeDialogue", null)
	set(v):
		d["completeDialogue"] = v

var failureDialogue:
	get:
		return d.get("failureDialogue", null)
	set(v):
		d["failureDialogue"] = v

var experienceReward:
	get:
		return d.get("experienceReward", 100)
	set(v):
		d["experienceReward"] = v

var currencyRewards:
	get:
		return d.get("currencyRewards", [])
	set(v):
		d["currencyRewards"] = v

var itemRewards:
	get:
		return d.get("itemRewards", [])
	set(v):
		d["itemRewards"] = v

var itemRewardQuantities:
	get:
		return d.get("itemRewardQuantities", [])
	set(v):
		d["itemRewardQuantities"] = v

var optionalRewards:
	get:
		return d.get("optionalRewards", [])
	set(v):
		d["optionalRewards"] = v

var trackObjectives:
	get:
		return d.get("trackObjectives", true)
	set(v):
		d["trackObjectives"] = v

var showOnMap:
	get:
		return d.get("showOnMap", true)
	set(v):
		d["showOnMap"] = v

var questMarkerPosition:
	get:
		return d.get("questMarkerPosition", null)
	set(v):
		d["questMarkerPosition"] = v

var autoCompleteWhenObjectivesComplete:
	get:
		return d.get("autoCompleteWhenObjectivesComplete", false)
	set(v):
		d["autoCompleteWhenObjectivesComplete"] = v

var hasTimeLimit:
	get:
		return d.get("hasTimeLimit", false)
	set(v):
		d["hasTimeLimit"] = v

var timeLimitSeconds:
	get:
		return d.get("timeLimitSeconds", 300.0)
	set(v):
		d["timeLimitSeconds"] = v

var canFail:
	get:
		return d.get("canFail", false)
	set(v):
		d["canFail"] = v

var onQuestStart:
	get:
		return d.get("onQuestStart", null)
	set(v):
		d["onQuestStart"] = v

var onQuestComplete:
	get:
		return d.get("onQuestComplete", null)
	set(v):
		d["onQuestComplete"] = v

var onQuestFail:
	get:
		return d.get("onQuestFail", null)
	set(v):
		d["onQuestFail"] = v

var flagsToSetOnStart:
	get:
		return d.get("flagsToSetOnStart", [])
	set(v):
		d["flagsToSetOnStart"] = v

var flagsToSetOnComplete:
	get:
		return d.get("flagsToSetOnComplete", [])
	set(v):
		d["flagsToSetOnComplete"] = v
