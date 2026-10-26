class_name GuideEntryFields
extends SO

var id:
	get:
		return d.get("id", "")
	set(v):
		d["id"] = v

var title:
	get:
		return d.get("title", "")
	set(v):
		d["title"] = v

var titleTR:
	get:
		return d.get("titleTR", "")
	set(v):
		d["titleTR"] = v

var category:
	get:
		return d.get("category", GuideCategory.Lore)
	set(v):
		d["category"] = v

var icon:
	get:
		return d.get("icon", null)
	set(v):
		d["icon"] = v

var bookItem:
	get:
		return d.get("bookItem", null)
	set(v):
		d["bookItem"] = v

var unlockedByDefault:
	get:
		return d.get("unlockedByDefault", true)
	set(v):
		d["unlockedByDefault"] = v

var unlockFlag:
	get:
		return d.get("unlockFlag", "")
	set(v):
		d["unlockFlag"] = v

var body:
	get:
		return d.get("body", "")
	set(v):
		d["body"] = v

var bodyTR:
	get:
		return d.get("bodyTR", "")
	set(v):
		d["bodyTR"] = v
