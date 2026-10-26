class_name DialogueLocalizationTableFields
extends SO

var entries:
	get:
		return d.get("entries", [])
	set(v):
		d["entries"] = v
