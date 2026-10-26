class_name UIPalette

const Gold := Color(0.784, 0.659, 0.431)
const Cream := Color(0.886, 0.835, 0.733)
const Muted := Color(0.659, 0.604, 0.525)
const Light := Color(0.934, 0.897, 0.824)
const Good := Color(0.561, 0.780, 0.478)
const Bad := Color(0.851, 0.467, 0.420)
const Common := Color(0.741, 0.714, 0.659)
const Rare := Color(0.420, 0.616, 0.878)
const Epic := Color(0.698, 0.463, 0.859)
const Legendary := Color(0.933, 0.647, 0.275)
const Godly := Color(0.863, 0.310, 0.271)

static func ForRarity(r: int) -> Color:
	match r:
		Rarity.Common:
			return Common
		Rarity.Rare:
			return Rare
		Rarity.Epic:
			return Epic
		Rarity.Legendary:
			return Legendary
		Rarity.Godly:
			return Godly
	return Cream

static func Hex(c: Color) -> String:
	return "#" + c.to_html(false).to_upper()
