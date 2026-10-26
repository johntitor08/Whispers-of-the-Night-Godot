class_name EquipmentSetBonus

static func GetBonus(s, pieces: int, stat: int) -> int:
	var data = s.get("data") if s is Dictionary else null
	if data == null or data.bonuses == null:
		return 0
	var total := 0
	for b in data.bonuses:
		if pieces >= int(b.requiredPieces) and int(b.stat) == stat:
			total += int(b.value)
	return total

static func GetDescription(s, pieces: int) -> String:
	var data = s.get("data")
	var desc := ""
	for b in data.bonuses:
		if pieces >= int(b.requiredPieces):
			desc += "<color=%s>%s:</color> +%d %s\n" % [UIPalette.Hex(UIPalette.Gold), Loc.T("%d-Piece" % int(b.requiredPieces), "%d Parça" % int(b.requiredPieces)), int(b.value), DisplayNames.Stat(int(b.stat))]
	return desc
