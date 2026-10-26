class_name ItemTooltip
extends Mono

var tooltipText

func Show(item, lvl := 0) -> void:
	var up := "  <color=%s>+%d</color>" % [UIPalette.Hex(UIPalette.Gold), lvl] if lvl > 0 else ""
	tooltipText.text = "%s%s\n%s: %d %s" % [item.DisplayName, up, Loc.T("Sell Price", "Satış Fiyatı"), item.GetSellPrice(), Loc.T("Gold", "Altın")]
	U.SetActive(gameObject, true)

func Hide() -> void:
	U.SetActive(gameObject, false)
