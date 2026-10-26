class_name MinigameLaunchButton
extends Mono

enum Target { Puzzle, Drawing }
var target := 0

func OnPointerClick(_e) -> void:
	if MinigameLauncher.Instance == null or not is_instance_valid(MinigameLauncher.Instance):
		push_warning("[MinigameLaunchButton] No MinigameLauncher in scene.")
		return
	if MinigameLauncher.Instance.InMinigame:
		return
	match target:
		Target.Puzzle:
			MinigameLauncher.Instance.LaunchPuzzle()
		Target.Drawing:
			MinigameLauncher.Instance.LaunchDrawing()
