class_name DisplayNames

static func RarityName(r: int) -> String:
	match r:
		Rarity.Common:
			return Loc.T("Common", "Sıradan")
		Rarity.Rare:
			return Loc.T("Rare", "Nadir")
		Rarity.Epic:
			return Loc.T("Epic", "Destansı")
		Rarity.Legendary:
			return Loc.T("Legendary", "Efsanevi")
		Rarity.Godly:
			return Loc.T("Godly", "İlahi")
	return Rarity.name_of(r)

static func Stat(s: int) -> String:
	match s:
		StatType.Health:
			return Loc.T("Health", "Can")
		StatType.MaxHealth:
			return Loc.T("Max Health", "Maks. Can")
		StatType.Energy:
			return Loc.T("Energy", "Enerji")
		StatType.MaxEnergy:
			return Loc.T("Max Energy", "Maks. Enerji")
		StatType.Charisma:
			return Loc.T("Charisma", "Karizma")
		StatType.Strength:
			return Loc.T("Strength", "Güç")
		StatType.Intelligence:
			return Loc.T("Intelligence", "Zekâ")
		StatType.Damage:
			return Loc.T("Damage", "Hasar")
		StatType.Defense:
			return Loc.T("Defense", "Savunma")
		StatType.Speed:
			return Loc.T("Speed", "Hız")
		StatType.Luck:
			return Loc.T("Luck", "Şans")
	return StatType.name_of(s)

static func Slot(s: int) -> String:
	match s:
		EquipmentSlot.Weapon:
			return Loc.T("Weapon", "Silah")
		EquipmentSlot.Armor:
			return Loc.T("Armor", "Zırh")
		EquipmentSlot.Helmet:
			return Loc.T("Helmet", "Kask")
		EquipmentSlot.Accessory:
			return Loc.T("Accessory", "Aksesuar")
		EquipmentSlot.Shield:
			return Loc.T("Shield", "Kalkan")
		EquipmentSlot.Boots:
			return Loc.T("Boots", "Bot")
	return EquipmentSlot.name_of(s)
