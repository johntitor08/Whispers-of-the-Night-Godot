class_name BrushSettings
extends BrushSettingsFields

static var Instance: BrushSettings

func GetActiveColor() -> Color:
	if Instance == null:
		Instance = self
	if int(d.get("activeTool", 0)) == ToolType.Eraser:
		return Color(0, 0, 0, 0)
	var c: Color = d.get("color", Color.BLACK)
	c.a *= float(d.get("opacity", 1.0))
	return c
