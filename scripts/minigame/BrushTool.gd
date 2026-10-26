class_name BrushTool

static func DrawLine(img: Image, from: Vector2, to: Vector2, size: int, color: Color, hardness: float, eraser: bool) -> void:
	var dist := from.distance_to(to)
	var spacing := maxf(0.5, size * 0.1)
	var steps := maxi(1, ceili(dist / spacing))
	var solid := not eraser and hardness >= 1.0 and color.a >= 1.0
	var hard_erase := eraser and hardness >= 1.0
	var mask: Image = null
	var fill: Image = null
	if solid or hard_erase:
		mask = CircleMask(size)
		fill = Image.create(mask.get_width(), mask.get_height(), false, Image.FORMAT_RGBA8)
		fill.fill(Color(0, 0, 0, 0) if hard_erase else color)
	for i in steps + 1:
		var c := from.lerp(to, float(i) / steps)
		if mask != null:
			var cx := U.RoundToInt(c.x)
			var cy := U.RoundToInt(c.y)
			img.blit_rect_mask(fill, mask, Rect2i(0, 0, mask.get_width(), mask.get_height()), Vector2i(cx - size, cy - size))
		else:
			PaintCircle(img, c, size, color, hardness, eraser)

static var _masks: Dictionary = {}

static func CircleMask(radius: int) -> Image:
	if _masks.has(radius):
		return _masks[radius]
	var n := radius * 2 + 1
	var m := Image.create(n, n, false, Image.FORMAT_RGBA8)
	for x in n:
		for y in n:
			var dx := x - radius
			var dy := y - radius
			if sqrt(dx * dx + dy * dy) <= radius:
				m.set_pixel(x, y, Color.WHITE)
	_masks[radius] = m
	return m

static func PaintCircle(img: Image, center: Vector2, radius: int, color: Color, hardness: float, eraser: bool) -> void:
	var cx := U.RoundToInt(center.x)
	var cy := U.RoundToInt(center.y)
	var W := img.get_width()
	var H := img.get_height()
	for x in range(maxi(0, cx - radius), mini(W - 1, cx + radius) + 1):
		for y in range(maxi(0, cy - radius), mini(H - 1, cy + radius) + 1):
			var dx := float(x - cx)
			var dy := float(y - cy)
			var dist := sqrt(dx * dx + dy * dy)
			if dist > radius:
				continue
			var alpha := 1.0 if hardness >= 1.0 else clampf(1.0 - (dist / radius - hardness) / (1.0 - hardness + 0.001), 0.0, 1.0)
			var existing := img.get_pixel(x, y)
			if eraser:
				existing.a = maxf(0.0, existing.a - alpha)
				img.set_pixel(x, y, existing)
			else:
				var blended := existing.lerp(color, color.a * alpha)
				blended.a = maxf(existing.a, color.a * alpha)
				img.set_pixel(x, y, blended)
