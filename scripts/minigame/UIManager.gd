class_name UIManager
extends Mono

var brushBtn
var eraserBtn
var fillBtn
var eyedropperBtn
var lineBtn
var rectBtn
var circleBtn
var sizeSlider
var hardnessSlider
var opacitySlider
var sizeLabel
var colorPreview
var paletteButtons: Array = []
var addLayerBtn
var removeLayerBtn
var mergeDownBtn
var savePNGBtn
var saveNativeBtn
var undoBtn
var redoBtn
var clearBtn

func Start() -> void:
	_bind(brushBtn, SetTool.bind(ToolType.Brush))
	_bind(eraserBtn, SetTool.bind(ToolType.Eraser))
	_bind(fillBtn, SetTool.bind(ToolType.Fill))
	_bind(eyedropperBtn, SetTool.bind(ToolType.Eyedropper))
	_bind(lineBtn, SetShape.bind(ShapeType.Line))
	_bind(rectBtn, SetShape.bind(ShapeType.Rectangle))
	_bind(circleBtn, SetShape.bind(ShapeType.Circle))
	if sizeSlider != null:
		sizeSlider.onValueChanged.AddListener(_on_size)
	if hardnessSlider != null:
		hardnessSlider.onValueChanged.AddListener(_on_hardness)
	if opacitySlider != null:
		opacitySlider.onValueChanged.AddListener(_on_opacity)
	for btn in paletteButtons:
		if btn == null:
			continue
		var img = U.GetComponent(btn, UImage)
		var col: Color = img.color if img != null else Color.WHITE
		btn.onClick.AddListener(_on_palette.bind(col))
	_bind(addLayerBtn, _add_layer)
	_bind(removeLayerBtn, _remove_layer)
	_bind(mergeDownBtn, _merge_down)
	_bind(savePNGBtn, _save_png)
	_bind(saveNativeBtn, _save_native)
	_bind(undoBtn, _undo)
	_bind(redoBtn, _redo)
	_bind(clearBtn, _clear)

static func _bind(b, c: Callable) -> void:
	if b != null:
		b.onClick.AddListener(c)

static func SetTool(t: int) -> void:
	BrushSettings.Instance.activeTool = t

static func SetShape(s: int) -> void:
	SetTool(ToolType.Shape)
	BrushSettings.Instance.activeShape = s

func _on_size(v: float) -> void:
	BrushSettings.Instance.size = int(v)
	if sizeLabel != null:
		sizeLabel.text = "%dpx" % int(v)

func _on_hardness(v: float) -> void:
	BrushSettings.Instance.hardness = v

func _on_opacity(v: float) -> void:
	BrushSettings.Instance.opacity = v

func _on_palette(col: Color) -> void:
	BrushSettings.Instance.color = col
	if colorPreview != null:
		colorPreview.color = col
	SetTool(ToolType.Brush)

func _add_layer() -> void:
	LayerManager.Instance.AddLayer()

func _remove_layer() -> void:
	LayerManager.Instance.RemoveLayer(LayerManager.Instance.ActiveIndex)

func _merge_down() -> void:
	LayerManager.Instance.MergeDown(LayerManager.Instance.ActiveIndex)

func _play_save() -> void:
	if AudioManager.Instance != null:
		AudioManager.Instance.PlaySave()

func _save_png() -> void:
	SaveManager.Instance.SavePNG()
	_play_save()

func _save_native() -> void:
	SaveManager.Instance.SaveNative()
	_play_save()

func _undo() -> void:
	DrawingCanvas.Instance.Undo()

func _redo() -> void:
	DrawingCanvas.Instance.Redo()

func _clear() -> void:
	var layer = LayerManager.Instance.ActiveLayer
	if layer != null:
		layer.Clear()
		DrawingCanvas.Instance.RefreshDisplay()
