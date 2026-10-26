class_name PuzzleRewarder
extends Mono

var easyReward := 25
var mediumReward := 50
var hardReward := 100
var rewardText
var _difficulty := Difficulty.Medium

func OnEnable() -> void:
	PuzzleEvents.OnDifficultyChanged.AddListener(OnDifficultyChanged)
	PuzzleEvents.OnPuzzleCompleted.AddListener(OnPuzzleCompleted)

func OnDisable() -> void:
	PuzzleEvents.OnDifficultyChanged.RemoveListener(OnDifficultyChanged)
	PuzzleEvents.OnPuzzleCompleted.RemoveListener(OnPuzzleCompleted)

func OnDifficultyChanged(d: int) -> void:
	_difficulty = d

func OnPuzzleCompleted() -> void:
	var amount := mediumReward
	match _difficulty:
		Difficulty.Easy:
			amount = easyReward
		Difficulty.Hard:
			amount = hardReward
	if CurrencyManager.Instance != null and is_instance_valid(CurrencyManager.Instance):
		CurrencyManager.Instance.Add(CurrencyType.Gold, amount, false)
	if rewardText != null:
		rewardText.text = "+%d %s" % [amount, Loc.T("Gold", "Altın")]
