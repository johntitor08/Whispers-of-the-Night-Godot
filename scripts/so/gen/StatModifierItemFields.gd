class_name StatModifierItemFields
extends ItemData

var targetStat:
	get:
		return d.get("targetStat", 0)
	set(v):
		d["targetStat"] = v

var modifyAmount:
	get:
		return d.get("modifyAmount", 0)
	set(v):
		d["modifyAmount"] = v

var modifyMaxStat:
	get:
		return d.get("modifyMaxStat", false)
	set(v):
		d["modifyMaxStat"] = v
