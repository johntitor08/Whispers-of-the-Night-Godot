class_name UndoRedoManager
extends Mono

static var Instance: UndoRedoManager
var maxHistory := 50
var _undoHistory: Array = []
var _redoStack: Array = []

var CanUndo: bool:
	get:
		return _undoHistory.size() > 1

var CanRedo: bool:
	get:
		return _redoStack.size() > 0

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance):
		Instance = self
	else:
		U.Destroy(gameObject)

func Push(snaps: Array) -> void:
	if _undoHistory.size() >= maxHistory:
		_undoHistory.pop_back()
	_undoHistory.push_front(snaps)
	_redoStack.clear()

func Undo():
	if _undoHistory.size() <= 1:
		return null
	_redoStack.push_back(_undoHistory.pop_front())
	return _undoHistory[0]

func Redo():
	if _redoStack.is_empty():
		return null
	var s = _redoStack.pop_back()
	_undoHistory.push_front(s)
	return s

static func TakeSnapshot(layers: Array) -> Array:
	var out := []
	for l in layers:
		out.append(l.image.duplicate())
	return out
