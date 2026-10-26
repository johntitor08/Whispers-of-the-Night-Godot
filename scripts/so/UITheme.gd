class_name UITheme
extends UIThemeFields

const DEFAULTS := {
	"panelBackground": Color(0.105, 0.103, 0.133, 0.97), "panelBorder": Color(0.470, 0.392, 0.255, 1), "panelLift": Color(0.188, 0.180, 0.243, 0.96),
	"headerText": Color(0.784, 0.659, 0.431, 1), "bodyText": Color(0.886, 0.835, 0.733, 1), "mutedText": Color(0.580, 0.553, 0.500, 1),
	"accent": Color(0.784, 0.659, 0.431, 1), "buttonBackground": Color(0.157, 0.149, 0.196, 1), "buttonText": Color(0.886, 0.835, 0.733, 1),
	"highlight": Color(0.553, 0.376, 0.255, 1), "primaryButtonText": Color(0.934, 0.897, 0.824, 1), "buttonSecondary": Color(0.263, 0.251, 0.341, 1),
	"dialogueSurface": Color(0.105, 0.103, 0.133, 0.95), "hairline": Color(0.784, 0.659, 0.431, 0.20), "shade": Color(0, 0, 0, 0.72),
	"sizeTitle": 64.0, "sizeHeader": 40.0, "sizeBody": 32.0, "sizeLabel": 28.0, "sizeSmall": 24.0,
	"radiusPanel": 22, "radiusButton": 18, "radiusSlot": 12, "radiusBar": 12,
	"buttonHeight": 52.0, "buttonHeightCompact": 40.0, "buttonMinWidth": 180.0, "iconButtonSize": 44.0, "headerHeight": 64.0,
}

func OnLoaded() -> void:
	for k in DEFAULTS:
		if not d.has(k) or d[k] == null:
			d[k] = DEFAULTS[k]

func NearestSize(cur: float) -> float:
	var steps := [float(d.sizeSmall), float(d.sizeLabel), float(d.sizeBody), float(d.sizeHeader), float(d.sizeTitle)]
	var best: float = steps[0]
	for s in steps:
		if absf(cur - s) < absf(cur - best):
			best = s
	return best
