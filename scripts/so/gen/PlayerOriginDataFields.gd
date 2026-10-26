class_name PlayerOriginDataFields
extends SO

var originID:
	get:
		return d.get("originID", "")
	set(v):
		d["originID"] = v

var displayName:
	get:
		return d.get("displayName", "")
	set(v):
		d["displayName"] = v

var displayNameTR:
	get:
		return d.get("displayNameTR", "")
	set(v):
		d["displayNameTR"] = v

var summary:
	get:
		return d.get("summary", "")
	set(v):
		d["summary"] = v

var summaryTR:
	get:
		return d.get("summaryTR", "")
	set(v):
		d["summaryTR"] = v

var icon:
	get:
		return d.get("icon", null)
	set(v):
		d["icon"] = v

var baseHP:
	get:
		return d.get("baseHP", 60)
	set(v):
		d["baseHP"] = v

var baseATK:
	get:
		return d.get("baseATK", 50)
	set(v):
		d["baseATK"] = v

var baseDEF:
	get:
		return d.get("baseDEF", 40)
	set(v):
		d["baseDEF"] = v

var baseMANA:
	get:
		return d.get("baseMANA", 60)
	set(v):
		d["baseMANA"] = v

var baseSPD:
	get:
		return d.get("baseSPD", 50)
	set(v):
		d["baseSPD"] = v

var flagsOnSelect:
	get:
		return d.get("flagsOnSelect", [])
	set(v):
		d["flagsOnSelect"] = v

var startingItems:
	get:
		return d.get("startingItems", [])
	set(v):
		d["startingItems"] = v

var startingItemQty:
	get:
		return d.get("startingItemQty", [])
	set(v):
		d["startingItemQty"] = v

var passiveDescription:
	get:
		return d.get("passiveDescription", "")
	set(v):
		d["passiveDescription"] = v
