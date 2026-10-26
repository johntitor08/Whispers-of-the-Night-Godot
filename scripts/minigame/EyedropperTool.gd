class_name EyedropperTool

static func Sample(img: Image, pos: Vector2) -> void:
	var x := clampi(U.RoundToInt(pos.x), 0, img.get_width() - 1)
	var y := clampi(U.RoundToInt(pos.y), 0, img.get_height() - 1)
	var c := img.get_pixel(x, y)
	c.a = 1.0
	BrushSettings.Instance.color = c
	BrushSettings.Instance.activeTool = ToolType.Brush
