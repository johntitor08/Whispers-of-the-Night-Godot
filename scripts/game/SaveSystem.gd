class_name SaveSystem

const StatsVersion := 1
static var CachedData = null
static var IsLoading := false
static var SavingEnabled := false
static var activeSlot := 0

static func GetSavePath(slot: int) -> String:
	return "user://save_slot_%d.json" % slot

static func SavePath() -> String:
	return GetSavePath(activeSlot)

static func SetActiveSlot(slot: int) -> void:
	activeSlot = maxi(0, slot)

static func HasSaveFileSlot(slot: int) -> bool:
	return FileAccess.file_exists(GetSavePath(slot))

static func HasSaveFile() -> bool:
	return FileAccess.file_exists(SavePath())

static func _read(path: String):
	if not FileAccess.file_exists(path):
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var v = JSON.parse_string(f.get_as_text())
	return v if v is Dictionary else null

static func PeekSlot(slot: int):
	return _read(GetSavePath(slot))

static func DeleteSaveSlot(slot: int) -> void:
	var p := GetSavePath(slot)
	if FileAccess.file_exists(p):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(p))

static func DeleteSave() -> void:
	DeleteSaveSlot(activeSlot)

static func SaveGameSlot(slot: int) -> void:
	SetActiveSlot(slot)
	SaveGame(true)

static func LoadGameSlot(slot: int) -> void:
	SetActiveSlot(slot)
	LoadGame()

static func NewData() -> Dictionary:
	return {
		"playerName": "Player", "playerLevel": 1, "playerExperience": 0, "playerExperienceToNext": 100,
		"currentScene": "", "sceneProgress": 0, "originID": "", "storyFlags": [], "currentTimePhase": 0,
		"currentDay": 1, "phaseProgress": 0.0, "resumeDialogueOnLoad": false, "dayScenarioPending": false,
		"inventoryKeys": [], "inventoryCounts": [], "equippedItems": [], "currencyTypes": [], "currencyAmounts": [],
		"shopStockIDs": [], "shopStockAmounts": [], "statTypes": [], "statValues": [], "statsVersion": 0,
		"activeQuestIDs": [], "activeQuests": [], "completedQuests": [], "trackedQuests": [], "questTimerKeys": [],
		"questTimerValues": [], "selectedOptionalRewardQuestIDs": [], "selectedOptionalRewardItemIDs": [],
		"activeScenarioID": "", "activeScenarioStep": 0, "activeScenarioStepName": "", "activeScenarioRetreated": false,
		"completedScenarios": [], "affinityKeys": [], "affinityValues": [], "combatWins": 0, "guideUnlocked": [], "savedAt": "",
	}

