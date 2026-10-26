class_name DailyCurrencyReward
extends Mono

var rewardType := CurrencyType.Gold
var baseRewardAmount := 100
var streakBonus := 50
var maxStreak := 30
var autoClaimOnStart := true
var lastClaim := 0
var currentStreak := 0

func Start() -> void:
	LoadLastClaimDate()
	if autoClaimOnStart:
		AutoClaimWhenReady()

func AutoClaimWhenReady() -> void:
	var t := 0.0
	while CurrencyManager.Instance == null and t < 5.0:
		t += U.unscaledDeltaTime
		await U.frame()
	if CurrencyManager.Instance != null:
		ClaimDailyReward()

func _now() -> int:
	return int(Time.get_unix_time_from_system())

func CanClaim() -> bool:
	if lastClaim <= 0 or _now() < lastClaim:
		return true
	return (_now() - lastClaim) / 3600.0 >= 24.0

func ClaimDailyReward() -> void:
	if not CanClaim():
		return
	var first := lastClaim <= 0
	var hrs := 0.0 if first else (_now() - lastClaim) / 3600.0
	var keep := not first and hrs >= 24.0 and hrs < 48.0
	currentStreak = mini(currentStreak + 1, maxStreak) if keep else 1
	var total := baseRewardAmount + streakBonus * maxi(0, currentStreak - 1)
	if CurrencyManager.Instance != null:
		CurrencyManager.Instance.AddMultiple({rewardType: total})
	lastClaim = _now()
	U.SetInt("LastDailyRewardClaimUnix", lastClaim)
	U.SetInt("DailyRewardStreak", currentStreak)
	U.PrefsSave()

func LoadLastClaimDate() -> void:
	lastClaim = U.GetInt("LastDailyRewardClaimUnix", 0)
	currentStreak = U.GetInt("DailyRewardStreak", 0)

func GetCurrentStreak() -> int:
	return currentStreak
