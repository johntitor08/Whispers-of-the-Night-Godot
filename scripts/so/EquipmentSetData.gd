class_name EquipmentSetData
extends EquipmentSetDataFields

var DisplaySetName: String:
	get:
		return Loc.Pick(d.get("setName"), d.get("setNameTR"))
