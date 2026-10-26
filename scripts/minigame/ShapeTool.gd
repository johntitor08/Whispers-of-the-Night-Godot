class_name ShapeTool

static func DrawShape(img: Image, from: Vector2, to: Vector2, shape: int, color: Color, thickness: int) -> void:
	match shape:
		ShapeType.Line:
			BrushTool.DrawLine(img, from, to, thickness, color, 1.0, false)
		ShapeType.Rectangle:
			DrawRect(img, from, to, color, thickness)
		ShapeType.Circle:
			DrawEllipse(img, from, to, color, thickness)

static func DrawRect(img: Image, a: Vector2, b: Vector2, color: Color, t: int) -> void:
	BrushTool.DrawLine(img, Vector2(a.x, a.y), Vector2(b.x, a.y), t, color, 1.0, false)
	BrushTool.DrawLine(img, Vector2(b.x, a.y), Vector2(b.x, b.y), t, color, 1.0, false)
	BrushTool.DrawLine(img, Vector2(b.x, b.y), Vector2(a.x, b.y), t, color, 1.0, false)
	BrushTool.DrawLine(img, Vector2(a.x, b.y), Vector2(a.x, a.y), t, color, 1.0, false)

static func DrawEllipse(img: Image, a: Vector2, b: Vector2, color: Color, t: int) -> void:
	var center := (a + b) / 2.0
	var rx := absf(b.x - a.x) / 2.0
	var ry := absf(b.y - a.y) / 2.0
	var steps := maxi(64, int(TAU * maxf(rx, ry) / maxf(1.0, t * 0.5)))
	var prev := Vector2.ZERO
	for i in steps + 1:
		var ang := TAU * i / steps
		var cur := Vector2(center.x + rx * cos(ang), center.y + ry * sin(ang))
		if i > 0:
			BrushTool.DrawLine(img, prev, cur, t, color, 1.0, false)
		prev = cur
