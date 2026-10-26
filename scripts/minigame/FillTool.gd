class_name FillTool

static func FloodFill(img: Image, pos: Vector2, fillColor: Color) -> void:
	var x := U.RoundToInt(pos.x)
	var y := U.RoundToInt(pos.y)
	var W := img.get_width()
	var H := img.get_height()
	if x < 0 or x >= W or y < 0 or y >= H:
		return
	var data := img.get_data()
	var i0 := (y * W + x) * 4
	var tr := data[i0]
	var tg := data[i0 + 1]
	var tb := data[i0 + 2]
	var ta := data[i0 + 3]
	var fr := int(round(fillColor.r * 255))
	var fg := int(round(fillColor.g * 255))
	var fb := int(round(fillColor.b * 255))
	var fa := int(round(fillColor.a * 255))
	if absi(tr - fr) < 30 and absi(tg - fg) < 30 and absi(tb - fb) < 30 and absi(ta - fa) < 30:
		return
	var done := PackedByteArray()
	done.resize(W * H)
	var stack := PackedInt32Array([x, y])
	while stack.size() > 0:
		var sy := stack[stack.size() - 1]
		var sx := stack[stack.size() - 2]
		stack.resize(stack.size() - 2)
		var lx := sx
		while lx >= 0 and _match(data, done, (sy * W + lx), tr, tg, tb, ta):
			lx -= 1
		lx += 1
		var up := false
		var down := false
		var px := lx
		while px < W and _match(data, done, (sy * W + px), tr, tg, tb, ta):
			var idx := sy * W + px
			var o := idx * 4
			data[o] = fr
			data[o + 1] = fg
			data[o + 2] = fb
			data[o + 3] = fa
			done[idx] = 1
			if sy > 0:
				var m := _match(data, done, idx - W, tr, tg, tb, ta)
				if m and not up:
					stack.append(px)
					stack.append(sy - 1)
				up = m
			if sy < H - 1:
				var m2 := _match(data, done, idx + W, tr, tg, tb, ta)
				if m2 and not down:
					stack.append(px)
					stack.append(sy + 1)
				down = m2
			px += 1
	img.set_data(W, H, false, Image.FORMAT_RGBA8, data)

static func _match(data: PackedByteArray, done: PackedByteArray, idx: int, tr: int, tg: int, tb: int, ta: int) -> bool:
	if done[idx] != 0:
		return false
	var o := idx * 4
	return absi(data[o] - tr) < 30 and absi(data[o + 1] - tg) < 30 and absi(data[o + 2] - tb) < 30 and absi(data[o + 3] - ta) < 30
