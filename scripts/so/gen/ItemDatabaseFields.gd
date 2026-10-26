class_name ItemDatabaseFields
extends SO

var items:
	get:
		return d.get("items", [])
	set(v):
		d["items"] = v
