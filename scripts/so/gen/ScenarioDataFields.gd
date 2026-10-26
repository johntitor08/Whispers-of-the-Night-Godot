class_name ScenarioDataFields
extends SO

var scenarioID:
	get:
		return d.get("scenarioID", "")
	set(v):
		d["scenarioID"] = v

var scenarioName:
	get:
		return d.get("scenarioName", "")
	set(v):
		d["scenarioName"] = v

var description:
	get:
		return d.get("description", "")
	set(v):
		d["description"] = v

var thumbnail:
	get:
		return d.get("thumbnail", null)
	set(v):
		d["thumbnail"] = v

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

var prerequisiteScenarios:
	get:
		return d.get("prerequisiteScenarios", [])
	set(v):
		d["prerequisiteScenarios"] = v

var introDialogue:
	get:
		return d.get("introDialogue", null)
	set(v):
		d["introDialogue"] = v

var steps:
	get:
		return d.get("steps", [])
	set(v):
		d["steps"] = v

var outroDialogue:
	get:
		return d.get("outroDialogue", null)
	set(v):
		d["outroDialogue"] = v

var experienceReward:
	get:
		return d.get("experienceReward", 0)
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

var flagsToSet:
	get:
		return d.get("flagsToSet", [])
	set(v):
		d["flagsToSet"] = v

var canFail:
	get:
		return d.get("canFail", false)
	set(v):
		d["canFail"] = v

var failureDialogue:
	get:
		return d.get("failureDialogue", null)
	set(v):
		d["failureDialogue"] = v

var retryFlagOnDefeat:
	get:
		return d.get("retryFlagOnDefeat", "")
	set(v):
		d["retryFlagOnDefeat"] = v
