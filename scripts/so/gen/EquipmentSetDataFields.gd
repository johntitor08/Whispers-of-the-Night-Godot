class_name EquipmentSetDataFields
extends SO

var setID:
	get:
		return d.get("setID", 0)
	set(v):
		d["setID"] = v

var setName:
	get:
		return d.get("setName", "")
	set(v):
		d["setName"] = v

var setNameTR:
	get:
		return d.get("setNameTR", "")
	set(v):
		d["setNameTR"] = v

var totalPieces:
	get:
		return d.get("totalPieces", 4)
	set(v):
		d["totalPieces"] = v

var bonuses:
	get:
		return d.get("bonuses", [])
	set(v):
		d["bonuses"] = v
