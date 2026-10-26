class_name ForegroundNotifier
extends Mono

static var Instance: ForegroundNotifier
const MessageSurface := Color(0.118, 0.100, 0.086, 0.95)
const ToastSurface := Color(0.200, 0.170, 0.146, 0.96)
const MessageMaxTextWidth := 1400.0
const MessagePadX := 56.0
const MessagePadY := 28.0
const ToastMaxTextWidth := 400.0
var _canvas
var _toastRoot: VBoxContainer
var headerFont
var bodyFont

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(self)
		return
	Instance = self
	var c: Node = gameObject
	while c.get_parent() is Control and c.get_parent().has_meta("u"):
		c = c.get_parent()
	_canvas = c

func OnDestroy() -> void:
	if Instance == self:
		Instance = null

func _box(col: Color, r: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(r)
	sb.anti_aliasing = true
	return sb

func ShowMessage(msg: String, secs: float) -> void:
	if _canvas == null:
		return
	var pc := PanelContainer.new()
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := _box(MessageSurface, 22)
	sb.content_margin_left = MessagePadX
	sb.content_margin_right = MessagePadX
	sb.content_margin_top = MessagePadY
	sb.content_margin_bottom = MessagePadY
	pc.add_theme_stylebox_override("panel", sb)
	var lbl := Label.new()
	lbl.text = msg
	if headerFont != null:
		lbl.add_theme_font_override("font", headerFont)
	lbl.add_theme_font_size_override("font_size", 64)
	lbl.add_theme_color_override("font_color", UIPalette.Gold)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var f: Font = headerFont if headerFont != null else ThemeDB.fallback_font
	var w := f.get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 64).x
	if w > MessageMaxTextWidth:
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.custom_minimum_size.x = MessageMaxTextWidth
	pc.add_child(lbl)
	_canvas.add_child(pc)
	pc.reset_size()
	await get_tree().process_frame
	pc.position = (_canvas.size - pc.size) * 0.5
	await U.wait(secs)
	if is_instance_valid(pc):
		pc.queue_free()

func ShowLoot(item, qty := 1) -> void:
	if item == null:
		return
	var c: Color = item.GetRarityColor() if item is EquipmentData else UIPalette.Cream
	ShowToast("+%d %s" % [qty, item.DisplayName], item.icon, c)

func ToastRoot() -> VBoxContainer:
	if _toastRoot != null and is_instance_valid(_toastRoot):
		return _toastRoot
	if _canvas == null:
		return null
	var v := VBoxContainer.new()
	v.name = "ToastStack"
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.alignment = BoxContainer.ALIGNMENT_END
	v.add_theme_constant_override("separation", 10)
	v.anchor_left = 1
	v.anchor_right = 1
	v.anchor_top = 1
	v.anchor_bottom = 1
	v.offset_left = -490
	v.offset_right = -30
	v.offset_top = -600
	v.offset_bottom = -30
	v.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_canvas.add_child(v)
	_toastRoot = v
	return v

func ShowToast(msg: String, icon, tint: Color, secs := 3.0) -> void:
	var root := ToastRoot()
	if root == null:
		return
	var pc := PanelContainer.new()
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.size_flags_horizontal = Control.SIZE_SHRINK_END
	var sb := _box(ToastSurface, 12)
	sb.content_margin_left = 12
	sb.content_margin_right = 16
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	pc.add_theme_stylebox_override("panel", sb)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.add_child(h)
	pc.custom_minimum_size.y = 64
	if icon is USprite and icon.texture != null:
		var tr := TextureRect.new()
		var at := AtlasTexture.new()
		at.atlas = icon.texture
		at.region = icon.get_region()
		tr.texture = at
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.custom_minimum_size = Vector2(48, 48)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(tr)
	var lbl := Label.new()
	lbl.text = msg
	if bodyFont != null:
		lbl.add_theme_font_override("font", bodyFont)
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.add_theme_color_override("font_color", tint)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var f: Font = bodyFont if bodyFont != null else ThemeDB.fallback_font
	lbl.custom_minimum_size.x = minf(f.get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 28).x + 4, ToastMaxTextWidth)
	h.add_child(lbl)
	root.add_child(pc)
	pc.modulate.a = 0.0
	var tw := pc.create_tween()
	tw.set_ignore_time_scale(true)
	tw.tween_property(pc, "modulate:a", 1.0, 0.18)
	tw.tween_interval(secs)
	tw.tween_property(pc, "modulate:a", 0.0, 0.3)
	tw.tween_callback(pc.queue_free)
