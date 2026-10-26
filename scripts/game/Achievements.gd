class_name Achievements
extends Node

const FirstNight := "ACH_FIRST_NIGHT"
const Day2 := "ACH_DAY_2"
const Day3 := "ACH_DAY_3"
const Day4 := "ACH_DAY_4"
const Finale := "ACH_TO_BE_CONTINUED"
const Origin := "ACH_ORIGIN"
const FirstVictory := "ACH_FIRST_VICTORY"
const Hunter := "ACH_HUNTER"
const Voss := "ACH_VOSS"
const SerenaTrust := "ACH_SERENA_TRUST"
const Level5 := "ACH_LEVEL_5"
const Upgrade := "ACH_UPGRADE"
const Fusion := "ACH_FUSION"
const Legendary := "ACH_LEGENDARY"
const Puzzle := "ACH_PUZZLE"
const Rich := "ACH_RICH"
const HunterWins := 20
const RichGold := 1000
const SerenaAffinity := 20
const LevelTarget := 5
const PREFS_KEY := "achievements_unlocked"

static var Wins := 0
static var instance: Achievements
var hookedCombat
var nextCheck := 0.0
var unlocked: Dictionary = {}

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	instance = self
	for a in U.GetString(PREFS_KEY, "").split(",", false):
		unlocked[a] = true
	PuzzleEvents.OnPuzzleCompleted.AddListener(OnPuzzleCompleted)

func _exit_tree() -> void:
	PuzzleEvents.OnPuzzleCompleted.RemoveListener(OnPuzzleCompleted)

func _process(_dt: float) -> void:
	if Engine.is_editor_hint():
		return
	var combat = CombatManager.Instance if is_instance_valid(CombatManager.Instance) else null
	if combat != hookedCombat:
		if is_instance_valid(hookedCombat):
			U.off(hookedCombat.OnCombatVictory, OnCombatVictory)
		hookedCombat = combat
		if hookedCombat != null:
			U.on(hookedCombat.OnCombatVictory, OnCombatVictory)
	var now := Time.get_ticks_msec() / 1000.0
	if now >= nextCheck:
		nextCheck = now + 1.0
		CheckStates()

func CheckStates() -> void:
	var sc = ScenarioManager.Instance if is_instance_valid(ScenarioManager.Instance) else null
	if sc != null:
		if sc.IsScenarioCompleted("ashenveil_day2") or IsActive(sc, "ashenveil_day2"):
			Set(FirstNight)
		if sc.IsScenarioCompleted("ashenveil_day2"):
			Set(Day2)
		if sc.IsScenarioCompleted("ashenveil_day3"):
			Set(Day3)
		if sc.IsScenarioCompleted("ashenveil_day4"):
			Set(Day4)
		if sc.IsScenarioCompleted("ashenveil_bound_archivist_q3") or sc.IsScenarioCompleted("ashenveil_foreign_echo_q3") or sc.IsScenarioCompleted("ashenveil_sinned_guardian_q3"):
			Set(Origin)
	if StoryFlags.Has("ashenveil_finale_shown"):
		Set(Finale)
	if is_instance_valid(ProfileManager.Instance) and ProfileManager.Instance.profile != null and ProfileManager.Instance.profile.level >= LevelTarget:
		Set(Level5)
	if is_instance_valid(CurrencyManager.Instance) and CurrencyManager.Instance.Get(CurrencyType.Gold) >= RichGold:
		Set(Rich)
	if is_instance_valid(AffinityManager.Instance) and AffinityManager.Instance.Get("Serena") >= SerenaAffinity:
		Set(SerenaTrust)
	CheckGear()

static func IsActive(sc, id: String) -> bool:
	var cur = sc.currentScenario
	return cur != null and cur.scenarioID == id

func CheckGear() -> void:
	var flags := [false, false]
	if is_instance_valid(InventoryManager.Instance):
		for pair in InventoryManager.Instance.GetEquipmentInstances():
			Inspect(pair[0], flags)
	if is_instance_valid(EquipmentManager.Instance):
		for s in EquipmentSlot.NAMES.size():
			Inspect(EquipmentManager.Instance.GetEquipped(s), flags)
	if flags[0]:
		Set(Legendary)
	if flags[1]:
		Set(Upgrade)

static func Inspect(inst, flags: Array) -> void:
	if inst == null or inst.baseData == null:
		return
	if int(inst.baseData.rarity) == Rarity.Legendary:
		flags[0] = true
	if inst.upgradeLevel > 0:
		flags[1] = true

func OnCombatVictory(enemy) -> void:
	Set(FirstVictory)
	if enemy != null and enemy.name == "Voss":
		Set(Voss)
	Wins += 1
	if Wins >= HunterWins:
		Set(Hunter)

func OnPuzzleCompleted() -> void:
	Set(Puzzle)

static func Unlock(apiName: String) -> void:
	if instance != null and is_instance_valid(instance):
		instance.Set(apiName)

func Set(apiName: String) -> void:
	if unlocked.has(apiName):
		return
	unlocked[apiName] = true
	U.SetString(PREFS_KEY, ",".join(unlocked.keys()))
	U.PrefsSave()
