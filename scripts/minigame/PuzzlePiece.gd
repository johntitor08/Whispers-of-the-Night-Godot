class_name PuzzlePiece
extends Mono

var gridPos := Vector2i.ZERO
var manager
var rt: Control
var placed := false
var dragOffset := Vector2.ZERO

func Awake() -> void:
	rt = gameObject

func Initialize(gp: Vector2i, pm) -> void:
	gridPos = gp
	manager = pm

func _local_mouse(e) -> Vector2:
	return RT.screen_to_local(rt.get_parent(), e.position)

func OnBeginDrag(e) -> void:
	if placed:
		return
	dragOffset = RT.anchored_position(rt) - _local_mouse(e)
	PuzzleEvents.OnMoveMade.Invoke()

func OnDrag(e) -> void:
	if placed:
		return
	RT.set_anchored_position(rt, _local_mouse(e) + dragOffset)

func OnEndDrag(_e) -> void:
	if placed:
		return
	var correct: Vector2 = manager.GetCorrectPosition(gridPos)
	if RT.anchored_position(rt).distance_to(correct) < manager.GetSnapDistance():
		RT.set_anchored_position(rt, correct)
		placed = true
		rt.raycastTarget = false
		U.SetAsLastSibling(rt)
		manager.PlaySnapSound()
		manager.CheckWin()

func IsInCorrectPosition() -> bool:
	return placed

func ResetPiece() -> void:
	placed = false
	rt.raycastTarget = true
