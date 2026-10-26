class_name UIThemeFields
extends SO

var panelBackground:
	get:
		return d.get("panelBackground", Color(0.105, 0.103, 0.133, 0.97))
	set(v):
		d["panelBackground"] = v

var panelBorder:
	get:
		return d.get("panelBorder", Color(0.470, 0.392, 0.255, 1))
	set(v):
		d["panelBorder"] = v

var panelLift:
	get:
		return d.get("panelLift", Color(0.188, 0.180, 0.243, 0.96))
	set(v):
		d["panelLift"] = v

var headerText:
	get:
		return d.get("headerText", Color(0.784, 0.659, 0.431, 1))
	set(v):
		d["headerText"] = v

var bodyText:
	get:
		return d.get("bodyText", Color(0.886, 0.835, 0.733, 1))
	set(v):
		d["bodyText"] = v

var mutedText:
	get:
		return d.get("mutedText", Color(0.580, 0.553, 0.500, 1))
	set(v):
		d["mutedText"] = v

var accent:
	get:
		return d.get("accent", Color(0.784, 0.659, 0.431, 1))
	set(v):
		d["accent"] = v

var buttonBackground:
	get:
		return d.get("buttonBackground", Color(0.157, 0.149, 0.196, 1))
	set(v):
		d["buttonBackground"] = v

var buttonText:
	get:
		return d.get("buttonText", Color(0.886, 0.835, 0.733, 1))
	set(v):
		d["buttonText"] = v

var highlight:
	get:
		return d.get("highlight", Color(0.553, 0.376, 0.255, 1))
	set(v):
		d["highlight"] = v

var primaryButtonText:
	get:
		return d.get("primaryButtonText", Color(0.934, 0.897, 0.824, 1))
	set(v):
		d["primaryButtonText"] = v

var buttonSecondary:
	get:
		return d.get("buttonSecondary", Color(0.263, 0.251, 0.341, 1))
	set(v):
		d["buttonSecondary"] = v

var dialogueSurface:
	get:
		return d.get("dialogueSurface", Color(0.105, 0.103, 0.133, 0.95))
	set(v):
		d["dialogueSurface"] = v

var hairline:
	get:
		return d.get("hairline", Color(0.784, 0.659, 0.431, 0.20))
	set(v):
		d["hairline"] = v

var shade:
	get:
		return d.get("shade", Color(0, 0, 0, 0.72))
	set(v):
		d["shade"] = v

var sizeTitle:
	get:
		return d.get("sizeTitle", 64.0)
	set(v):
		d["sizeTitle"] = v

var sizeHeader:
	get:
		return d.get("sizeHeader", 40.0)
	set(v):
		d["sizeHeader"] = v

var sizeBody:
	get:
		return d.get("sizeBody", 32.0)
	set(v):
		d["sizeBody"] = v

var sizeLabel:
	get:
		return d.get("sizeLabel", 28.0)
	set(v):
		d["sizeLabel"] = v

var sizeSmall:
	get:
		return d.get("sizeSmall", 24.0)
	set(v):
		d["sizeSmall"] = v

var radiusPanel:
	get:
		return d.get("radiusPanel", 22)
	set(v):
		d["radiusPanel"] = v

var radiusButton:
	get:
		return d.get("radiusButton", 18)
	set(v):
		d["radiusButton"] = v

var radiusSlot:
	get:
		return d.get("radiusSlot", 12)
	set(v):
		d["radiusSlot"] = v

var radiusBar:
	get:
		return d.get("radiusBar", 12)
	set(v):
		d["radiusBar"] = v

var buttonHeight:
	get:
		return d.get("buttonHeight", 52.0)
	set(v):
		d["buttonHeight"] = v

var buttonHeightCompact:
	get:
		return d.get("buttonHeightCompact", 40.0)
	set(v):
		d["buttonHeightCompact"] = v

var buttonMinWidth:
	get:
		return d.get("buttonMinWidth", 180.0)
	set(v):
		d["buttonMinWidth"] = v

var iconButtonSize:
	get:
		return d.get("iconButtonSize", 44.0)
	set(v):
		d["iconButtonSize"] = v

var headerHeight:
	get:
		return d.get("headerHeight", 64.0)
	set(v):
		d["headerHeight"] = v
