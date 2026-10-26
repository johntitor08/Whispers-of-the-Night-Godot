class_name MinigameExitButton
extends Mono

var allowEscapeKey := true

func Update() -> void:
	if allowEscapeKey and U.GetKeyDown(KEY_ESCAPE):
		ExitToGame()

func ExitToGame() -> void:
	if MinigameLauncher.Instance != null and is_instance_valid(MinigameLauncher.Instance) and MinigameLauncher.Instance.InMinigame:
		MinigameLauncher.Instance.ReturnToGame()
