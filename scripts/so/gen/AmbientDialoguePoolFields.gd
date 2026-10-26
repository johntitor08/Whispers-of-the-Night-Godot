class_name AmbientDialoguePoolFields
extends SO

var speakerName:
	get:
		return d.get("speakerName", "NPC")
	set(v):
		d["speakerName"] = v

var speakerPortrait:
	get:
		return d.get("speakerPortrait", null)
	set(v):
		d["speakerPortrait"] = v

var speakerNameColor:
	get:
		return d.get("speakerNameColor", null)
	set(v):
		d["speakerNameColor"] = v

var lines:
	get:
		return d.get("lines", [])
	set(v):
		d["lines"] = v

var fallbackLine:
	get:
		return d.get("fallbackLine", "...")
	set(v):
		d["fallbackLine"] = v
