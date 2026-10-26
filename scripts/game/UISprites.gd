class_name UISprites

static var _cache: Dictionary = {}

static func _mk(key: String, kind: int, r := 0, w := 0) -> USprite:
	if _cache.has(key):
		return _cache[key]
	var s := USprite.new()
	s.kind = kind
	s.radius = r
	s.ring_width = w
	s.name = key
	s.region = Rect2(0, 0, 96, 96)
	s._region_known = true
	if r > 0:
		s.border = Vector4(r, r, r, r)
	_cache[key] = s
	return s

static func Rounded(r: int) -> USprite:
	return _mk("round%d" % r, USprite.Kind.ROUNDED, clampi(r, 1, 48))

static func RoundedRing(r: int, w: int) -> USprite:
	return _mk("ring%d_%d" % [r, w], USprite.Kind.RING, clampi(r, 1, 48), w)

static func Circle() -> USprite:
	return _mk("circle", USprite.Kind.CIRCLE)

static func Solid() -> USprite:
	return _mk("solid", USprite.Kind.SOLID)

static func BottomFade() -> USprite:
	return _mk("bfade", USprite.Kind.BOTTOM_FADE)
