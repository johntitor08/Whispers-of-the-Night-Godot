class_name GameUI
extends Mono

var movesText
var timeText
var winPanel
var winMovesText
var winTimeText
var imageSelector
var moves := 0
var startTime := 0.0
var timerRunning := false

func _now() -> float:
	return U.time

func OnEnable() -> void:
	PuzzleEvents.OnMoveMade.AddListener(IncrementMoves)
	PuzzleEvents.OnPuzzleCompleted.AddListener(ShowWinPanel)
	PuzzleEvents.OnPuzzleRestarted.AddListener(ResetUI)
	PuzzleEvents.OnPuzzleStarted.AddListener(StartTimer)

func OnDisable() -> void:
	PuzzleEvents.OnMoveMade.RemoveListener(IncrementMoves)
	PuzzleEvents.OnPuzzleCompleted.RemoveListener(ShowWinPanel)
	PuzzleEvents.OnPuzzleRestarted.RemoveListener(ResetUI)
	PuzzleEvents.OnPuzzleStarted.RemoveListener(StartTimer)

func Update() -> void:
	if not timerRunning:
		return
	var elapsed := _now() - startTime
	var m := floori(elapsed / 60.0)
	var s := floori(fmod(elapsed, 60.0))
	timeText.text = "%s: %02d:%02d" % [Loc.T("Time", "Süre"), m, s]

func StartTimer() -> void:
	startTime = _now()
	timerRunning = true

func IncrementMoves() -> void:
	moves += 1
	movesText.text = "%s: %d" % [Loc.T("Moves", "Hamle"), moves]

func ShowWinPanel() -> void:
	timerRunning = false
	U.SetActive(winPanel, true)
	winMovesText.text = "%s: %d" % [Loc.T("Moves", "Hamle"), moves]
	winTimeText.text = timeText.text

func ResetUI() -> void:
	moves = 0
	startTime = _now()
	timerRunning = true
	movesText.text = "%s: 0" % Loc.T("Moves", "Hamle")
	timeText.text = "%s: 00:00" % Loc.T("Time", "Süre")
	if winPanel != null:
		U.SetActive(winPanel, false)

func Replay() -> void:
	ResetUI()
	if imageSelector != null and imageSelector.GetImageCount() > 0:
		imageSelector.SelectNewRandomImage()
	else:
		PuzzleEvents.OnPuzzleRestarted.Invoke()