static func SaveGame(isManual := false) -> void:
	if not SavingEnabled or IsLoading or (not isManual and SettingsManager.Instance != null and not SettingsManager.Instance.IsAutosaveEnabled()):
		return
	var data := NewData()
	var dt := Time.get_datetime_dict_from_system()
	data.savedAt = "%04d-%02d-%02d %02d:%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute]
	if ProfileManager.Instance != null:
		var p = ProfileManager.Instance.profile
		data.playerName = p.playerName
		data.playerLevel = p.level
		data.playerExperience = p.experience
		data.playerExperienceToNext = p.experienceToNextLevel
	var cs := U.scene_root()
	data.currentScene = cs.name if cs != null else "GameScene"
	data.statsVersion = StatsVersion
	data.storyFlags = StoryFlags.GetAll()
	if OriginManager.Instance != null:
		data.originID = OriginManager.Instance.GetSaveID()
	if SceneEvent.Instance != null:
		data.sceneProgress = SceneEvent.Instance.Progress
		data.dayScenarioPending = SceneEvent.Instance.DayScenarioPending
	if TimePhaseManager.Instance != null:
		data.currentTimePhase = TimePhaseManager.Instance.currentPhase
		data.phaseProgress = TimePhaseManager.Instance.GetPhaseProgress()
	if TimeUI.Instance != null:
		data.currentDay = TimeUI.Instance.GetCurrentDay()
	if InventoryManager.Instance != null:
		var stock: Dictionary = InventoryManager.Instance.GetRawStock()
		for k in stock:
			data.inventoryKeys.append(k)
			data.inventoryCounts.append(stock[k])
	if EquipmentManager.Instance != null:
		var eq: Dictionary = EquipmentManager.Instance.GetAllEquipped()
		for slot in eq:
			data.equippedItems.append({"slot": slot, "itemID": eq[slot].baseData.itemID, "upgradeLevel": eq[slot].upgradeLevel})
	if CurrencyManager.Instance != null:
		var cur: Dictionary = CurrencyManager.Instance.GetAllCurrencies()
		for t in cur:
			data.currencyTypes.append(t)
			data.currencyAmounts.append(cur[t])
	if ShopManager.Instance != null:
		for s in ShopManager.Instance.GetStockDataForSave():
			data.shopStockIDs.append(s.itemID)
			data.shopStockAmounts.append(s.amount)
	if ScenarioManager.Instance != null:
		var sm = ScenarioManager.Instance
		data.completedScenarios = sm.GetSaveData().completedScenarioIDs
		if sm.IsScenarioActive():
			var scen = sm.GetCurrentScenario()
			data.activeScenarioID = scen.scenarioID
			data.activeScenarioStep = sm.GetCurrentStepIndex()
			var idx: int = data.activeScenarioStep
			var steps = scen.steps
			data.activeScenarioStepName = steps[idx].stepName if steps != null and idx >= 0 and idx < steps.size() and steps[idx] != null else ""
			data.activeScenarioRetreated = sm.IsWaitingAfterRetreat
	if AffinityManager.Instance != null:
		AffinityManager.Instance.ExportTo(data.affinityKeys, data.affinityValues)
	data.combatWins = Achievements.Wins
	GuideManager.ExportTo(data.guideUnlocked)
	if QuestManager.Instance != null:
		var qs: Dictionary = QuestManager.Instance.GetSaveData()
		data.activeQuestIDs = qs.activeQuestIDs
		data.activeQuests = qs.runtimeStates
		data.completedQuests = qs.completedQuestIDs
		data.trackedQuests = qs.trackedQuestIDs
		data.questTimerKeys = qs.questTimerKeys
		data.questTimerValues = qs.questTimerValues
		data.selectedOptionalRewardQuestIDs = qs.selectedOptionalRewardQuestIDs
		data.selectedOptionalRewardItemIDs = qs.selectedOptionalRewardItemIDs
	if PlayerStats.Instance != null:
		for s in PlayerStats.Instance.stats:
			data.statTypes.append(s.type)
			data.statValues.append(s.currentValue)
	var f := FileAccess.open(SavePath(), FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(data, "\t"))

static func LoadGame() -> void:
	if not HasSaveFile():
		return
	SavingEnabled = true
	CachedData = _read(SavePath())
	if CachedData == null:
		return
	IsLoading = true
	UScene.OnSceneBooted.AddListener(OnSceneLoaded)
	var scn := str(CachedData.get("currentScene", "GameScene"))
	if scn == "":
		scn = "GameScene"
	U.LoadScene("res://scenes/%s.tscn" % scn)

static func OnSceneLoaded(_root = null) -> void:
	UScene.OnSceneBooted.RemoveListener(OnSceneLoaded)
	if CachedData != null and SceneEvent.Instance != null:
		DelayedApply(CachedData)
	CachedData = null

static func DelayedApply(data: Dictionary) -> void:
	await U.frame()
	ApplyLoadedData(data)

static func _g(d: Dictionary, k: String, def = null):
	var v = d.get(k)
	return def if v == null else v

