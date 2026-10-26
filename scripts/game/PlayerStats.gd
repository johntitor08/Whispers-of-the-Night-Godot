class_name PlayerStats
extends StatsBase

static var Instance: PlayerStats
static var OnReady := UEvent.new()
signal OnHealthChanged
signal OnEnergyChanged

var healthRemainder := 0.0
var energyRemainder := 0.0
var lastHealthDamageTime := -1000.0
var lastEnergyUseTime := -1000.0
var lastAttackTime := -1000.0
var enableHealthRegen := true
var healthRegenRate := 0.05
var healthRegenDelay := 5.0
var enableEnergyRegen := true
var energyRegenRate := 0.2
var energyRegenDelay := 2.0
var regenSaveDebounceSeconds := 5.0
var pendingSaveTime := -1.0
var hasPendingRegenSave := false
var baseDamage := 10
var attackCooldown := 1.0

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)
		return
	if stats.is_empty():
		stats = [NewStat(StatType.Health, 100, 0, 999), NewStat(StatType.MaxHealth, 100, 1, 999), NewStat(StatType.Energy, 100, 0, 999), NewStat(StatType.MaxEnergy, 100, 1, 999), NewStat(StatType.Strength, 10, 0, 999), NewStat(StatType.Intelligence, 10, 0, 999), NewStat(StatType.Charisma, 10, 0, 999), NewStat(StatType.Defense, 5, 0, 999), NewStat(StatType.Speed, 10, 0, 999), NewStat(StatType.Luck, 5, 0, 999)]
	super.Awake()
	Set(StatType.Health, Get(StatType.MaxHealth), true)
	Set(StatType.Energy, Get(StatType.MaxEnergy), true)
	OnReady.Invoke()

func Update() -> void:
	HandleRegeneration()
	if hasPendingRegenSave and U.time >= pendingSaveTime:
		hasPendingRegenSave = false
		SaveSystem.SaveGame()

func Modify(type: int, amount: int, save := true) -> void:
	if amount < 0:
		if type == StatType.Health:
			lastHealthDamageTime = U.time
		elif type == StatType.Energy:
			lastEnergyUseTime = U.time
	super.Modify(type, amount, save)
	if type == StatType.MaxHealth:
		SyncResourceCap(StatType.Health, StatType.MaxHealth)
	if type == StatType.MaxEnergy:
		SyncResourceCap(StatType.Energy, StatType.MaxEnergy)
	if type == StatType.Health:
		OnHealthChanged.emit()
	elif type == StatType.Energy:
		OnEnergyChanged.emit()

func Set(type: int, value: int, save := true) -> void:
	super.Set(type, value, save)
	if type == StatType.MaxHealth:
		SyncResourceCap(StatType.Health, StatType.MaxHealth)
	elif type == StatType.MaxEnergy:
		SyncResourceCap(StatType.Energy, StatType.MaxEnergy)
	elif type == StatType.Health:
		OnHealthChanged.emit()
	elif type == StatType.Energy:
		OnEnergyChanged.emit()

func RefreshResourceCaps() -> void:
	SyncResourceCap(StatType.Health, StatType.MaxHealth)
	SyncResourceCap(StatType.Energy, StatType.MaxEnergy)

func SyncResourceCap(resource: int, cap: int) -> void:
	if statDict.has(resource):
		var stat: Dictionary = statDict[resource]
		stat.maxValue = Get(cap)
		stat.currentValue = clampi(stat.currentValue, stat.minValue, stat.maxValue)
	if resource == StatType.Health:
		OnHealthChanged.emit()
	else:
		OnEnergyChanged.emit()

func ApplyEffectModifiers(type: int, base_value: int) -> int:
	var value := super.ApplyEffectModifiers(type, base_value)
	if type == StatType.Health or type == StatType.Energy or EquipmentManager.Instance == null:
		return value
	return value + EquipmentManager.Instance.GetStatBonus(type)

func RemoveBakedEquipmentBonuses() -> void:
	if EquipmentManager.Instance == null:
		return
	for stat in stats:
		if stat.type == StatType.Health or stat.type == StatType.Energy:
			continue
		var bonus: int = EquipmentManager.Instance.GetStatBonus(stat.type)
		if bonus != 0:
			Set(stat.type, stat.currentValue - bonus, false)
	RefreshResourceCaps()

func Attack(target) -> void:
	if target == null or U.time - lastAttackTime < attackCooldown:
		return
	target.Modify(StatType.Health, -(baseDamage + Get(StatType.Strength)))
	lastAttackTime = U.time

func HandleRegeneration() -> void:
	var hm := 1.0
	var em := 1.0
	if PlayerBuffManager.Instance != null:
		for buff in PlayerBuffManager.Instance.GetActiveBuffs():
			if buff.type == PlayerBuffManager.BuffType.HealthRegen:
				hm += buff.multiplier
			elif buff.type == PlayerBuffManager.BuffType.EnergyRegen:
				em += buff.multiplier
	if enableHealthRegen and U.time - lastHealthDamageTime >= healthRegenDelay:
		if Get(StatType.Health) < Get(StatType.MaxHealth):
			healthRemainder += healthRegenRate * hm * U.deltaTime
			if healthRemainder >= 1.0:
				var regen := floori(healthRemainder)
				Modify(StatType.Health, regen, false)
				healthRemainder -= regen
				ScheduleRegenSave()
	if enableEnergyRegen and U.time - lastEnergyUseTime >= energyRegenDelay:
		if Get(StatType.Energy) < Get(StatType.MaxEnergy):
			energyRemainder += energyRegenRate * em * U.deltaTime
			if energyRemainder >= 1.0:
				var regen2 := floori(energyRemainder)
				Modify(StatType.Energy, regen2, false)
				energyRemainder -= regen2
				ScheduleRegenSave()

func FullRestore() -> void:
	Set(StatType.Health, Get(StatType.MaxHealth), true)
	Set(StatType.Energy, Get(StatType.MaxEnergy), true)

func ModifyMax(type: int, amount: int) -> void:
	var mt := type
	if type == StatType.Health:
		mt = StatType.MaxHealth
	elif type == StatType.Energy:
		mt = StatType.MaxEnergy
	Modify(mt, amount, true)

func HasEnoughEnergy(amount: int) -> bool:
	return Get(StatType.Energy) >= amount

func IsAlive() -> bool:
	return Get(StatType.Health) > 0

func GetHealthPercentage() -> float:
	return 0.0 if Get(StatType.MaxHealth) <= 0 else float(Get(StatType.Health)) / Get(StatType.MaxHealth)

func GetEnergyPercentage() -> float:
	return 0.0 if Get(StatType.MaxEnergy) <= 0 else float(Get(StatType.Energy)) / Get(StatType.MaxEnergy)

func GetPowerScore() -> float:
	var score := 0.0
	score += Get(StatType.Strength) * 2.0
	score += Get(StatType.Intelligence) * 1.8
	score += Get(StatType.Defense) * 1.5
	score += Get(StatType.MaxHealth) * 0.5
	score += Get(StatType.Speed) * 1.2
	score += Get(StatType.Luck) * 1.0
	score += Get(StatType.Charisma) * 0.8
	if ProfileManager.Instance != null:
		score += ProfileManager.Instance.profile.level * 5.0
	return U.Round(score)

func ScheduleRegenSave() -> void:
	pendingSaveTime = U.time + regenSaveDebounceSeconds
	hasPendingRegenSave = true

func SaveStats() -> void:
	SaveSystem.SaveGame()

func OnDie() -> void:
	print("Player died!")
