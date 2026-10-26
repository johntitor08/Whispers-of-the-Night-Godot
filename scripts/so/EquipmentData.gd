class_name EquipmentData
extends EquipmentDataFields

func OnLoaded() -> void:
	d["itemType"] = ItemType.Equipment
	d["stackable"] = 0
	d["maxStack"] = 1

func IsEquipment() -> bool:
	return true
