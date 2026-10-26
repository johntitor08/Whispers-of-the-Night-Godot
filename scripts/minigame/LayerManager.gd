class_name LayerManager
extends Mono

class Layer:
	var name := ""
	var image: Image
	var texture: ImageTexture
	var visible := true
	var opacity := 1.0
	var locked := false
	var id := 0
	var dirty := true

	func _init(i: int, n: String, w: int, h: int) -> void:
		id = i
		name = n
		image = Image.create(w, h, false, Image.FORMAT_RGBA8)
		texture = ImageTexture.create_from_image(image)

	func Clear() -> void:
		image.fill(Color(0, 0, 0, 0))
		dirty = true

	func RestoreFrom(snap: Image) -> void:
		image.copy_from(snap)
		dirty = true

	func Sync() -> void:
		if dirty:
			texture.update(image)
			dirty = false

signal OnLayersChanged
static var Instance: LayerManager
var Layers: Array = []
var ActiveIndex := 0
var _nextId := 0
var canvasWidth := 1920
var canvasHeight := 1080

var ActiveLayer:
	get:
		return Layers[ActiveIndex] if Layers.size() > 0 else null

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance):
		Instance = self
	else:
		U.Destroy(gameObject)
		return
	AddLayer("Background")
	Layers[0].image.fill(Color.WHITE)
	Layers[0].dirty = true

func AddLayer(n := ""):
	var nm := "%s %d" % [Loc.T("Layer", "Katman"), _nextId] if n.is_empty() else n
	var layer := Layer.new(_nextId, nm, canvasWidth, canvasHeight)
	_nextId += 1
	Layers.append(layer)
	ActiveIndex = Layers.size() - 1
	OnLayersChanged.emit()
	return layer

func RemoveLayer(index: int) -> void:
	if Layers.size() <= 1:
		return
	Layers.remove_at(index)
	ActiveIndex = clampi(ActiveIndex, 0, Layers.size() - 1)
	OnLayersChanged.emit()

func SetActive(index: int) -> void:
	ActiveIndex = clampi(index, 0, Layers.size() - 1)

func MoveLayer(from: int, to: int) -> void:
	if from < 0 or from >= Layers.size() or to < 0 or to >= Layers.size():
		return
	var l = Layers[from]
	Layers.remove_at(from)
	Layers.insert(to, l)
	OnLayersChanged.emit()

static func WithOpacity(src: Image, opacity: float) -> Image:
	if opacity >= 1.0:
		return src
	var img: Image = src.duplicate()
	var data := img.get_data()
	for i in range(3, data.size(), 4):
		data[i] = int(data[i] * opacity)
	img.set_data(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8, data)
	return img

func MergeDown(index: int) -> void:
	if index <= 0 or index >= Layers.size():
		return
	var top = Layers[index]
	var bottom = Layers[index - 1]
	UndoRedoManager.Instance.Push(UndoRedoManager.TakeSnapshot(Layers))
	bottom.image.blend_rect(WithOpacity(top.image, top.opacity), Rect2i(0, 0, canvasWidth, canvasHeight), Vector2i.ZERO)
	bottom.dirty = true
	RemoveLayer(index)

func Flatten() -> Image:
	var result := Image.create(canvasWidth, canvasHeight, false, Image.FORMAT_RGBA8)
	result.fill(Color.WHITE)
	for l in Layers:
		if not l.visible:
			continue
		result.blend_rect(WithOpacity(l.image, l.opacity), Rect2i(0, 0, canvasWidth, canvasHeight), Vector2i.ZERO)
	return result
