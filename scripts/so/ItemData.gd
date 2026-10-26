class_name ItemData
extends ItemDataFields

var DisplayName: String:
	get:
		return Loc.Pick(d.get("itemName"), d.get("itemNameTR"))

var DisplayDescription: String:
	get:
		return Loc.Pick(d.get("description"), d.get("descriptionTR"))

var DisplayReadText: String:
	get:
		return Loc.Pick(d.get("readText"), d.get("readTextTR"))

func IsEquipment() -> bool:
	return int(d.get("itemType", 0)) == ItemType.Equipment or self is EquipmentData

func GetRarityColor() -> Color:
	return UIPalette.ForRarity(int(d.get("rarity", 0)))

func GetRarityMultiplier() -> float:
	match int(d.get("rarity", 0)):
		Rarity.Common:
			return 1.0
		Rarity.Rare:
			return 1.5
		Rarity.Epic:
			return 2.5
		Rarity.Legendary:
			return 5.0
		Rarity.Godly:
			return 10.0
	return 1.0

func GetSellPrice(sellRatio := 0.5) -> int:
	return U.RoundToInt(int(d.get("basePrice", 10)) * GetRarityMultiplier() * sellRatio)