static func ApplyLoadedData(data) -> void:
	if data == null:
		return
	var base := NewData()
	for k in data:
		base[k] = data[k]
	data = base
	IsLoading = true
	if ProfileManager.Instance != null:
		var prof := PlayerProfile.new()
		prof.playerName = str(data.playerName)
		prof.level = int(data.playerLevel)
		prof.experience = int(data.playerExperience)
		prof.experienceToNextLevel = int(data.playerExperienceToNext)
		prof.profileIconID = "default"
		ProfileManager.Instance.ApplyLoadedProfile(prof)
	StoryFlags.Reset()
	StoryFlags.Load(data.storyFlags)
	if AffinityManager.Instance != null:
		AffinityManager.Instance.ImportFrom(data.affinityKeys, data.affinityValues)
	Achievements.Wins = int(data.combatWins)
	GuideManager.ImportFrom(data.guideUnlocked)
	if OriginManager.Instance != null and not U.empty(data.originID):
		OriginManager.Instance.LoadFromSaveID(str(data.originID))
	if SceneEvent.Instance != null:
		SceneEvent.Instance.DayScenarioPending = bool(data.dayScenarioPending)
		SceneEvent.Instance.UnsubscribeDialogue()
		SceneEvent.Instance.SubscribeDialogue()
		SceneEvent.Instance.ApplySceneProgress(int(data.sceneProgress))
	if TimePhaseManager.Instance != null:
		TimePhaseManager.Instance.SetPhase(int(data.currentTimePhase))
		TimePhaseManager.Instance.SetPhaseProgress(float(data.phaseProgress))
	if TimeUI.Instance != null:
		TimeUI.Instance.SetDay(int(data.currentDay))
	if InventoryManager.Instance != null:
		InventoryManager.Instance.Clear()
		var keys: Array = data.inventoryKeys
		if ItemDatabase.Instance != null:
			for i in keys.size():
				var key := str(keys[i])
				var sep := key.rfind(":")
				if sep < 0:
					continue
				var id := key.substr(0, sep)
				var lvl_s := key.substr(sep + 1)
				if not lvl_s.is_valid_int():
					continue
				var item = ItemDatabase.Instance.GetByID(id)
				if item == null:
					continue
				var qty := int(data.inventoryCounts[i])
				if item is EquipmentData:
					InventoryManager.Instance.AddUpgradedItem(item, int(lvl_s), qty)
				else:
					InventoryManager.Instance.AddItem(item, qty)
	if EquipmentManager.Instance != null:
		var restored := []
		if ItemDatabase.Instance != null:
			for saved in data.equippedItems:
				var eq = ItemDatabase.Instance.GetByID(str(saved.get("itemID", "")))
				if eq is EquipmentData:
					restored.append(EquipmentInstance.new(eq, int(saved.get("upgradeLevel", 0))))
		EquipmentManager.Instance.RestoreEquipped(restored)
	if CurrencyManager.Instance != null:
		for i in data.currencyTypes.size():
			CurrencyManager.Instance.Set(int(data.currencyTypes[i]), int(data.currencyAmounts[i]))
	if ShopManager.Instance != null:
		ShopManager.Instance.ApplyLoadedStock(data.shopStockIDs, data.shopStockAmounts)
	if ScenarioManager.Instance != null:
		ScenarioManager.Instance.LoadSaveData({"completedScenarioIDs": data.completedScenarios})
	if QuestManager.Instance != null:
		var active: Array = data.activeQuestIDs.duplicate()
		if active.is_empty() and data.activeQuests.size() > 0:
			var done: Array = data.completedQuests
			for st in data.activeQuests:
				if st != null and not U.empty(st.get("questID")) and not done.has(st.questID):
					active.append(st.questID)
		QuestManager.Instance.LoadSaveData({
			"activeQuestIDs": active, "runtimeStates": data.activeQuests, "completedQuestIDs": data.completedQuests,
			"trackedQuestIDs": data.trackedQuests, "questTimerKeys": data.questTimerKeys, "questTimerValues": data.questTimerValues,
			"selectedOptionalRewardQuestIDs": data.selectedOptionalRewardQuestIDs, "selectedOptionalRewardItemIDs": data.selectedOptionalRewardItemIDs,
		})
	if PlayerStats.Instance != null:
		for i in data.statTypes.size():
			PlayerStats.Instance.Set(int(data.statTypes[i]), int(data.statValues[i]), true)
		if int(data.statsVersion) < StatsVersion:
			PlayerStats.Instance.RemoveBakedEquipmentBonuses()
	if ProfileUI.Instance != null:
		ProfileUI.Instance.RefreshAll()
	var sid := str(data.activeScenarioID)
	var has_active: bool = ScenarioManager.Instance != null and sid != "" and ScenarioManager.Instance.GetScenarioByID(sid) != null
	if has_active:
		IsLoading = false
		ResumeScenarioAfterLoad(sid, ScenarioManager.Instance.ResolveStepIndex(sid, int(data.activeScenarioStep), str(data.activeScenarioStepName)), bool(data.activeScenarioRetreated))
		return
	if DialogueManager.Instance != null or SceneEvent.Instance != null:
		ClearAndStartDialogue(int(data.sceneProgress))
	else:
		IsLoading = false

static func ClearAndStartDialogue(idx: int) -> void:
	IsLoading = false
	await U.frame()
	if SceneEvent.Instance != null:
		await SceneEvent.Instance.StartDialogueAfterLoad(idx)

static func ResumeScenarioAfterLoad(sid: String, step: int, wait_square: bool) -> void:
	await U.frame()
	if ScenarioManager.Instance != null:
		ScenarioManager.Instance.ResumeScenario(sid, step, wait_square)
