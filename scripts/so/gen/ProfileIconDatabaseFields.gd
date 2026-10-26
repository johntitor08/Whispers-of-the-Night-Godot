class_name ProfileIconDatabaseFields
extends SO

var icons:
	get:
		return d.get("icons", [])
	set(v):
		d["icons"] = v
