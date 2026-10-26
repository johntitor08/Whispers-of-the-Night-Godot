class_name FillTool

const K := 64

static func FloodFill(img: Image, pos: Vector2, fillColor: Color) -> void:
	var x := _round(pos.x)
	var y := _round(pos.y)
	var W := img.get_width()
	var H := img.get_height()
	if x < 0 or x >= W or y < 0 or y >= H:
		return
	var px := img.get_data().to_int32_array()
	var tc: int = px[y * W + x]
	var fr := int(round(fillColor.r * 255))
	var fg := int(round(fillColor.g * 255))
	var fb := int(round(fillColor.b * 255))
	var fa := int(round(fillColor.a * 255))
	var fc := fr | (fg << 8) | (fb << 16) | (fa << 24)
	if fa >= 128:
		fc -= 1 << 32
	if _near(tc, fc):
		return
	var cache := {}
	var run := PackedInt32Array()
	run.resize(K)
	run.fill(tc)
	var stack := PackedInt32Array([x, y])
	while not stack.is_empty():
		var n := stack.size()
		var sy := stack[n - 1]
		var sx := stack[n - 2]
		stack.resize(n - 2)
		var row := sy * W
		var c: int = px[row + sx]
		if c != tc and (c == fc or not _ok(cache, c, tc)):
			continue
		var lx := sx
		while lx >= K and px.slice(row + lx - K, row + lx) == run:
			lx -= K
		while lx > 0:
			c = px[row + lx - 1]
			if c == tc or (c != fc and _ok(cache, c, tc)):
				lx -= 1
			else:
				break
		var rx := sx
		while rx + K < W and px.slice(row + rx + 1, row + rx + 1 + K) == run:
			rx += K
		while rx < W - 1:
			c = px[row + rx + 1]
			if c == tc or (c != fc and _ok(cache, c, tc)):
				rx += 1
			else:
				break
		for i in range(row + lx, row + rx + 1):
			px[i] = fc
		if sy > 0:
			_seed(px, stack, row - W, lx, rx, sy - 1, tc, fc, cache, run)
		if sy < H - 1:
			_seed(px, stack, row + W, lx, rx, sy + 1, tc, fc, cache, run)
	img.set_data(W, H, false, Image.FORMAT_RGBA8, px.to_byte_array())

static func _seed(px: PackedInt32Array, stack: PackedInt32Array, row: int, lx: int, rx: int, yy: int, tc: int, fc: int, cache: Dictionary, run: PackedInt32Array) -> void:
	var inside := false
	var xx := lx
	while xx <= rx:
		if xx + K - 1 <= rx and px.slice(row + xx, row + xx + K) == run:
			if not inside:
				stack.append(xx)
				stack.append(yy)
			inside = true
			xx += K
			continue
		var c: int = px[row + xx]
		var m := c == tc or (c != fc and _ok(cache, c, tc))
		if m and not inside:
			stack.append(xx)
			stack.append(yy)
		inside = m
		xx += 1

static func _ok(cache: Dictionary, c: int, tc: int) -> bool:
	if cache.has(c):
		return cache[c]
	var r := _near(c, tc)
	cache[c] = r
	return r

static func _near(a: int, b: int) -> bool:
	return absi((a & 255) - (b & 255)) < 30 and absi(((a >> 8) & 255) - ((b >> 8) & 255)) < 30 and absi(((a >> 16) & 255) - ((b >> 16) & 255)) < 30 and absi(((a >> 24) & 255) - ((b >> 24) & 255)) < 30

static func _round(f: float) -> int:
	var fl := floorf(f)
	if is_equal_approx(f - fl, 0.5):
		return int(fl) if int(fl) % 2 == 0 else int(fl) + 1
	return int(roundf(f))
