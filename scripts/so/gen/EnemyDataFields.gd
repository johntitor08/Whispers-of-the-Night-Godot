class_name EnemyDataFields
extends SO

var enemyName:
	get:
		return d.get("enemyName", "Enemy")
	set(v):
		d["enemyName"] = v

var enemyNameTR:
	get:
		return d.get("enemyNameTR", "")
	set(v):
		d["enemyNameTR"] = v

var sprite:
	get:
		return d.get("sprite", null)
	set(v):
		d["sprite"] = v

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

var maxHealth:
	get:
		return d.get("maxHealth", 100)
	set(v):
		d["maxHealth"] = v

var attack:
	get:
		return d.get("attack", 15)
	set(v):
		d["attack"] = v

var defense:
	get:
		return d.get("defense", 5)
	set(v):
		d["defense"] = v

var speed:
	get:
		return d.get("speed", 10)
	set(v):
		d["speed"] = v

var experienceReward:
	get:
		return d.get("experienceReward", 50)
	set(v):
		d["experienceReward"] = v

var currencyReward:
	get:
		return d.get("currencyReward", 25)
	set(v):
		d["currencyReward"] = v

var possibleLoot:
	get:
		return d.get("possibleLoot", [])
	set(v):
		d["possibleLoot"] = v

var lootChances:
	get:
		return d.get("lootChances", [])
	set(v):
		d["lootChances"] = v

var isAggressive:
	get:
		return d.get("isAggressive", true)
	set(v):
		d["isAggressive"] = v

var defendChance:
	get:
		return d.get("defendChance", 0.2)
	set(v):
		d["defendChance"] = v

var specialAttackChance:
	get:
		return d.get("specialAttackChance", 0.3)
	set(v):
		d["specialAttackChance"] = v

var equipmentLootTable:
	get:
		return d.get("equipmentLootTable", null)
	set(v):
		d["equipmentLootTable"] = v

var combatAbility:
	get:
		return d.get("combatAbility", null)
	set(v):
		d["combatAbility"] = v

var abilityChance:
	get:
		return d.get("abilityChance", 0.0)
	set(v):
		d["abilityChance"] = v

var abilityTargetsSelf:
	get:
		return d.get("abilityTargetsSelf", true)
	set(v):
		d["abilityTargetsSelf"] = v

var aiPattern:
	get:
		return d.get("aiPattern", EnemyAIPattern.Random)
	set(v):
		d["aiPattern"] = v

var lowHealthThreshold:
	get:
		return d.get("lowHealthThreshold", 0.3)
	set(v):
		d["lowHealthThreshold"] = v

var finisherThreshold:
	get:
		return d.get("finisherThreshold", 0.25)
	set(v):
		d["finisherThreshold"] = v
