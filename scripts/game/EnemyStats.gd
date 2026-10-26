class_name EnemyStats
extends StatsBase

var destroyOnDeath := true
var deathDelay := 0.1

func Awake() -> void:
	super.Awake()
	if stats.is_empty():
		stats = [NewStat(StatType.MaxHealth, 100, 1, 999), NewStat(StatType.Health, 100, 0, 999), NewStat(StatType.Strength, 5, 0, 999), NewStat(StatType.Defense, 3, 0, 999)]
		InitializeStats()

func InitializeFromData(data) -> void:
	if data == null:
		return
	stats.clear()
	stats.append(NewStat(StatType.MaxHealth, data.maxHealth, 1, data.maxHealth))
	stats.append(NewStat(StatType.Health, data.maxHealth, 0, data.maxHealth))
	stats.append(NewStat(StatType.Strength, data.attack, 0, 999))
	stats.append(NewStat(StatType.Defense, data.defense, 0, 999))
	stats.append(NewStat(StatType.Speed, data.speed, 0, 999))
	InitializeStats()

func OnDie() -> void:
	if CombatManager.Instance != null and CombatManager.Instance.inCombat:
		return
	if destroyOnDeath:
		_die_delayed()

func _die_delayed() -> void:
	var e := co()
	await U.wait(0.1)
	if dead(e):
		return
	U.Destroy(gameObject)
