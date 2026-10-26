class_name DrawingCanvas
extends Mono

static var Instance: DrawingCanvas
var _rt: Control
var _drawing := false
var _lastPos := Vector2.ZERO
var _strokeStarted := false
var _shapeStart := Vector2.ZERO
var _shapePreviewSnap: Image
var _views: Array = []
var _dirty := true

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance):
		Instance = self
	else:
		U.Destroy(gameObject)
		return
	_rt = gameObject
	_rt.sprite = null
	_rt.color = Color.WHITE

func Start() -> void:
	U.on(LayerManager.Instance.OnLayersChanged, Rebuild)
	Rebuild()

func OnDestroy() -> void:
	if LayerManager.Instance != null and is_instance_valid(LayerManager.Instance):
		U.off(LayerManager.Instance.OnLayersChanged, Rebuild)

func Rebuild() -> void:
	for v in _views:
		if is_instance_valid(v):
			v.queue_free()
	_views.clear()
	for l in LayerManager.Instance.Layers:
		var tr := TextureRect.new()
		tr.texture = l.texture
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_SCALE
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_rt.add_child(tr, false, Node.INTERNAL_MODE_BACK)
		_views.append(tr)
	RefreshDisplay()

func RefreshDisplay() -> void:
	_dirty = true

func LateUpdate() -> void:
	if not _dirty:
		return
	_dirty = false
	var layers: Array = LayerManager.Instance.Layers
	if layers.size() != _views.size():
		Rebuild()
		return
	for i in layers.size():
		var l = layers[i]
		l.Sync()
		_views[i].visible = l.visible
		_views[i].modulate = Color(1, 1, 1, l.opacity)

func _active_img() -> Image:
	return LayerManager.Instance.ActiveLayer.image

func _mark_active() -> void:
	LayerManager.Instance.ActiveLayer.dirty = true
	RefreshDisplay()

func OnPointerDown(e) -> void:
	var pos = GetCanvasPos(e)
	if pos == null:
		return
	var bs := BrushSettings.Instance
	var tool := int(bs.activeTool)
	if tool == ToolType.Fill:
		UndoRedoManager.Instance.Push(UndoRedoManager.TakeSnapshot(LayerManager.Instance.Layers))
		FillTool.FloodFill(_active_img(), pos, bs.color)
		if AudioManager.Instance != null:
			AudioManager.Instance.PlayFill()
		_mark_active()
		return
	if tool == ToolType.Eyedropper:
		EyedropperTool.Sample(_active_img(), pos)
		return
	if tool == ToolType.Shape:
		_shapeStart = pos
		_shapePreviewSnap = _active_img().duplicate()
		UndoRedoManager.Instance.Push(UndoRedoManager.TakeSnapshot(LayerManager.Instance.Layers))
		return
	_drawing = true
	_lastPos = pos
	_strokeStarted = false

func OnDrag(e) -> void:
	var pos = GetCanvasPos(e)
	if pos == null:
		return
	var bs := BrushSettings.Instance
	var tool := int(bs.activeTool)
	if tool == ToolType.Shape and _shapePreviewSnap != null:
		var img := _active_img()
		img.copy_from(_shapePreviewSnap)
		ShapeTool.DrawShape(img, _shapeStart, pos, int(bs.activeShape), bs.color, int(bs.size))
		_mark_active()
		return
	if not _drawing:
		return
	if not _strokeStarted:
		UndoRedoManager.Instance.Push(UndoRedoManager.TakeSnapshot(LayerManager.Instance.Layers))
		_strokeStarted = true
		var audio = AudioManager.Instance
		if audio != null:
			if tool == ToolType.Eraser:
				audio.PlayEraser()
			else:
				audio.PlayBrush()
	BrushTool.DrawLine(_active_img(), _lastPos, pos, int(bs.size), bs.GetActiveColor(), float(bs.hardness), tool == ToolType.Eraser)
	_lastPos = pos
	_mark_active()

func OnPointerMove(_e) -> void:
	pass

func OnPointerUp(_e) -> void:
	_drawing = false
	_strokeStarted = false
	_shapePreviewSnap = null

func GetCanvasPos(e):
	var local := RT.screen_to_local(_rt, e.position)
	var r := RT.rect(_rt)
	var u := (local.x - r.position.x) / r.size.x
	var v := (local.y - r.position.y) / r.size.y
	if u < 0 or u > 1 or v < 0 or v > 1:
		return null
	var lm = LayerManager.Instance
	return Vector2(u * lm.canvasWidth, (1.0 - v) * lm.canvasHeight)

func Update() -> void:
	var ctrl := U.GetKey(KEY_CTRL) or U.GetKey(KEY_META)
	if U.GetKeyDown(KEY_Z) and ctrl:
		Undo()
	if U.GetKeyDown(KEY_Y) and ctrl:
		Redo()
	var bs := BrushSettings.Instance
	if U.GetKeyDown(KEY_E):
		bs.activeTool = ToolType.Eraser
	if U.GetKeyDown(KEY_B):
		bs.activeTool = ToolType.Brush
	if U.GetKeyDown(KEY_F):
		bs.activeTool = ToolType.Fill
	if U.GetKeyDown(KEY_I):
		bs.activeTool = ToolType.Eyedropper

func Undo() -> void:
	var state = UndoRedoManager.Instance.Undo()
	if state == null:
		return
	RestoreState(state)
	if AudioManager.Instance != null:
		AudioManager.Instance.PlayUndo()

func Redo() -> void:
	var state = UndoRedoManager.Instance.Redo()
	if state == null:
		return
	RestoreState(state)

func RestoreState(snaps: Array) -> void:
	var layers: Array = LayerManager.Instance.Layers
	for i in mini(snaps.size(), layers.size()):
		layers[i].RestoreFrom(snaps[i])
	RefreshDisplay()
