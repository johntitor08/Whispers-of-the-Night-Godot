class_name StatusEffectData
extends StatusEffectDataFields

var DisplayName: String:
	get:
		return Loc.Pick(d.get("effectName"), d.get("effectNameTR"))

var DisplayDescription: String:
	get:
		return Loc.Pick(d.get("description"), d.get("descriptionTR"))
