class_name ProfileManager
extends Mono

static var Instance: ProfileManager
static var OnReady := UEvent.new()
signal OnProfileChanged(profile)
signal OnLevelUp(profile)
signal OnCurrencyChanged(profile)
var profile
var IsLoaded := false

func _on_injected(_root: Node) -> void:
	profile = PlayerProfile.from_dict(profile) if profile is Dictionary else profile

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self
	if profile == null:
		profile = PlayerProfile.new()
	OnReady.Invoke()

func CreateNewProfile(n := "Player") -> void:
	profile = PlayerProfile.new()
	profile.playerName = n
	OnProfileChanged.emit(profile)
	SaveSystem.SaveGame()

func SetPlayerName(n) -> void:
	if U.blank(n):
		return
	profile.playerName = str(n)
	OnProfileChanged.emit(profile)
	SaveSystem.SaveGame()

func AddExperience(amount: int) -> void:
	if amount <= 0:
		return
	profile.experience += amount
	while profile.experience >= profile.experienceToNextLevel:
		LevelUp()
	OnProfileChanged.emit(profile)
	SaveSystem.SaveGame()

func LevelUp() -> void:
	profile.experience -= profile.experienceToNextLevel
	profile.level += 1
	profile.experienceToNextLevel = U.RoundToInt(profile.experienceToNextLevel * 1.5)
	profile.statPoints += 3
	var ps = PlayerStats.Instance
	if ps != null:
		ps.ModifyMax(StatType.Health, 10)
		ps.ModifyMax(StatType.Energy, 5)
		ps.Modify(StatType.Health, 10)
		ps.Modify(StatType.Energy, 5)
		ps.Modify(StatType.Strength, 1)
		ps.Modify(StatType.Intelligence, 1)
	OnLevelUp.emit(profile)

func AddCurrency(amount: int) -> void:
	if CurrencyManager.Instance == null:
		return
	CurrencyManager.Instance.Add(CurrencyType.Gold, amount)
	OnProfileChanged.emit(profile)

func SpendCurrency(amount: int) -> bool:
	if CurrencyManager.Instance == null:
		return false
	var ok: bool = CurrencyManager.Instance.Spend(CurrencyType.Gold, amount)
	if ok:
		OnProfileChanged.emit(profile)
	return ok

func ApplyLoadedProfile(saved) -> void:
	profile.playerName = saved.playerName
	profile.level = saved.level
	profile.experience = saved.experience
	profile.experienceToNextLevel = saved.experienceToNextLevel
	profile.profileIconID = saved.profileIconID
	profile.statPoints = saved.statPoints
	profile.unlockedIconIDs = saved.unlockedIconIDs
	OnCurrencyChanged.emit(profile)
	OnProfileChanged.emit(profile)
	IsLoaded = true

func PurchaseIcon(id: String, cost: int) -> bool:
	if CurrencyManager.Instance == null:
		return false
	if profile.unlockedIconIDs.has(id) or not CurrencyManager.Instance.Spend(CurrencyType.Gold, cost):
		return false
	profile.unlockedIconIDs.append(id)
	OnProfileChanged.emit(profile)
	SaveSystem.SaveGame()
	return true

func UnlockIcon(id: String) -> void:
	if profile.unlockedIconIDs.has(id):
		return
	profile.unlockedIconIDs.append(id)
	OnProfileChanged.emit(profile)
	SaveSystem.SaveGame()

func SelectIcon(id: String) -> bool:
	if not profile.unlockedIconIDs.has(id):
		return false
	profile.profileIconID = id
	OnProfileChanged.emit(profile)
	SaveSystem.SaveGame()
	return true

func IsIconUnlocked(id: String) -> bool:
	return profile.unlockedIconIDs.has(id)
