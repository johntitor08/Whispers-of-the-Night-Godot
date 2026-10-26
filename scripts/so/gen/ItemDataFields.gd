class_name ItemDataFields
extends SO

var itemID:
	get:
		return d.get("itemID", "")
	set(v):
		d["itemID"] = v

var itemName:
	get:
		return d.get("itemName", "")
	set(v):
		d["itemName"] = v

var itemNameTR:
	get:
		return d.get("itemNameTR", "")
	set(v):
		d["itemNameTR"] = v

var icon:
	get:
		return d.get("icon", null)
	set(v):
		d["icon"] = v

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

var itemType:
	get:
		return d.get("itemType", ItemType.Consumable)
	set(v):
		d["itemType"] = v

var stackable:
	get:
		return d.get("stackable", true)
	set(v):
		d["stackable"] = v

var maxStack:
	get:
		return d.get("maxStack", 99)
	set(v):
		d["maxStack"] = v

var useable:
	get:
		return d.get("useable", false)
	set(v):
		d["useable"] = v

var consumeOnUse:
	get:
		return d.get("consumeOnUse", true)
	set(v):
		d["consumeOnUse"] = v

var onUse:
	get:
		return d.get("onUse", null)
	set(v):
		d["onUse"] = v

var questObjectiveOnUse:
	get:
		return d.get("questObjectiveOnUse", "")
	set(v):
		d["questObjectiveOnUse"] = v

var readable:
	get:
		return d.get("readable", false)
	set(v):
		d["readable"] = v

var readText:
	get:
		return d.get("readText", "")
	set(v):
		d["readText"] = v

var readTextTR:
	get:
		return d.get("readTextTR", "")
	set(v):
		d["readTextTR"] = v

var basePrice:
	get:
		return d.get("basePrice", 10)
	set(v):
		d["basePrice"] = v

var rarity:
	get:
		return d.get("rarity", Rarity.Common)
	set(v):
		d["rarity"] = v
