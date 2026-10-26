class_name StatusEffectDataFields
extends SO

var effectType:
	get:
		return d.get("effectType", 0)
	set(v):
		d["effectType"] = v

var effectName:
	get:
		return d.get("effectName", "Poison")
	set(v):
		d["effectName"] = v

var effectNameTR:
	get:
		return d.get("effectNameTR", "")
	set(v):
		d["effectNameTR"] = v

var icon:
	get:
		return d.get("icon", null)
	set(v):
		d["icon"] = v

var description:
	get:
		return d.get("description", "Takes damage over time")
	set(v):
		d["description"] = v

var descriptionTR:
	get:
		return d.get("descriptionTR", "")
	set(v):
		d["descriptionTR"] = v

var effectColor:
	get:
		return d.get("effectColor", null)
	set(v):
		d["effectColor"] = v

var particleEffectPrefab:
	get:
		return d.get("particleEffectPrefab", null)
	set(v):
		d["particleEffectPrefab"] = v

var applySound:
	get:
		return d.get("applySound", null)
	set(v):
		d["applySound"] = v

var tickSound:
	get:
		return d.get("tickSound", null)
	set(v):
		d["tickSound"] = v

var duration:
	get:
		return d.get("duration", 5.0)
	set(v):
		d["duration"] = v

var isPermanent:
	get:
		return d.get("isPermanent", false)
	set(v):
		d["isPermanent"] = v

var isRoundBased:
	get:
		return d.get("isRoundBased", false)
	set(v):
		d["isRoundBased"] = v

var durationRounds:
	get:
		return d.get("durationRounds", 3)
	set(v):
		d["durationRounds"] = v

var hasTicks:
	get:
		return d.get("hasTicks", true)
	set(v):
		d["hasTicks"] = v

var tickInterval:
	get:
		return d.get("tickInterval", 1.0)
	set(v):
		d["tickInterval"] = v

var tickDamage:
	get:
		return d.get("tickDamage", 5)
	set(v):
		d["tickDamage"] = v

var tickHeal:
	get:
		return d.get("tickHeal", 0)
	set(v):
		d["tickHeal"] = v

var statModifiers:
	get:
		return d.get("statModifiers", [])
	set(v):
		d["statModifiers"] = v

var canStack:
	get:
		return d.get("canStack", false)
	set(v):
		d["canStack"] = v

var maxStacks:
	get:
		return d.get("maxStacks", 1)
	set(v):
		d["maxStacks"] = v

var refreshOnReapply:
	get:
		return d.get("refreshOnReapply", true)
	set(v):
		d["refreshOnReapply"] = v

var isPurgeableByPlayer:
	get:
		return d.get("isPurgeableByPlayer", true)
	set(v):
		d["isPurgeableByPlayer"] = v

var isDebuff:
	get:
		return d.get("isDebuff", true)
	set(v):
		d["isDebuff"] = v

var preventActions:
	get:
		return d.get("preventActions", false)
	set(v):
		d["preventActions"] = v

var damageMultiplier:
	get:
		return d.get("damageMultiplier", 1.0)
	set(v):
		d["damageMultiplier"] = v

var damageReduction:
	get:
		return d.get("damageReduction", 0.0)
	set(v):
		d["damageReduction"] = v

var preventMovement:
	get:
		return d.get("preventMovement", null)
	set(v):
		d["preventMovement"] = v
