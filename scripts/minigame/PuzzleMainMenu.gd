class_name PuzzleMainMenu
extends Mono

func Easy() -> void:
	PuzzleEvents.OnDifficultyChanged.Invoke(Difficulty.Easy)

func Medium() -> void:
	PuzzleEvents.OnDifficultyChanged.Invoke(Difficulty.Medium)

func Hard() -> void:
	PuzzleEvents.OnDifficultyChanged.Invoke(Difficulty.Hard)

func Play() -> void:
	PuzzleEvents.OnPuzzleRestarted.Invoke()
