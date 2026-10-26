class_name PuzzleManager
extends Mono

var piecePrefab
var puzzleContainer
var gameUI
var gridX := 5
var gridY := 5
var puzzleSize := Vector2(1200, 900)
var audioSource
var snapClip
var currentImage
var pieceSize := Vector2.ZERO
var pieces: Array = []

func OnEnable() -> void:
	PuzzleEvents.OnImageChanged.AddListener(SetPuzzleImage)
	PuzzleEvents.OnDifficultyChanged.AddListener(SetDifficulty)
	PuzzleEvents.OnPuzzleRestarted.AddListener(RestartPuzzle)

func OnDisable() -> void:
	PuzzleEvents.OnImageChanged.RemoveListener(SetPuzzleImage)
	PuzzleEvents.OnDifficultyChanged.RemoveListener(SetDifficulty)
	PuzzleEvents.OnPuzzleRestarted.RemoveListener(RestartPuzzle)

func SetPuzzleImage(image) -> void:
	currentImage = image
	RestartPuzzle()

func SetDifficulty(diff: int) -> void:
	match diff:
		Difficulty.Easy:
			gridX = 4
		Difficulty.Medium:
			gridX = 5
		Difficulty.Hard:
			gridX = 6
	gridY = gridX
	RestartPuzzle()

func RestartPuzzle() -> void:
	ClearPuzzle()
	if gameUI != null:
		gameUI.ResetUI()
	if currentImage == null:
		return
	CreatePuzzle()

func CreatePuzzle() -> void:
	var cont = U.go_of(puzzleContainer)
	RT.set_size_with_current_anchors(cont, 0, puzzleSize.x)
	RT.set_size_with_current_anchors(cont, 1, puzzleSize.y)
	pieceSize = Vector2(puzzleSize.x / gridX, puzzleSize.y / gridY)
	var tex: Texture2D = currentImage.texture
	var pixelW := int(tex.get_width() / gridX)
	var pixelH := int(tex.get_height() / gridY)
	for y in gridY:
		for x in gridX:
			var obj = U.go_of(U.Instantiate(piecePrefab, cont))
			RT.set_size_delta(obj, pieceSize)
			obj.scale = Vector2.ONE
			var spr := USprite.from_texture(tex, "piece_%d_%d" % [x, y])
			spr.region = Rect2(x * pixelW, y * pixelH, pixelW, pixelH)
			obj.sprite = spr
			var piece = U.GetComponent(obj, PuzzlePiece)
			piece.Initialize(Vector2i(x, y), self)
			pieces.append(piece)
	ShufflePieces()
	PuzzleEvents.OnPuzzleStarted.Invoke()

func ShufflePieces() -> void:
	if pieces.is_empty():
		return
	var positions: Array[Vector2] = []
	var gridCols := ceili(puzzleSize.x / pieceSize.x)
	var gridRows := ceili(puzzleSize.y / pieceSize.y)
	var cellWidth := puzzleSize.x / gridCols
	var cellHeight := puzzleSize.y / gridRows
	for y in gridRows:
		for x in gridCols:
			positions.append(Vector2(-puzzleSize.x / 2.0 + cellWidth / 2.0 + x * cellWidth, puzzleSize.y / 2.0 - cellHeight / 2.0 - y * cellHeight))
	for i in positions.size():
		var j := randi_range(i, positions.size() - 1)
		var tmp := positions[j]
		positions[j] = positions[i]
		positions[i] = tmp
	for i in pieces.size():
		var piece = pieces[i]
		var pos := positions[i]
		pos += Vector2(randf_range(-cellWidth * 0.3, cellWidth * 0.3), randf_range(-cellHeight * 0.3, cellHeight * 0.3))
		var correct := GetCorrectPosition(piece.gridPos)
		if pos.distance_to(correct) < GetSnapDistance():
			pos += Vector2(GetSnapDistance(), GetSnapDistance())
		RT.set_anchored_position(piece.gameObject, pos)
		piece.ResetPiece()

func GetCorrectPosition(gp: Vector2i) -> Vector2:
	var startX := -puzzleSize.x / 2.0 + pieceSize.x / 2.0
	var startY := puzzleSize.y / 2.0 - pieceSize.y / 2.0
	return Vector2(startX + gp.x * pieceSize.x, startY - gp.y * pieceSize.y)

func GetSnapDistance() -> float:
	return minf(pieceSize.x, pieceSize.y) * 0.35

func PlaySnapSound() -> void:
	if audioSource != null and snapClip != null:
		audioSource.PlayOneShot(snapClip)

func CheckWin() -> void:
	for p in pieces:
		if not p.IsInCorrectPosition():
			return
	PuzzleEvents.OnPuzzleCompleted.Invoke()

func ClearPuzzle() -> void:
	for p in pieces:
		if is_instance_valid(p):
			U.Destroy(p.gameObject)
	pieces.clear()
