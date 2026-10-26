class_name SceneEvent
extends Mono

static var Instance: SceneEvent

enum PhaseCondition { Any, MorningOrNoon, NotNight, NightOnly, NoonOrEvening, MorningOnly, EveningOrNight }
enum MapGroup { Modern, Fantasy, Combat }
enum HoverAction { None, EnterTown, OpenMarket, OpenChurch, OpenHome, OpenOffice, OpenGym, SleepToNextDay, ShowGardenHole, ShowPool, CollectItem, OpenStove, QuestInteract, QuestTalk, QuestCombat, GoToQuestLocation, ReturnToTown }

signal OnBackgroundChanged(index: int)

const validMapIndices := [6, 8, 13]
const HudRevealDelay := 0.3
const SceneDipOut := 0.35
const SceneDipIn := 0.4
const BedroomBackground := 13
const LastDayQuests := ["q10_acik_hesap", "q11_fincan_basinda"]
const EndingDoorHeld := "ending_door_held"
const EndingOpenAccount := "ending_open_account"
const EndingTwoInTheDoor := "ending_two_in_the_door"
const SharedEpilogueScenario := "ashenveil_red_saint"
const SharedEpilogueStartFlag := "red_saint_start"
const HalfBodyCharacterSprites := ["char_mireya_00001_"]
const DialogueCharacterLayoutOverrides := [
	["ComfyUI_01231_", Vector2(0, -260), Vector2(1000, 1000)],
	["ComfyUI_01241_", Vector2(0, -260), Vector2(1000, 1000)],
	["bg26_morning", Vector2(250, -260), Vector2(1000, 1000)],
]

var progress := SceneProgress.Scene1
var currentMapIndex := 0
var _validMapCursor := 0
var isDialogueSubscribed := false
var isHoverEffectsSubscribed := false
var _hoverClickActions: Array = []
var _currentVictoryHandler = null
var _currentDefeatHandler = null
var _currentFleeHandler = null
var _lastBgIndex := -1
var _lastCharIndex := -1
var _currentQuestLocation = null
var dayScenarioPending := false
var _transitionBusySince := -1.0
var _sceneCharacterActive := false
var _doorClicked := false
var _lastObservedPhase := TimePhase.Morning
var _itemDefaultY: Array = []
var _mapIconDefaultPos: Array = []
var charRtAnchoredTransform := Vector2.ZERO
var charRtSizeDelta := Vector2.ZERO
var charFadeCoroutine := false
var _char_gen := 0
var _charFadingOut := false
var _charImageFromDialogue := false
var _dialogueBgCurrent
var _dialogueBgPending
var _hudRoutine := false
var _wasInCombat := false
var _keepingSpeaker := false
var _sceneFade
var _sceneFadeRoutine := false
var _fade_gen := 0
var _holdFrame
var _holdSprite
var _transitionDepth := 0

var itemDatabase
var mapTitleText
var townNpc
var backgroundImage
var backgrounds: Array = []
var questLocationBackgrounds: Array = []
var charImage
var characters: Array = []
var hoverRegions: Array = []
var worldItems: Array = []
var dialogueCharacterPosition := Vector2.ZERO
var dialogueCharacterSize := Vector2(700, 700)
var sceneStartDialogueNodes: Array = []
var scene9SecondNode
var scene9FifthNode
var finaleCutsceneNode
var marenTeaDialogue
var marenDeliveryNode
var enemies: Array = []
var mapImage
var combatMapImage
var maps: Array = []
var settingsIconPanel
var iconPanel
var timePanel
var settingsPanel
var savePanel
var minigameLauncherPanel
var profilePanel
var inventoryPanel
var shopPanel
var mapPanel
var combatMapPanel
var equipmentPanel
var coinPanel
var questPanel
var houseIconsPanel
var sleepingPanel
var diversionsPanel
var earliestSleepPhase := TimePhase.Evening
var settingsIcon
var profileIcon
var inventoryIcon
var mapIcon
var coinIcon
var questIcon
var combatIcon
var diversionsIcon
var mapLocations: Array = []
var roomIcons: Array = []
var closeMapButton
var closeCombatMapButton
var timePanelAnimator
var iconPanelAnimator
var minigameLauncherPanelAnimator
var dialoguePanelAnimator
var timePanelOpenTrigger := "TimePanelOpened"
var timePanelCloseTrigger := "TimePanelClosed"
var iconPanelOpenTrigger := "IconPanelOpened"
var iconPanelCloseTrigger := "IconPanelClosed"
var dialoguePanelOpenTrigger := "DialoguePanelOpened"
var dialoguePanelCloseTrigger := "DialoguePanelClosed"
var minigameLauncherPanelOpenTrigger := "MinigameLauncherPanelOpened"
var minigameLauncherPanelCloseTrigger := "MinigameLauncherPanelClosed"
var dialogueCloseFallbackDuration := 0.25
var closeOtherPanelsOnOpen := true
var allowMultiplePanels := false

var IsHudReturning: bool:
	get:
		return _hudRoutine

var IsSleeping: bool:
	get:
		return sleepingPanel != null and sleepingPanel.visible

var IsShowingQuestLocation: bool:
	get:
		return not U.empty(_currentQuestLocation)

var IsInTownSquare: bool:
	get:
		return _lastBgIndex == 0 and not IsShowingQuestLocation

var IsInNightOnlyRoom: bool:
	get:
		return _lastBgIndex == 7 or _lastBgIndex == 42

var IsDayStoryWaiting: bool:
	get:
		return (dayScenarioPending and TimeUI.Instance != null and TimeUI.Instance.GetCurrentDay() >= 2 and HasUnplayedDayScenario()) or (ScenarioManager.Instance != null and ScenarioManager.Instance.IsWaitingAfterRetreat)

var IsSceneDarkened: bool:
	get:
		return _transitionDepth > 0 or (_sceneFade != null and _sceneFade.visible and _sceneFade.color.a > 0.05)

var IsHoldingScene: bool:
	get:
		return _holdFrame != null and _holdFrame.visible

var DayScenarioPending: bool:
	get:
		return dayScenarioPending
	set(v):
		dayScenarioPending = v

var Progress: int:
	get:
		return progress
	set(v):
		if progress == v:
			return
		progress = v
		SyncTimePhaseToScene(v)
		SaveSystem.SaveGame()

func _phase() -> int:
	return TimePhaseManager.Instance.currentPhase if TimePhaseManager.Instance != null else TimePhase.Morning

static func ResolveEntry(e, phase: int):
	if e == null:
		return null
	var s = [e.get("morning"), e.get("noon"), e.get("evening"), e.get("night")][phase] if phase >= 0 and phase < 4 else e.get("morning")
	if s != null:
		return s
	return e.get("morning") if e.get("morning") != null else e.get("night")

static func ResolveCharEntry(e, phase: int):
	if e == null:
		return null
	var s = [e.get("morning"), e.get("noon"), e.get("evening"), e.get("night")][phase] if phase >= 0 and phase < 4 else e.get("morning")
	return s if s != null else e.get("morning")

static func ResolveNamed(q, phase: int):
	if phase == TimePhase.Noon and q.get("noonSprite") != null:
		return q.noonSprite
	if phase == TimePhase.Night and q.get("nightSprite") != null:
		return q.nightSprite
	var dusk := phase == TimePhase.Evening or phase == TimePhase.Night
	return q.eveningSprite if dusk and q.get("eveningSprite") != null else q.get("sprite")

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self
	if itemDatabase != null:
		itemDatabase.SetInstance()
	_mapIconDefaultPos = []
	for loc in mapLocations:
		var ic = loc.get("icon")
		_mapIconDefaultPos.append(ic.anchoredPosition if ic is Control else Vector2.ZERO)
	_itemDefaultY = []
	for wi in worldItems:
		var it = wi.get("item")
		_itemDefaultY.append(it.anchoredPosition.y if wi.get("name") == "HistoryBook" and it is Control else 0.0)

func Start() -> void:
	if DialogueManager.Instance != null:
		DialogueManager.Instance.PanelAnimator = self
	if TimePhaseManager.Instance != null:
		U.on(TimePhaseManager.Instance.OnPhaseChanged, OnPhaseChanged)
	if not SaveSystem.IsLoading:
		SetBackground(0)
		SetCharacter(0)
	currentMapIndex = validMapIndices[0]
	SetupIconButtons()
	HideAllPanels()
	SubscribeDialogue()
	SubscribeHoverEffects()
	SetActive(settingsIconPanel, false)
	SetActive(timePanel, false)
	SetActive(iconPanel, false)
	SetActive(minigameLauncherPanel, false)
	if charImage != null:
		charImage.preserveAspect = true
		U.SetActive(charImage, false)

func Update() -> void:
	if U.GetKeyDown(KEY_M):
		TogglePanel(mapPanel, "Map")
	GuardSceneFade()
	WatchCombatEnd()

func GuardSceneFade() -> void:
	var idle := not _sceneFadeRoutine and not charFadeCoroutine
	if idle and not IsHoldingScene and _transitionDepth == 0 and _sceneFade != null and _sceneFade.visible and _sceneFade.color.a > 0.0:
		RunSceneFade(0.0, SceneDipIn)
	if _transitionDepth > 0:
		if _transitionBusySince < 0.0:
			_transitionBusySince = U.unscaledTime
		elif U.unscaledTime - _transitionBusySince > 6.0:
			_transitionDepth = 0
			if _holdFrame != null:
				U.SetActive(_holdFrame, false)
	else:
		_transitionBusySince = -1.0

func OnEnable() -> void:
	SubscribeDialogue()
	SubscribeHoverEffects()
	if TimePhaseManager.Instance != null:
		U.on(TimePhaseManager.Instance.OnPhaseChanged, OnPhaseChanged)
	if ScenarioManager.Instance != null:
		U.on(ScenarioManager.Instance.OnScenarioStart, OnScenarioStarted)
		U.on(ScenarioManager.Instance.OnScenarioComplete, OnScenarioCompleted)
	if InventoryManager.Instance != null:
		U.on(InventoryManager.Instance.OnItemUsed, HandleItemUsed)

func OnDisable() -> void:
	UnsubscribeDialogue()
	UnsubscribeHoverEffects()
	_hudRoutine = false
	if TimePhaseManager.Instance != null:
		U.off(TimePhaseManager.Instance.OnPhaseChanged, OnPhaseChanged)
	if ScenarioManager.Instance != null:
		U.off(ScenarioManager.Instance.OnScenarioStart, OnScenarioStarted)
		U.off(ScenarioManager.Instance.OnScenarioComplete, OnScenarioCompleted)
	if InventoryManager.Instance != null:
		U.off(InventoryManager.Instance.OnItemUsed, HandleItemUsed)

func _btn(go):
	if go == null:
		return null
	var b = U.GetComponent(go, UButton)
	return b if b != null else U.GetComponentInChildren(go, UButton, true)

func SetupIconButtons() -> void:
	for pair in [[settingsIcon, settingsPanel, "Settings"], [profileIcon, profilePanel, "Profile"], [inventoryIcon, inventoryPanel, "Inventory"], [mapIcon, mapPanel, "Map"], [coinIcon, coinPanel, "Coin"], [questIcon, questPanel, "Quest"], [diversionsIcon, diversionsPanel, "Diversions"], [combatIcon, combatMapPanel, "Combat Map"]]:
		var b = _btn(pair[0])
		if b != null:
			var p = pair[1]
			var n = pair[2]
			b.onClick.AddListener(func(): TogglePanel(p, n))
	for cb in [closeMapButton, closeCombatMapButton]:
		var b2 = _btn(cb)
		if b2 != null:
			b2.onClick.AddListener(HideAllPanels)
	SetActive(combatIcon, false)
	for loc in mapLocations:
		var ic = loc.get("icon")
		SetActive(ic, false)
		if ic != null and not U.empty(loc.get("travelToLocation")):
			var qb = U.GetComponentInChildren(ic, UButton, true)
			if qb != null:
				var target := str(loc.travelToLocation)
				qb.onClick.AddListener(func(): ShowQuestLocation(target))
	for room in roomIcons:
		SetActive(room.get("icon"), false)

func InitializeGame() -> void:
	if PlayerStats.Instance != null:
		PlayerStats.Instance.FullRestore()
	TryStartDialogue(0)
	InitializeGameContinue()

func InitializeGameContinue() -> void:
	for inst in [ProfileUI.Instance, InventoryUI.Instance, EquipmentUI.Instance, MarketUI.Instance, CurrencyUI.Instance]:
		if inst != null and is_instance_valid(inst):
			inst.OnGameStarted()

func OpenPanel(panel, n: String) -> void:
	if IsInDialogue() or panel == null:
		return
	if closeOtherPanelsOnOpen and not allowMultiplePanels:
		HideAllPanels()
	UIPanelAnimator.Show(panel)

func _refresh_profile() -> void:
	if ProfileUI.Instance != null:
		ProfileUI.Instance.RefreshAll()

func OpenSettings() -> void:
	OpenPanel(settingsPanel, "Settings")
	_refresh_profile()

func OpenProfile() -> void:
	OpenPanel(profilePanel, "Profile")
	_refresh_profile()

func OpenInventory() -> void:
	OpenPanel(inventoryPanel, "Inventory")
	_refresh_profile()

func OpenShop() -> void:
	if MarketUI.Instance != null:
		HideAllPanels()
		MarketUI.Instance.OpenShop()
	else:
		OpenPanel(shopPanel, "Shop")
	_refresh_profile()

func OpenMap() -> void:
	OpenPanel(mapPanel, "Map")
	_refresh_profile()

func OpenEquipment() -> void:
	OpenPanel(equipmentPanel, "Equipment")
	_refresh_profile()

func OpenCoin() -> void:
	OpenPanel(coinPanel, "Coin")
	_refresh_profile()

func OpenQuest() -> void:
	OpenPanel(questPanel, "Quest")
	if QuestUI.Instance != null:
		U.SetActive(QuestUI.Instance.questLogPanel, true)
	_refresh_profile()

func OpenSave() -> void:
	OpenPanel(savePanel, "Save")
	_refresh_profile()

func OpenCombatMap() -> void:
	OpenPanel(combatMapPanel, "Combat Map")
	_refresh_profile()

func ClosePanel(panel) -> void:
	UIPanelAnimator.Hide(panel)

func HideAllPanels() -> void:
	for p in [settingsPanel, savePanel, profilePanel, inventoryPanel, mapPanel, equipmentPanel, coinPanel, questPanel, combatMapPanel, diversionsPanel]:
		UIPanelAnimator.Hide(p)
	if MarketUI.Instance != null:
		MarketUI.Instance.CloseAll()
	else:
		UIPanelAnimator.Hide(shopPanel)
	if GuideUI.Instance != null:
		GuideUI.Instance.Close()

func TogglePanel(panel, n: String) -> void:
	if IsInDialogue() or panel == null:
		return
	var active: bool = panel.visible
	if closeOtherPanelsOnOpen and not allowMultiplePanels and not active:
		HideAllPanels()
	if active:
		UIPanelAnimator.Hide(panel)
	else:
		UIPanelAnimator.Show(panel)
	if not active and panel == mapPanel:
		SetMap(currentMapIndex)
	if QuestUI.Instance != null and not active and panel == questPanel:
		U.SetActive(QuestUI.Instance.questLogPanel, true)
		QuestUI.Instance.RefreshQuestLog()

func ToggleInventoryInCombat() -> void:
	if inventoryPanel == null:
		return
	if inventoryPanel.visible:
		UIPanelAnimator.Hide(inventoryPanel)
	else:
		UIPanelAnimator.Show(inventoryPanel)

func SetCharacter(index: int) -> void:
	_lastCharIndex = index
	if charImage == null:
		return
	charImage.preserveAspect = true
	if index >= 0 and index < characters.size():
		var s = ResolveCharEntry(characters[index], _phase())
		if s != null:
			charImage.sprite = s
			FitCharacterWidth()
			_sceneCharacterActive = true
			_charImageFromDialogue = false
			if DialogueManager.Instance != null and DialogueManager.Instance.IsInDialogue():
				U.SetActive(charImage, true)

func _set_char_rt(amin: Vector2, amax: Vector2, piv: Vector2, ap: Vector2, sd: Vector2, sc: float) -> void:
	charImage.anchorMin = amin
	charImage.anchorMax = amax
	charImage.pivot = piv
	charImage.sizeDelta = sd
	charImage.anchoredPosition = ap
	charImage.localScale = Vector3(sc, sc, sc)

func SetBackground(index: int) -> void:
	_lastBgIndex = index
	_currentQuestLocation = null
	if backgroundImage != null and index >= 0 and index < backgrounds.size():
		backgroundImage.sprite = ResolveBg(index)
	ClearDialogueBackground()
	SetActive(townNpc, index == 0)
	if index == 0 and not SaveSystem.IsLoading and ScenarioManager.Instance != null and ScenarioManager.Instance.IsWaitingAfterRetreat:
		ScenarioManager.Instance.ResumeAfterRetreat()
	elif index == 0:
		TryStartDayScenario()
	OnBackgroundChanged.emit(index)
	if TimePhaseManager.Instance != null:
		TimePhaseManager.Instance.UpdatePhaseButtons()
	ApplyHoverVisibility(index)
	ApplyItemVisibility(index)
	ApplyHouseIconVisibility(IsHouseBackground(index))
	var show_char := index >= 8 and index <= 12
	if index == 11 and (IsNight() or IsEvening()):
		show_char = false
	_sceneCharacterActive = show_char
	if not DialogueManager.Instance.IsInDialogue():
		SetActive(charImage, show_char)
	if show_char:
		if index == 9:
			_set_char_rt(Vector2(1, 0), Vector2(1, 0), Vector2(0.5, 0.5), Vector2(-260, 450), Vector2(700, 1200), 0.75)
			SetCharacter(24)
		elif index == 11:
			_set_char_rt(Vector2(0.5, 0), Vector2(0.5, 0), Vector2(0.5, 0.5), Vector2(375, 375), Vector2(75, 75), 10.0)
			SetCharacter(27)
		else:
			_set_char_rt(Vector2(0.5, 0), Vector2(0.5, 0), Vector2(0.5, 0.5), Vector2(0, 375), Vector2(75, 75), 10.0)
			if index == 8:
				SetCharacter(22)
			elif index == 10:
				SetCharacter(26)
			elif index == 12:
				SetCharacter(29)

func PhaseVariantOf(sprite):
	if sprite == null:
		return null
	var ph := _phase()
	for q in questLocationBackgrounds:
		if sprite == q.get("sprite") or sprite == q.get("noonSprite") or sprite == q.get("eveningSprite") or sprite == q.get("nightSprite"):
			var r = ResolveNamed(q, ph)
			return r if r != null else sprite
	return sprite

func ResolveBg(index: int):
	if index < 0 or index >= backgrounds.size():
		return null
	return ResolveEntry(backgrounds[index], _phase())

func ClearDialogueBackground() -> void:
	var dm = DialogueManager.Instance
	if dm == null or dm.backgroundImage == null or dm.IsInDialogue() or _charFadingOut:
		return
	dm.backgroundImage.enabled = false
	dm.backgroundImage.sprite = null
	_dialogueBgCurrent = null
	_dialogueBgPending = null
	if backgroundImage != null and backgroundImage.color != Color.WHITE:
		backgroundImage.color = Color.WHITE

func SetMap(index: int) -> void:
	if mapImage == null:
		return
	var r := ResolveMapIndex(index)
	if r < 0 or r >= maps.size() or maps[r] == null:
		return
	mapImage.sprite = maps[r]
	var modern := r == 8 or r == 9 or r == 10
	var fantasy := r == 6 or r == 7 or r == 11
	var combat := r == 13 or r == 19 or r == 20
	var group := MapGroup.Modern if modern else (MapGroup.Fantasy if fantasy else (MapGroup.Combat if combat else -1))
	ApplyMapIcons(group)
	SetActive(combatIcon, combat)
	if mapTitleText != null:
		if modern:
			mapTitleText.text = Loc.T("Neighborhood", "Mahalle")
		elif fantasy:
			mapTitleText.text = Loc.T("Ashenveil Town", "Ashenveil Kasabası")
		elif combat:
			mapTitleText.text = Loc.T("Combat Region", "Savaş Bölgesi")

func SetCombatMap(index: int) -> void:
	if combatMapImage == null or index < 0 or index >= maps.size() or maps[index] == null:
		return
	combatMapImage.sprite = maps[index]

func ApplyMapIcons(group: int) -> void:
	for i in mapLocations.size():
		var loc = mapLocations[i]
		var ic = loc.get("icon")
		if ic == null:
			continue
		var visible := group >= 0 and int(loc.get("group", 0)) == group
		if not U.empty(loc.get("questID")):
			visible = visible and IsQuestIconActive(loc) and (not IsNight() or not IsCurrentDayContentComplete())
		SetActive(ic, visible)
		if not visible:
			continue
		var inter := PhaseMatches(int(loc.get("interactablePhase", 0)))
		SetInteractable(ic, inter)
		var off = loc.get("interactableOffset")
		if off is Vector2 and off != Vector2.ZERO and i < _mapIconDefaultPos.size():
			ic.anchoredPosition = _mapIconDefaultPos[i] + (off if inter else Vector2.ZERO)

func ResolveMapIndex(index: int) -> int:
	var ph := _phase()
	if index == 8 or index == 9 or index == 10:
		return [9, 8, 8, 10][ph]
	if index == 6 or index == 7 or index == 11:
		return [6, 7, 7, 11][ph]
	if index == 13 or index == 19 or index == 20:
		return [13, 19, 19, 20][ph]
	return index

func NextMap() -> void:
	_validMapCursor = (_validMapCursor + 1) % validMapIndices.size()
	currentMapIndex = validMapIndices[_validMapCursor]
	SetMap(currentMapIndex)

func PreviousMap() -> void:
	_validMapCursor = (_validMapCursor - 1 + validMapIndices.size()) % validMapIndices.size()
	currentMapIndex = validMapIndices[_validMapCursor]
	SetMap(currentMapIndex)

func SubscribeDialogue() -> void:
	var dm = DialogueManager.Instance
	if isDialogueSubscribed or dm == null:
		return
	U.on(dm.OnDialogueStart, HandleDialogueStart)
	U.on(dm.OnDialogueEnd, HandleDialogueEnd)
	U.on(dm.OnLineShown, HandleLineShown)
	U.on(dm.OnNodeAdvanced, HandleNodeAdvanced)
	isDialogueSubscribed = true

func UnsubscribeDialogue() -> void:
	var dm = DialogueManager.Instance
	if not isDialogueSubscribed or dm == null:
		return
	U.off(dm.OnDialogueStart, HandleDialogueStart)
	U.off(dm.OnDialogueEnd, HandleDialogueEnd)
	U.off(dm.OnLineShown, HandleLineShown)
	U.off(dm.OnNodeAdvanced, HandleNodeAdvanced)
	isDialogueSubscribed = false

func TryStartDialogue(i: int) -> void:
	if DialogueManager.Instance == null or i >= sceneStartDialogueNodes.size():
		return
	var n = sceneStartDialogueNodes[i]
	if n != null:
		DialogueManager.Instance.StartDialogue(n)

func StartDialogueAfterLoad(i: int) -> void:
	await U.frame()
	var free_roam := Progress == SceneProgress.SceneHome or Progress == SceneProgress.SceneMarket or Progress == SceneProgress.SceneGym or Progress == SceneProgress.SceneOffice or Progress == SceneProgress.SceneChurch
	var node = sceneStartDialogueNodes[i] if i >= 0 and i < sceneStartDialogueNodes.size() else null
	var day: int = TimeUI.Instance.GetCurrentDay() if TimeUI.Instance != null else 1
	var past_day1: bool = day > 1 or (ScenarioManager.Instance != null and ScenarioManager.Instance.GetCompletedScenarios().size() > 0)
	if free_roam or past_day1 or node == null or DialogueManager.Instance == null:
		if past_day1 and not free_roam:
			Progress = SceneProgress.Scene1
			SetBackground(0)
		ShowHudPanels()
		return
	DialogueManager.Instance.StartDialogue(node)

func _stop_char() -> void:
	_char_gen += 1
	charFadeCoroutine = false

func _start_char() -> int:
	_char_gen += 1
	charFadeCoroutine = true
	return _char_gen

func _end_char(g: int) -> void:
	if g == _char_gen:
		charFadeCoroutine = false

func HandleDialogueStart(node) -> void:
	if node != null and node.backgroundImage != null:
		SetActive(townNpc, false)
	_anim(timePanelAnimator, timePanelOpenTrigger, timePanelCloseTrigger)
	_anim(iconPanelAnimator, iconPanelOpenTrigger, iconPanelCloseTrigger)
	_anim(minigameLauncherPanelAnimator, minigameLauncherPanelOpenTrigger, minigameLauncherPanelCloseTrigger)
	SetActive(settingsIconPanel, false)
	HideAllPanels()
	SetActive(houseIconsPanel, false)
	var finale: bool = node != null and node.name.begins_with("Finale_")
	var dm = DialogueManager.Instance
	if dm != null and dm.backgroundImage != null:
		dm.backgroundImage.preserveAspect = finale
	if backgroundImage != null:
		if finale:
			backgroundImage.enabled = true
			backgroundImage.color = Color.BLACK
		elif backgroundImage.color != Color.WHITE:
			backgroundImage.color = Color.WHITE
	if finale:
		_stop_char()
		_charFadingOut = false
		_sceneCharacterActive = false
		if charImage != null:
			U.SetActive(charImage, false)
		return
	if charImage == null:
		return
	_stop_char()
	var was_fading := _charFadingOut
	_charFadingOut = false
	if charImage.visible and not was_fading:
		_set_char_alpha(1.0)
	if node != null and node.characterImage != null:
		_dialogueBgPending = PhaseVariantOf(node.backgroundImage)
		ShowCharacterFaded(node.characterImage)
	elif _sceneCharacterActive:
		if _lastBgIndex >= 0 and _lastBgIndex <= 7:
			ApplySceneCharacterLayout()
		charImage.preserveAspect = true
		var already: bool = charImage.visible and charImage.color.a > 0.99
		U.SetActive(charImage, true)
		if already:
			_set_char_alpha(1.0)
		else:
			FadeInCurrentCharacter(_start_char())
	elif charImage.visible and charImage.color.a > 0.05:
		FadeOutSpeaker(0.3, _start_char())
	else:
		U.SetActive(charImage, false)

func _anim(a, open_t: String, close_t: String) -> void:
	if a != null:
		a.ResetTrigger(open_t)
		a.SetTrigger(close_t)

func _set_char_alpha(a: float) -> void:
	var c: Color = charImage.color
	c.a = a
	charImage.color = c

func HandleNodeAdvanced(node) -> void:
	if charImage == null or node == null or node.characterImage == null:
		return
	_dialogueBgPending = PhaseVariantOf(node.backgroundImage)
	ShowCharacterFaded(node.characterImage)

func ShowCharacterFaded(sprite) -> void:
	if charImage == null or sprite == null:
		return
	var visible: bool = charImage.visible and charImage.color.a > 0.05
	var defer_bg: bool = visible and charImage.sprite != sprite and _dialogueBgPending != null and _dialogueBgCurrent != null and _dialogueBgPending != _dialogueBgCurrent
	if charImage.sprite == sprite:
		_stop_char()
		_charFadingOut = false
		var bg_changed: bool = _dialogueBgPending != null and _dialogueBgPending != _dialogueBgCurrent
		if bg_changed and visible and not _same_layout(DialogueCharacterLayout(_dialogueBgPending, sprite), DialogueCharacterLayout(_dialogueBgCurrent, sprite)):
			SwapCharacter(sprite, _start_char())
			return
		U.SetActive(charImage, true)
		_set_char_alpha(1.0)
		ApplyDialogueCharacterLayout()
		if bg_changed and visible:
			SwapBackgroundOnly(_dialogueBgPending, _start_char())
		elif _dialogueBgPending != null:
			_dialogueBgCurrent = _dialogueBgPending
			var dm = DialogueManager.Instance
			if dm != null and dm.backgroundImage != null:
				dm.backgroundImage.sprite = _dialogueBgPending
				dm.backgroundImage.enabled = true
		return
	_stop_char()
	if visible and charImage.sprite != sprite:
		var dm2 = DialogueManager.Instance
		if defer_bg and dm2 != null and dm2.backgroundImage != null:
			dm2.backgroundImage.sprite = _dialogueBgCurrent
		SwapCharacter(sprite, _start_char())
	elif IsHoldingScene:
		if _dialogueBgPending != null:
			SetBackdrop(_dialogueBgPending)
		charImage.sprite = sprite
		ApplyDialogueCharacterLayout()
		_set_char_alpha(0.0)
		U.SetActive(charImage, true)
		FadeCharacterInAfterHold(_start_char())
	elif _dialogueBgPending != null and _dialogueBgPending != VisibleBackdrop():
		DipToScene(_dialogueBgPending, sprite, _start_char())
	else:
		if _dialogueBgPending != null:
			SetBackdrop(_dialogueBgPending)
		FadeInCharacter(sprite, _start_char())

func _same_layout(a: Array, b: Array) -> bool:
	return a[0] == b[0] and a[1] == b[1]

func _fade_char(from: float, to: float, dur: float, g: int) -> bool:
	var t := 0.0
	while t < dur:
		if g != _char_gen:
			return false
		_set_char_alpha(lerpf(from, to, clampf(t / dur, 0.0, 1.0)))
		await U.frame()
		t += U.deltaTime
	if g != _char_gen:
		return false
	_set_char_alpha(to)
	return true

func SwapBackgroundOnly(bg, g: int) -> void:
	await RunSceneFade(1.0, SceneDipOut)
	if g != _char_gen:
		return
	if bg != null:
		SetBackdrop(bg)
	await RunSceneFade(0.0, SceneDipIn)
	_end_char(g)

func SwapCharacter(sprite, g: int) -> void:
	_charImageFromDialogue = true
	_sceneCharacterActive = false
	_charFadingOut = true
	var start_a: float = charImage.color.a
	if not await _fade_char(start_a, 0.0, 0.3, g):
		return
	_charFadingOut = false
	U.SetActive(charImage, false)
	var place_changes: bool = _dialogueBgPending != null and _dialogueBgPending != VisibleBackdrop()
	if place_changes:
		await RunSceneFade(1.0, SceneDipOut)
	else:
		await U.wait_rt(0.2)
	if g != _char_gen:
		return
	if _dialogueBgPending != null:
		SetBackdrop(_dialogueBgPending)
	charImage.sprite = sprite
	ApplyDialogueCharacterLayout()
	U.SetActive(charImage, true)
	_set_char_alpha(0.0)
	if place_changes:
		await RunSceneFade(0.0, SceneDipIn)
		if g != _char_gen:
			return
	if not await _fade_char(0.0, 1.0, 0.28, g):
		return
	_end_char(g)

func FadeInCharacter(sprite, g: int) -> void:
	_charFadingOut = false
	_charImageFromDialogue = true
	_sceneCharacterActive = false
	U.SetActive(charImage, true)
	charImage.sprite = sprite
	ApplyDialogueCharacterLayout()
	_set_char_alpha(0.0)
	if await _fade_char(0.0, 1.0, 0.28, g):
		_end_char(g)

func FadeInCurrentCharacter(g: int) -> void:
	_charFadingOut = false
	if await _fade_char(0.0, 1.0, 0.28, g):
		_end_char(g)

func FadeOutCharacter(dur: float, ended_node, g: int) -> void:
	if charImage == null:
		return
	_charFadingOut = true
	var start_a: float = charImage.color.a
	if not await _fade_char(start_a, 0.0, dur, g):
		return
	U.SetActive(charImage, false)
	_set_char_alpha(1.0)
	_end_char(g)
	await U.wait_rt(0.2)
	_charFadingOut = false
	if ended_node != null:
		var change := func() -> void:
			HandleSceneTransition(ended_node)
			ClearDialogueBackground()
		TransitionScene(change)
	elif CombatManager.Instance == null or not CombatManager.Instance.inCombat:
		ShowHudPanels()

func ApplyDialogueCharacterLayout() -> void:
	if charImage == null:
		return
	charImage.preserveAspect = true
	charImage.anchorMin = Vector2(0.5, 0)
	charImage.anchorMax = Vector2(0.5, 0)
	charImage.pivot = Vector2(0.5, 0)
	charImage.localScale = Vector3.ONE
	var dm = DialogueManager.Instance
	var bg = _dialogueBgPending if _dialogueBgPending != null else (dm.backgroundImage.sprite if dm != null and dm.backgroundImage != null else null)
	var lay := DialogueCharacterLayout(bg, charImage.sprite)
	charImage.sizeDelta = lay[1]
	charImage.anchoredPosition = lay[0]
	FitCharacterWidth()

func FitCharacterWidth() -> void:
	if charImage == null or charImage.sprite == null:
		return
	var r: Rect2 = charImage.sprite.get_region()
	var sd: Vector2 = charImage.sizeDelta
	if r.size.y <= 0:
		return
	var w := sd.y * r.size.x / r.size.y
	if w > sd.x:
		charImage.sizeDelta = Vector2(w, sd.y)

func DialogueCharacterLayout(bg, character) -> Array:
	if bg != null and not (character != null and HalfBodyCharacterSprites.has(character.name)):
		for o in DialogueCharacterLayoutOverrides:
			if o[0] == bg.name:
				return [o[1], o[2]]
	return [dialogueCharacterPosition, dialogueCharacterSize]

func ApplySceneCharacterLayout() -> void:
	if charImage == null:
		return
	charImage.preserveAspect = true
	_set_char_rt(Vector2(0.5, 0), Vector2(0.5, 0), Vector2(0.5, 0.5), Vector2(0, 375), Vector2(75, 75), 10.0)
	FitCharacterWidth()

func IsInDialogue() -> bool:
	return DialogueManager.Instance != null and DialogueManager.Instance.IsInDialogue()

static func IsHouseBackground(i: int) -> bool:
	return i in [11, 13, 14, 15, 16, 17, 20, 38, 39, 40]

func ApplyHouseIconVisibility(is_house: bool) -> void:
	SetActive(houseIconsPanel, is_house)
	for room in roomIcons:
		SetActive(room.get("icon"), is_house)

func ShowHudPanels() -> void:
	if not _active:
		ShowHudPanelsNow()
		return
	if _hudRoutine:
		return
	_hudRoutine = true
	ShowHudWhenSettled()

func ShowHudWhenSettled() -> void:
	var dm = DialogueManager.Instance
	var busy := 0.0
	var quiet := 0.0
	while quiet < HudRevealDelay:
		if not _hudRoutine:
			return
		if CombatOpen() or (dm != null and dm.IsInDialogue()):
			busy = 0.0
			quiet = 0.0
		elif dm != null and (dm.IsConversationBusy() or dm.IsSceneTransitionBusy()) and busy < 3.0:
			busy += U.unscaledDeltaTime
			quiet = 0.0
		else:
			quiet += U.unscaledDeltaTime
		await U.frame()
	if not _hudRoutine:
		return
	_hudRoutine = false
	ShowHudPanelsNow()

static func CombatOpen() -> bool:
	return (CombatManager.Instance != null and CombatManager.Instance.inCombat) or (CombatUI.Instance != null and CombatUI.Instance.combatPanel != null and CombatUI.Instance.combatPanel.visible)

func WatchCombatEnd() -> void:
	var inc := CombatOpen()
	if _wasInCombat and not inc:
		ShowHudPanels()
	_wasInCombat = inc

func ShowHudPanelsNow() -> void:
	SetActive(settingsIconPanel, true)
	SetActive(timePanel, true)
	SetActive(iconPanel, true)
	SetActive(minigameLauncherPanel, true)
	_anim(timePanelAnimator, timePanelCloseTrigger, timePanelOpenTrigger)
	_anim(iconPanelAnimator, iconPanelCloseTrigger, iconPanelOpenTrigger)
	_anim(minigameLauncherPanelAnimator, minigameLauncherPanelCloseTrigger, minigameLauncherPanelOpenTrigger)
	ApplyHouseIconVisibility(IsHouseBackground(_lastBgIndex))
	if not _charFadingOut and U.empty(_currentQuestLocation):
		ClearDialogueBackground()

func HandleDialogueEnd(ended) -> void:
	var scen_active: bool = ScenarioManager.Instance != null and ScenarioManager.Instance.IsScenarioActive()
	var is_final: bool = not scen_active and ended != null and bool(ended.isFinalNode)
	if charImage != null and charImage.visible:
		_stop_char()
		if not is_final and NextDialogueKeepsSpeaker():
			_keepingSpeaker = true
			KeepSpeakerForNextDialogue()
			return
		DeferredFadeOut(0.5, ended if is_final else null, _start_char())
	elif is_final:
		TransitionScene(func(): HandleSceneTransition(ended))
	elif CombatManager.Instance == null or not CombatManager.Instance.inCombat:
		ShowHudPanels()
	if not is_final:
		return
	ShowHudPanels()
	if Progress == SceneProgress.SceneMarket and sceneStartDialogueNodes.size() > 9 and sceneStartDialogueNodes[9] != null and ended == sceneStartDialogueNodes[9] and MarketUI.Instance != null:
		MarketUI.Instance.OpenMarket()

func NextDialogueKeepsSpeaker() -> bool:
	var sm = ScenarioManager.Instance
	var dm = DialogueManager.Instance
	if sm == null or dm == null or charImage == null or charImage.sprite == null or charImage.color.a < 0.5 or _charFadingOut:
		return false
	var nx = sm.PeekFollowUpDialogue(dm.LastStartNode)
	if nx == null or nx.characterImage == null or nx.characterImage != charImage.sprite:
		return false
	return nx.backgroundImage == null or PhaseVariantOf(nx.backgroundImage) == VisibleBackdrop()

func KeepSpeakerForNextDialogue() -> void:
	var dm = DialogueManager.Instance
	var t := 0.0
	while t < 2.0:
		if dm == null or dm.IsInDialogue():
			_keepingSpeaker = false
			return
		await U.frame()
		t += U.unscaledDeltaTime
	_keepingSpeaker = false
	if charImage != null and charImage.visible:
		DeferredFadeOut(0.5, null, _start_char())
	else:
		ShowHudPanels()

func DeferredFadeOut(dur: float, ended, g: int) -> void:
	_charFadingOut = true
	await U.wait_rt(0.12)
	if g != _char_gen:
		return
	await FadeOutCharacter(dur, ended, g)

func OnScenarioStarted(s) -> void:
	var first = null
	if s != null:
		if s.introDialogue != null:
			first = s.introDialogue
		elif s.steps != null and s.steps.size() > 0 and int(s.steps[0].type) == ScenarioStepType.Dialogue:
			first = s.steps[0].dialogue
	if charImage != null and charImage.visible and charImage.color.a > 0.05 and not _charFadingOut and first != null and first.characterImage != null and first.characterImage == charImage.sprite:
		return
	if charImage != null and charImage.visible and charImage.color.a > 0.05:
		_sceneCharacterActive = false
		_charImageFromDialogue = false
		if not _charFadingOut:
			_stop_char()
			FadeOutSpeaker(0.3, _start_char())
		return
	ForceHideSceneCharacter()

func OnScenarioCompleted(_s) -> void:
	TryStartDayScenarioAfterScenario()
	if charImage == null:
		return
	_sceneCharacterActive = false
	if charFadeCoroutine and _charFadingOut:
		return
	if charImage.visible and charImage.color.a > 0.01:
		DeferredFadeOut(0.5, null, _start_char())
	else:
		U.SetActive(charImage, false)
		ShowHudPanels()

func TryStartDayScenarioAfterScenario() -> void:
	await U.frame()
	while DialogueManager.Instance != null and DialogueManager.Instance.IsInDialogue():
		await U.frame()
	if _lastBgIndex == 0 and U.empty(_currentQuestLocation):
		TryStartDayScenario()

func HasUnplayedDayScenario() -> bool:
	var sm = ScenarioManager.Instance
	if sm == null:
		return false
	for s in sm.availableScenarios:
		if s != null and str(s.scenarioID).begins_with("ashenveil_day") and not sm.IsScenarioCompleted(s.scenarioID):
			return true
	return false

func ForceHideSceneCharacter() -> void:
	_stop_char()
	_charFadingOut = false
	_sceneCharacterActive = false
	_charImageFromDialogue = false
	if charImage == null:
		return
	_set_char_alpha(1.0)
	U.SetActive(charImage, false)

static func IsReachableFrom(root, node, depth: int) -> bool:
	if root == null or node == null or depth <= 0 or root.choices == null:
		return false
	for c in root.choices:
		var nx = c.get("nextNode") if c != null else null
		if nx != null and (nx == node or IsReachableFrom(nx, node, depth - 1)):
			return true
	return false

func HandleSceneTransition(ended) -> void:
	match int(ended.sceneContext):
		SceneProgress.Scene2:
			TriggerScene3()
		SceneProgress.Scene3:
			TriggerScene4()
		SceneProgress.Scene4:
			StartCombatForScene4()
		SceneProgress.Scene5:
			if ended == sceneStartDialogueNodes[4] or IsReachableFrom(sceneStartDialogueNodes[4], ended, 3):
				TriggerScene6()
		SceneProgress.Scene6:
			TriggerScene7()
		SceneProgress.Scene7:
			TriggerScene8()
		SceneProgress.Scene8:
			TriggerScene9()

func HandleLineShown(node, i: int) -> void:
	if node == sceneStartDialogueNodes[0] and i == 1:
		SetCharacter(8)
	if node == sceneStartDialogueNodes[3] and i == 0:
		SetCharacter(14)
	if node == scene9SecondNode and i == 0:
		SetCharacter(20)
		SetBackground(42)
		if charImage != null:
			charRtAnchoredTransform = charImage.anchoredPosition
			charRtSizeDelta = charImage.sizeDelta
			charImage.anchoredPosition = Vector2(0, 500)
			charImage.sizeDelta = Vector2(100, 100)
	if node == scene9FifthNode and i == 0:
		SetCharacter(38)

func OpenDialoguePanel() -> void:
	if dialoguePanelAnimator != null:
		dialoguePanelAnimator.ResetTrigger(dialoguePanelCloseTrigger)
		dialoguePanelAnimator.SetTrigger(dialoguePanelOpenTrigger)

func CloseDialoguePanel() -> void:
	if dialoguePanelAnimator == null or not U.activeInHierarchy(dialoguePanelAnimator.gameObject):
		return
	dialoguePanelAnimator.ResetTrigger(dialoguePanelOpenTrigger)
	dialoguePanelAnimator.SetTrigger(dialoguePanelCloseTrigger)
	dialoguePanelAnimator.Play("DialoguePanelClose", 0, 0.0)
	dialoguePanelAnimator.Update(0.0)

func DialogueOpenAnimationDuration() -> float:
	return 0.0

func IsSceneTransitionActive() -> bool:
	return charFadeCoroutine or _transitionDepth > 0

func _root_canvas(n: Node) -> Control:
	var c: Node = n
	while c != null and not (c.get_parent() is CanvasLayer) and c.get_parent() != null and c.get_parent() is Control:
		c = c.get_parent()
	return c as Control

func SceneFade():
	if _sceneFade == null or not is_instance_valid(_sceneFade):
		var root := _root_canvas(charImage if charImage != null else gameObject)
		var img := UImage.new()
		img.name = "SceneFade"
		img.set_meta("u", "{\"name\":\"SceneFade\",\"image\":{\"color\":[0,0,0,0],\"raycastTarget\":false}}")
		img.set_meta("pivot", [0.5, 0.5])
		root.add_child(img)
		img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		img.visible = false
		_sceneFade = img
	_sceneFade.get_parent().move_child(_sceneFade, -1)
	return _sceneFade

func FadeSceneTo(target: float, dur: float, g: int) -> void:
	var img = SceneFade()
	img.visible = true
	var from: float = img.color.a
	var t := 0.0
	while t < dur:
		if g != _fade_gen:
			return
		img.color = Color(0, 0, 0, lerpf(from, target, clampf(t / dur, 0.0, 1.0)))
		await U.frame()
		t += U.unscaledDeltaTime
	if g != _fade_gen:
		return
	img.color = Color(0, 0, 0, target)
	if target <= 0.0:
		img.visible = false

func RunSceneFade(target: float, dur: float) -> void:
	_fade_gen += 1
	var g := _fade_gen
	_sceneFadeRoutine = true
	await FadeSceneTo(target, dur, g)
	if g == _fade_gen:
		_sceneFadeRoutine = false

func ShownBackdrop():
	var dm = DialogueManager.Instance
	var img = dm.backgroundImage if dm != null else null
	return img.sprite if img != null and img.enabled else null

func VisibleBackdrop():
	var s = ShownBackdrop()
	if s != null:
		return s
	return backgroundImage.sprite if backgroundImage != null and backgroundImage.enabled else null

func SetBackdrop(sprite) -> void:
	var dm = DialogueManager.Instance
	var img = dm.backgroundImage if dm != null else null
	if img == null:
		return
	img.sprite = sprite
	img.enabled = sprite != null
	_dialogueBgCurrent = sprite

func ShowDialogueBackdrop(sprite) -> void:
	var dm = DialogueManager.Instance
	if dm == null or dm.backgroundImage == null:
		return
	_dialogueBgPending = sprite
	if sprite == ShownBackdrop() or sprite == VisibleBackdrop() or IsHoldingScene:
		SetBackdrop(sprite)
		return
	BackdropAfterTransition(sprite)

func BackdropAfterTransition(sprite) -> void:
	_transitionDepth += 1
	while charFadeCoroutine or _sceneFadeRoutine:
		await U.frame()
	if _dialogueBgPending == sprite and sprite != ShownBackdrop():
		if sprite != VisibleBackdrop():
			await RunSceneFade(1.0, SceneDipOut)
			SetBackdrop(sprite)
			await RunSceneFade(0.0, SceneDipIn)
		else:
			SetBackdrop(sprite)
	_transitionDepth = maxi(0, _transitionDepth - 1)

func FadeOutSpeaker(dur: float, g: int) -> void:
	_charFadingOut = true
	var from: float = charImage.color.a
	if not await _fade_char(from, 0.0, dur, g):
		return
	U.SetActive(charImage, false)
	_set_char_alpha(1.0)
	_charFadingOut = false
	_end_char(g)

func FadeCharacterInAfterHold(g: int) -> void:
	while IsHoldingScene or _sceneFadeRoutine:
		await U.frame()
		if g != _char_gen:
			return
	_charImageFromDialogue = true
	_sceneCharacterActive = false
	U.SetActive(charImage, true)
	if await _fade_char(0.0, 1.0, 0.28, g):
		_end_char(g)

func DipToScene(backdrop, character, g: int) -> void:
	await RunSceneFade(1.0, SceneDipOut)
	if g != _char_gen:
		return
	SetBackdrop(backdrop)
	if character != null and charImage != null:
		charImage.sprite = character
		ApplyDialogueCharacterLayout()
		_set_char_alpha(0.0)
		U.SetActive(charImage, true)
	await RunSceneFade(0.0, SceneDipIn)
	if g != _char_gen:
		return
	if character != null and charImage != null:
		_charImageFromDialogue = true
		_sceneCharacterActive = false
		if not await _fade_char(0.0, 1.0, 0.28, g):
			return
	_end_char(g)

func BeginSceneHold() -> void:
	var shown = ShownBackdrop()
	if shown == null or DialogueManager.Instance == null or IsHoldingScene:
		return
	var src = DialogueManager.Instance.backgroundImage
	if _holdFrame == null or not is_instance_valid(_holdFrame):
		var img := UImage.new()
		img.name = "SceneHold"
		img.set_meta("u", "{\"name\":\"SceneHold\",\"image\":{\"color\":[1,1,1,1],\"raycastTarget\":false}}")
		img.set_meta("pivot", [0.5, 0.5])
		_root_canvas(src).add_child(img)
		_holdFrame = img
	_holdFrame.anchor_left = src.anchor_left
	_holdFrame.anchor_right = src.anchor_right
	_holdFrame.anchor_top = src.anchor_top
	_holdFrame.anchor_bottom = src.anchor_bottom
	_holdFrame.global_position = src.global_position
	_holdFrame.size = src.size
	_holdFrame.scale = src.scale
	_holdFrame.sprite = shown
	_holdFrame.preserveAspect = src.preserveAspect
	_holdFrame.color = src.color
	_holdFrame.visible = true
	_holdFrame.get_parent().move_child(_holdFrame, -1)
	_holdSprite = shown
	_transitionDepth += 1

func EndSceneHold() -> void:
	if _holdFrame == null or not _holdFrame.visible:
		return
	var now = ShownBackdrop()
	if now == null and backgroundImage != null:
		now = backgroundImage.sprite
	if now == _holdSprite:
		_holdFrame.visible = false
		_transitionDepth = maxi(0, _transitionDepth - 1)
		return
	DipOutOfHold()

func DipOutOfHold() -> void:
	await RunSceneFade(1.0, SceneDipOut)
	_holdFrame.visible = false
	await RunSceneFade(0.0, SceneDipIn)
	_transitionDepth = maxi(0, _transitionDepth - 1)

func TransitionScene(change) -> void:
	if _keepingSpeaker:
		if change is Callable:
			change.call()
		return
	BeginSceneHold()
	if change is Callable:
		change.call()
	await U.frame()
	EndSceneHold()

func DialogueCloseAnimationDuration() -> float:
	var l := dialogueCloseFallbackDuration
	if dialoguePanelAnimator != null:
		var info: Dictionary = dialoguePanelAnimator.GetCurrentAnimatorStateInfo(0)
		if float(info.length) > 0.0:
			l = float(info.length)
	return maxf(l, 0.4)

func ApplySceneProgress(target: int) -> void:
	progress = target
	match progress:
		SceneProgress.Scene1:
			SetBackground(0)
			SetCharacter(0)
		SceneProgress.Scene2:
			SetBackground(1)
			SetCharacter(8)
		SceneProgress.Scene3:
			SetBackground(2)
			SetCharacter(8)
		SceneProgress.Scene4:
			SetBackground(3)
			SetCharacter(14)
		SceneProgress.Scene5:
			SetBackground(3)
			SetCharacter(8)
		SceneProgress.Scene6:
			SetBackground(4)
			SetCharacter(8)
		SceneProgress.Scene7:
			SetBackground(5)
			SetCharacter(8)
		SceneProgress.Scene8:
			SetBackground(6)
			SetCharacter(8)
		SceneProgress.Scene9:
			SetBackground(7)
			SetCharacter(8)
		SceneProgress.SceneHome:
			SetBackground(11)
			SetCharacter(27)
		SceneProgress.SceneMarket:
			SetBackground(12)
			SetCharacter(29)
		SceneProgress.SceneGym:
			SetBackground(8)
			SetCharacter(22)
		SceneProgress.SceneOffice:
			SetBackground(9)
			SetCharacter(24)
		SceneProgress.SceneChurch:
			SetBackground(10)
			SetCharacter(26)

func SubscribeHoverEffects() -> void:
	if hoverRegions.is_empty() or isHoverEffectsSubscribed:
		return
	_hoverClickActions.clear()
	for entry in hoverRegions:
		var r = entry.get("region")
		if r == null:
			continue
		var hover = U.GetComponent(r, UIHoverRegion)
		if hover == null:
			continue
		var cap = entry
		var h := func(): OnHoverClicked(cap)
		_hoverClickActions.append([hover, h])
		hover.OnRegionClicked.connect(h)
	isHoverEffectsSubscribed = true

func UnsubscribeHoverEffects() -> void:
	if not isHoverEffectsSubscribed:
		return
	for pair in _hoverClickActions:
		if is_instance_valid(pair[0]) and pair[0].OnRegionClicked.is_connected(pair[1]):
			pair[0].OnRegionClicked.disconnect(pair[1])
	_hoverClickActions.clear()
	isHoverEffectsSubscribed = false

func OnHoverClicked(entry) -> void:
	SetActive(entry.get("region"), false)
	match int(entry.get("action", 0)):
		HoverAction.EnterTown:
			OnDoorClicked()
		HoverAction.OpenMarket:
			TriggerMarketScene()
		HoverAction.OpenChurch:
			TriggerChurchScene()
		HoverAction.OpenHome:
			TriggerHomeScene()
		HoverAction.OpenOffice:
			TriggerOfficeScene()
		HoverAction.OpenGym:
			TriggerGymScene()
		HoverAction.SleepToNextDay:
			SkipToNextDay()
		HoverAction.ShowGardenHole:
			ShowGardenHole()
		HoverAction.ShowPool:
			ShowPool()
		HoverAction.CollectItem:
			CollectWorldItem(int(entry.get("worldItemIndex", 0)))
		HoverAction.OpenStove:
			OpenStove(int(entry.get("worldItemIndex", 0)))
		HoverAction.QuestInteract:
			if entry.get("questGrantItem") != null and InventoryManager.Instance != null:
				InventoryManager.Instance.AddItem(entry.questGrantItem)
			var on_interact := func() -> void:
				if QuestManager.Instance != null and not U.empty(entry.get("questObjectiveTag")):
					QuestManager.Instance.NotifyObjectInteracted(entry.questObjectiveTag, maxi(1, int(entry.get("questProgressAmount", 1))))
			PlayQuestDialogueThen(entry, on_interact)
		HoverAction.QuestTalk:
			var on_talk := func() -> void:
				if QuestManager.Instance != null:
					QuestManager.Instance.NotifyTalkToNPC(entry.get("questObjectiveTag"), maxi(1, int(entry.get("questProgressAmount", 1))))
			PlayQuestDialogueThen(entry, on_talk)
		HoverAction.QuestCombat:
			StartQuestCombat(entry)
		HoverAction.GoToQuestLocation:
			ShowQuestLocation(entry.get("questLocationName"))
		HoverAction.ReturnToTown:
			ReturnToTownFromQuestLocation()

func PlayQuestDialogueThen(entry, on_done: Callable) -> void:
	var node = entry.get("questDialogueNode")
	if node == null or DialogueManager.Instance == null or DialogueManager.Instance.IsInDialogue():
		on_done.call()
		return
	if U.empty(node.speakerName):
		node = node.duplicate_so()
		var pm = ProfileManager.Instance
		node.d.speakerName = pm.profile.playerName if pm != null and pm.profile != null else Loc.T("You", "Sen")
	DialogueManager.Instance.StartDialogue(node, on_done)

func StartQuestCombat(entry) -> void:
	if entry.get("questEnemy") == null or CombatManager.Instance == null or CombatManager.Instance.inCombat:
		return
	var region = entry.get("region")
	PlayQuestDialogueThen(entry, func(): _quest_combat_go(entry, region))

func _quest_combat_go(entry, region) -> void:
	var cm = CombatManager.Instance
	if cm == null or cm.inCombat:
		return
	var location = _currentQuestLocation
	var state := {}
	var cleanup := func() -> void:
		U.off(cm.OnCombatDefeat, state.defeat)
		U.off(cm.OnCombatFled, state.defeat)
		U.off(cm.OnCombatVictory, state.victory)
	var on_defeat := func() -> void:
		cleanup.call()
		RestoreQuestLocationAfterLostCombat(location, region)
	var on_victory := func(_e) -> void:
		cleanup.call()
		CountGroupFight(entry)
		RestoreHudAfterQuestCombat()
	state.defeat = on_defeat
	state.victory = on_victory
	cm.OnCombatDefeat.connect(state.defeat)
	cm.OnCombatFled.connect(state.defeat)
	cm.OnCombatVictory.connect(state.victory)
	cm.StartCombat(entry.questEnemy)

func _wait_combat_ui_closed() -> void:
	while (CombatManager.Instance != null and CombatManager.Instance.inCombat) or (CombatUI.Instance != null and CombatUI.Instance.combatPanel != null and CombatUI.Instance.combatPanel.visible):
		await U.frame()

func RestoreQuestLocationAfterLostCombat(location, region) -> void:
	await _wait_combat_ui_closed()
	if PlayerStats.Instance != null:
		PlayerStats.Instance.FullRestore()
	if not U.empty(location):
		ShowQuestLocation(location)
	elif region != null:
		U.SetActive(region, true)
	ShowHudPanels()

func CountGroupFight(entry) -> void:
	await U.frame()
	var qm = QuestManager.Instance
	var amt := int(entry.get("questProgressAmount", 1))
	if qm == null or amt <= 1 or U.empty(entry.get("questID")) or U.empty(entry.get("questObjectiveTag")):
		return
	var st = qm.GetObjectiveState(entry.questID, entry.questObjectiveTag)
	if st != null and not st.isCompleted and st.currentProgress < amt:
		qm.UpdateObjectiveProgress(entry.questID, entry.questObjectiveTag, amt - st.currentProgress)
	ApplyHoverVisibility(-1 if IsShowingQuestLocation else _lastBgIndex)

func RestoreHudAfterQuestCombat() -> void:
	await U.frame()
	await U.frame()
	ShowHudPanels()

func ReturnToTownFromQuestLocation() -> void:
	_currentQuestLocation = null
	Progress = SceneProgress.Scene1
	SetBackground(0)
	ShowHudPanels()

static func IsQuestObjectiveAction(a: int) -> bool:
	return a == HoverAction.QuestTalk or a == HoverAction.QuestInteract or a == HoverAction.QuestCombat

func IsQuestObjectiveActive(qid, oid) -> bool:
	if U.empty(qid) or QuestManager.Instance == null or not QuestManager.Instance.IsQuestActive(qid):
		return false
	if U.empty(oid):
		return true
	var st = QuestManager.Instance.GetObjectiveState(qid, oid)
	return st == null or not st.isCompleted

func IsQuestIconActive(loc) -> bool:
	var qid = loc.get("questID")
	if U.empty(qid) or QuestManager.Instance == null or not QuestManager.Instance.IsQuestActive(qid):
		return false
	if U.empty(loc.get("questObjectiveID")):
		return true
	for raw in str(loc.questObjectiveID).split(","):
		var id := raw.strip_edges()
		if id == "":
			continue
		var st = QuestManager.Instance.GetObjectiveState(qid, id)
		if st == null or not st.isCompleted:
			return true
	return false

func ApplyHoverVisibility(bg: int) -> void:
	for entry in hoverRegions:
		var r = entry.get("region")
		if r == null:
			continue
		var action := int(entry.get("action", 0))
		var qloc = entry.get("questLocationName")
		var is_qloc: bool = not U.empty(qloc) and (IsQuestObjectiveAction(action) or action == HoverAction.ReturnToTown)
		var visible := false
		if is_qloc:
			visible = _currentQuestLocation == qloc and PhaseMatches(int(entry.get("phase", 0)))
			if IsQuestObjectiveAction(action):
				visible = visible and IsQuestObjectiveActive(entry.get("questID"), entry.get("questObjectiveTag"))
		else:
			var vob = entry.get("visibleOnBackgrounds")
			if vob == null or vob.is_empty():
				continue
			visible = U.empty(_currentQuestLocation) and vob.has(bg) and PhaseMatches(int(entry.get("phase", 0)))
			if action == HoverAction.EnterTown:
				visible = visible and not _doorClicked and not StoryFlags.Has("day1_complete")
		if not U.empty(entry.get("hideIfFlag")) and StoryFlags.Has(entry.hideIfFlag):
			visible = false
		SetActive(r, visible)

func ApplyItemVisibility(bg: int) -> void:
	for i in worldItems.size():
		var entry = worldItems[i]
		var it = entry.get("item")
		if it == null or not is_instance_valid(it):
			continue
		if not U.empty(entry.get("questLocationName")):
			SetActive(it, _currentQuestLocation == entry.questLocationName)
		else:
			var vob = entry.get("visibleOnBackgrounds")
			if vob != null and not vob.is_empty():
				SetActive(it, U.empty(_currentQuestLocation) and vob.has(bg))
		var wi = U.GetComponent(it, WorldItem)
		if it.visible and wi != null and wi.IsCollected:
			SetActive(it, false)
		if entry.get("name") == "HistoryBook" and it.visible and i < _itemDefaultY.size():
			var p: Vector2 = it.anchoredPosition
			it.anchoredPosition = Vector2(p.x, _itemDefaultY[i] + (25.0 if IsNight() or IsEvening() else 0.0))

func PhaseMatches(c: int) -> bool:
	match c:
		PhaseCondition.Any:
			return true
		PhaseCondition.MorningOrNoon:
			return IsMorningOrNoon()
		PhaseCondition.NotNight:
			return not IsNight()
		PhaseCondition.NightOnly:
			return IsNight()
		PhaseCondition.NoonOrEvening:
			return IsNoonOrEvening()
		PhaseCondition.MorningOnly:
			return IsMorning()
		PhaseCondition.EveningOrNight:
			return IsEvening() or IsNight()
	return true

func ResetSceneProgress() -> void:
	_doorClicked = false
	if TimePhaseManager.Instance != null:
		TimePhaseManager.Instance.SetPhase(TimePhase.Morning)
	Progress = SceneProgress.Scene1
	SetBackground(0)
	SetCharacter(0)
	TryStartDialogue(0)

static func SetActive(go, active: bool) -> void:
	if go != null and is_instance_valid(go):
		U.SetActive(go, active)

static func SetInteractable(go, inter: bool) -> void:
	if go == null:
		return
	var b = U.GetComponentInChildren(go, UButton)
	if b != null:
		b.interactable = inter

func IsEvening() -> bool:
	return TimePhaseManager.Instance != null and TimePhaseManager.Instance.currentPhase == TimePhase.Evening

func IsNight() -> bool:
	return TimePhaseManager.Instance != null and TimePhaseManager.Instance.currentPhase == TimePhase.Night

func IsMorningOrNoon() -> bool:
	return TimePhaseManager.Instance != null and TimePhaseManager.Instance.currentPhase <= TimePhase.Noon

func IsNoonOrEvening() -> bool:
	return TimePhaseManager.Instance != null and (TimePhaseManager.Instance.currentPhase == TimePhase.Noon or TimePhaseManager.Instance.currentPhase == TimePhase.Evening)

func IsMorning() -> bool:
	return TimePhaseManager.Instance != null and TimePhaseManager.Instance.currentPhase == TimePhase.Morning

func OnPhaseChanged(p: int) -> void:
	if _lastObservedPhase == TimePhase.Night and p == TimePhase.Morning:
		dayScenarioPending = true
	_lastObservedPhase = p
	if mapPanel != null and mapPanel.visible:
		SetMap(currentMapIndex)
	if backgroundImage != null and _lastBgIndex >= 0:
		var r = ResolveBg(_lastBgIndex)
		if r != null:
			backgroundImage.sprite = r
	elif backgroundImage != null and not U.empty(_currentQuestLocation):
		var r2 = ResolveQuestLocationBg(_currentQuestLocation, p)
		if r2 != null:
			backgroundImage.sprite = r2
		ApplyHoverVisibility(-1)
		ApplyItemVisibility(-1)
	var shown = ShownBackdrop()
	var for_phase = PhaseVariantOf(shown)
	if shown != null and for_phase != shown:
		SetBackdrop(for_phase)
	ClearDialogueBackground()
	if _lastBgIndex == 11 and _sceneCharacterActive and charImage != null and DialogueManager.Instance != null and not DialogueManager.Instance.IsInDialogue():
		var show_home := not IsNight() and not IsEvening()
		SetActive(charImage, show_home)
		if show_home:
			SetCharacter(27)
	if _sceneCharacterActive and charImage != null and charImage.visible and _lastCharIndex >= 0 and _lastCharIndex < characters.size():
		var s = ResolveCharEntry(characters[_lastCharIndex], p)
		if s != null:
			charImage.sprite = s
			FitCharacterWidth()
	if _lastBgIndex >= 0:
		ApplyHoverVisibility(_lastBgIndex)
		ApplyItemVisibility(_lastBgIndex)

func GetFleeAction():
	var cm = CombatManager.Instance
	if cm == null:
		return null
	for a in cm.defaultActions:
		if a.isFlee:
			return a
	return null

func SetFleeDisabled(v: bool) -> void:
	var f = GetFleeAction()
	if f != null:
		f.isDisabled = v

func StartCombatForScene(i: int, on_victory: Callable, on_defeat: Callable, on_flee = null) -> void:
	var cm = CombatManager.Instance
	if cm == null or i < 0 or i >= enemies.size() or enemies[i] == null:
		return
	UnsubscribeSceneCombat()
	_currentVictoryHandler = on_victory
	_currentDefeatHandler = on_defeat
	_currentFleeHandler = on_flee
	cm.OnCombatVictory.connect(on_victory)
	cm.OnCombatDefeat.connect(on_defeat)
	if on_flee != null:
		cm.OnCombatFled.connect(on_flee)
	SetFleeDisabled(on_flee == null)
	cm.StartCombat(enemies[i])

func UnsubscribeSceneCombat() -> void:
	var cm = CombatManager.Instance
	if cm == null:
		return
	if _currentVictoryHandler != null:
		U.off(cm.OnCombatVictory, _currentVictoryHandler)
		_currentVictoryHandler = null
	if _currentDefeatHandler != null:
		U.off(cm.OnCombatDefeat, _currentDefeatHandler)
		_currentDefeatHandler = null
	if _currentFleeHandler != null:
		U.off(cm.OnCombatFled, _currentFleeHandler)
		_currentFleeHandler = null

func StartCombatForScene4() -> void:
	var on_victory := func(_e) -> void:
		SetFleeDisabled(false)
		UnsubscribeSceneCombat()
		StoryFlags.Add("day1_complete")
		TriggerScene5()
	var on_defeat := func() -> void:
		SetFleeDisabled(false)
		UnsubscribeSceneCombat()
		RestartScene4AfterCombatCloses()
	var on_flee := func() -> void:
		SetFleeDisabled(false)
		UnsubscribeSceneCombat()
		RestartDay1AfterCombatCloses()
	StartCombatForScene(0, on_victory, on_defeat, on_flee)

func _wait_combat_panel_closed() -> void:
	while CombatUI.Instance != null and CombatUI.Instance.combatPanel != null and CombatUI.Instance.combatPanel.visible:
		await U.frame()

func RestartScene4AfterCombatCloses() -> void:
	await _wait_combat_panel_closed()
	if PlayerStats.Instance != null:
		PlayerStats.Instance.FullRestore()
	SetBackground(3)
	SetCharacter(14)
	TryStartDialogue(3)

func RestartDay1AfterCombatCloses() -> void:
	await _wait_combat_panel_closed()
	if PlayerStats.Instance != null:
		PlayerStats.Instance.FullRestore()
	ResetSceneProgress()

func WakeUpInBedToRetryDay() -> void:
	_transitionDepth += 1
	await RunSceneFade(1.0, SceneDipOut)
	HideAllPanels()
	if TimePhaseManager.Instance != null:
		TimePhaseManager.Instance.SetPhase(TimePhase.Morning)
	dayScenarioPending = true
	Progress = SceneProgress.SceneHome
	SetBackground(BedroomBackground)
	await U.wait_rt(0.6)
	await RunSceneFade(0.0, SceneDipIn)
	_transitionDepth = maxi(0, _transitionDepth - 1)
	ShowHudPanels()
	ShowForegroundMessage(Loc.T("You wake up in your bed, aching all over. The day begins again.", "Yatağında, her yerin sızlayarak uyanıyorsun. Gün yeniden başlıyor."), 4.0)
	SaveSystem.SaveGame()

func SkipToNextDay() -> void:
	var tpm = TimePhaseManager.Instance
	if tpm == null:
		return
	if tpm.currentPhase < earliestSleepPhase:
		ShowForegroundMessage(Loc.T("It's too early to sleep.", "Uyumak için çok erken."), 2.0)
		return
	if ScenarioManager.Instance != null and ScenarioManager.Instance.IsWaitingAfterRetreat:
		ShowForegroundMessage(Loc.T("Not yet. The fight you ran from is waiting for you in the village square.", "Henüz değil. Kaçtığın dövüş seni köy meydanında bekliyor."), 3.0)
		return
	if not IsCurrentDayContentComplete():
		if IsDayStoryWaiting and GetNextDayScenario() != null:
			ShowForegroundMessage(Loc.T("Not yet. Today's story is waiting for you in the village square.", "Henüz değil. Bugünün hikayesi seni köy meydanında bekliyor."), 3.0)
		else:
			ShowForegroundMessage(Loc.T("Not yet. Finish the quests in your journal before resting.", "Henüz değil. Dinlenmeden önce günlüğündeki görevleri bitir."), 3.0)
		return
	ShowSleepingPanelAfterDelay(3.0)
	while tpm.currentPhase != TimePhase.Night:
		tpm.NextPhase()
	tpm.NextPhase()
	if PlayerStats.Instance != null:
		PlayerStats.Instance.FullRestore()

func IsCurrentDayContentComplete() -> bool:
	var day: int = TimeUI.Instance.GetCurrentDay() if TimeUI.Instance != null else 1
	if day <= 1:
		return StoryFlags.Has("day1_complete")
	var sm = ScenarioManager.Instance
	if sm == null:
		return true
	var sid := "ashenveil_day%d" % day
	if sm.GetScenarioByID(sid) == null:
		return true
	if not sm.IsScenarioCompleted(sid):
		return false
	if sm.GetScenarioByID("ashenveil_day%d" % (day + 1)) == null and QuestManager.Instance != null:
		for q in LastDayQuests:
			if QuestManager.Instance.IsQuestActive(q):
				return false
	return true

func SyncTimePhaseToScene(scene: int) -> void:
	if TimePhaseManager.Instance == null:
		return
	var target := -1
	match scene:
		SceneProgress.Scene1, SceneProgress.Scene2:
			target = TimePhase.Morning
		SceneProgress.Scene3, SceneProgress.Scene4, SceneProgress.Scene5, SceneProgress.Scene6:
			target = TimePhase.Noon
		SceneProgress.Scene7, SceneProgress.Scene8:
			target = TimePhase.Evening
		SceneProgress.Scene9:
			target = TimePhase.Night
	if target >= 0 and target > TimePhaseManager.Instance.currentPhase:
		TimePhaseManager.Instance.SetPhase(target)

func TryStartDayScenario() -> void:
	var sm = ScenarioManager.Instance
	if sm == null or not dayScenarioPending or sm.IsScenarioActive():
		return
	var s = GetNextDayScenario()
	if s == null:
		TryPlayFinaleCutscene()
		return
	if OriginManager.Instance != null and OriginManager.Instance.ShouldHoldDayScenario(s.scenarioID):
		return
	dayScenarioPending = false
	if TimePhaseManager.Instance != null and TimePhaseManager.Instance.currentPhase != TimePhase.Morning:
		TimePhaseManager.Instance.SetPhase(TimePhase.Morning)
	sm.StartScenario(s)

func TryPlayFinaleCutscene() -> void:
	const flag := "ashenveil_finale_shown"
	if finaleCutsceneNode == null or DialogueManager.Instance == null or StoryFlags.Has(flag) or not AllDayScenariosCompleted() or TryStartSharedEpilogue():
		return
	dayScenarioPending = false
	StoryFlags.Add(flag)
	StoryFlags.Add(ChooseEnding())
	DialogueManager.Instance.StartDialogue(finaleCutsceneNode)

static func ChooseEnding() -> String:
	var serena: int = AffinityManager.Instance.Get("Serena") if AffinityManager.Instance != null else 0
	if StoryFlags.Has(AshenveilVossWeakPoint.SerenaBondBroken) and serena >= 35:
		return EndingTwoInTheDoor
	return EndingOpenAccount if StoryFlags.Has("court_parley") else EndingDoorHeld

func TryStartSharedEpilogue() -> bool:
	var sm = ScenarioManager.Instance
	var ep = sm.GetScenarioByID(SharedEpilogueScenario) if sm != null else null
	if ep == null or sm.IsScenarioCompleted(SharedEpilogueScenario):
		return false
	StoryFlags.Add(SharedEpilogueStartFlag)
	if not sm.IsScenarioActive() and sm.CanStartScenario(ep):
		sm.StartScenario(ep)
	return sm.IsScenarioActive()

func AllDayScenariosCompleted() -> bool:
	var sm = ScenarioManager.Instance
	if sm == null:
		return false
	var any := false
	for s in sm.availableScenarios:
		if s == null or not str(s.scenarioID).begins_with("ashenveil_day"):
			continue
		any = true
		if not sm.IsScenarioCompleted(s.scenarioID):
			return false
	return any

func GetNextDayScenario():
	var sm = ScenarioManager.Instance
	if sm == null:
		return null
	for s in sm.availableScenarios:
		if s == null or not str(s.scenarioID).begins_with("ashenveil_day") or sm.IsScenarioCompleted(s.scenarioID):
			continue
		if sm.CanStartScenario(s):
			return s
	return null

func ShowSleepingPanelAfterDelay(delay: float) -> void:
	SetActive(sleepingPanel, true)
	await U.wait(delay)
	SetActive(sleepingPanel, false)

func ShowForegroundMessage(msg: String, secs: float) -> void:
	if ForegroundNotifier.Instance != null:
		ForegroundNotifier.Instance.ShowMessage(msg, secs)

func StartMapCombat(enemy) -> void:
	if enemy == null or CombatManager.Instance == null or CombatManager.Instance.inCombat:
		return
	HideAllPanels()
	CombatManager.Instance.StartCombat(enemy)

func ShowGardenHole() -> void:
	SetBackground(38)

func ShowPool() -> void:
	SetBackground(39)

func ResolveQuestLocationBg(n, p: int):
	for q in questLocationBackgrounds:
		if q.get("name") == n:
			return ResolveNamed(q, p)
	return null

func ShowQuestLocation(n) -> void:
	if U.empty(n) or backgroundImage == null:
		return
	var spr = ResolveQuestLocationBg(n, _phase())
	if spr == null:
		return
	backgroundImage.sprite = spr
	_currentQuestLocation = n
	_lastBgIndex = -1
	UIPanelAnimator.Hide(mapPanel)
	ClearDialogueBackground()
	SetActive(townNpc, false)
	ForceHideSceneCharacter()
	ApplyHoverVisibility(-1)
	ApplyItemVisibility(-1)
	ApplyHouseIconVisibility(false)
	if n == "bg_templeborn_archives":
		StartTeaHandIn()

func StartTeaHandIn() -> void:
	var qm = QuestManager.Instance
	if qm == null or not qm.IsQuestActive("q01_bir_fincan_huzur"):
		return
	var o = qm.GetObjectiveState("q01_bir_fincan_huzur", "q01_obj4")
	if o == null or o.isCompleted:
		return
	var has_cup: bool = InventoryManager.Instance != null and InventoryManager.Instance.GetTotalQuantity("apple_tea") > 0
	if has_cup and marenTeaDialogue != null and DialogueManager.Instance != null:
		DialogueManager.Instance.StartDialogue(marenTeaDialogue, DeliverTeaToMaren)
		return
	DeliverTeaToMaren()

func CollectAppleTeaSeed() -> void:
	CollectWorldItem(0)

func CollectHistoryBook() -> void:
	CollectWorldItem(1)

func CollectApple() -> void:
	CollectWorldItem(2)

func CollectCinnamon() -> void:
	CollectWorldItem(3)

func CollectWorldItem(i: int) -> void:
	if i < 0 or i >= worldItems.size() or worldItems[i].get("item") == null:
		return
	var it = worldItems[i].item
	if not is_instance_valid(it):
		return
	var wi = U.GetComponent(it, WorldItem)
	if wi != null:
		wi.Collect()
	else:
		U.Destroy(it)

func OpenStove(i: int) -> void:
	SetBackground(i if i > 0 else 17)
	TryBrewTeaAtStove()

func TryBrewTeaAtStove() -> void:
	const qid := "q01_bir_fincan_huzur"
	const oid := "q01_obj3"
	var qm = QuestManager.Instance
	if qm == null or not qm.IsQuestActive(qid):
		return
	var o = qm.GetObjectiveState(qid, oid)
	if o == null or o.isCompleted:
		return
	var inv = InventoryManager.Instance
	var db = ItemDatabase.Instance
	var apple = db.GetByID("fresh_apple") if db != null else null
	var cin = db.GetByID("cinnamon") if db != null else null
	if inv == null or apple == null or cin == null or inv.GetTotalQuantity("fresh_apple") <= 0 or inv.GetTotalQuantity("cinnamon") <= 0:
		ShowForegroundMessage(Loc.T("You need a Fresh Apple and Cinnamon to brew the tea.", "Çayı demlemek için bir Taze Elma ve Tarçın gerekiyor."), 3.0)
		return
	inv.RemoveItem(apple)
	inv.RemoveItem(cin)
	qm.UpdateObjectiveProgress(qid, oid, 1)
	var tea = db.GetByID("apple_tea")
	if tea != null:
		inv.AddItem(tea)
	ShowForegroundMessage(Loc.T("The tea is brewed. Use the cup from your inventory to give it to Maren.", "Çay demlendi. Maren'e vermek için fincanı envanterden kullan."), 3.5)

func HandleItemUsed(item) -> void:
	if item != null and item.itemID == "apple_tea":
		DeliverTeaToMaren()

func DeliverTeaToMaren() -> void:
	const qid := "q01_bir_fincan_huzur"
	const oid := "q01_obj4"
	var qm = QuestManager.Instance
	if qm == null or not qm.IsQuestActive(qid):
		return
	var o = qm.GetObjectiveState(qid, oid)
	if o == null or o.isCompleted:
		return
	var tea = ItemDatabase.Instance.GetByID("apple_tea") if ItemDatabase.Instance != null else null
	if tea == null or InventoryManager.Instance == null or InventoryManager.Instance.GetTotalQuantity("apple_tea") <= 0:
		ShowForegroundMessage(Loc.T("You need to brew the tea at the stove first.", "Önce ocakta çayı demlemen gerek."), 2.5)
		return
	InventoryManager.Instance.RemoveItem(tea)
	if marenDeliveryNode != null and DialogueManager.Instance != null and not DialogueManager.Instance.IsInDialogue():
		DialogueManager.Instance.StartDialogue(marenDeliveryNode, func(): CompleteMarenDelivery(qid, oid))
		return
	CompleteMarenDelivery(qid, oid)

func CompleteMarenDelivery(qid: String, oid: String) -> void:
	if QuestManager.Instance != null:
		QuestManager.Instance.UpdateObjectiveProgress(qid, oid, 1)
	ShowForegroundMessage(Loc.T("You gave the cup to Maren.", "Fincanı Maren'e verdin."), 3.0)

func OnDoorClicked() -> void:
	_doorClicked = true
	if Progress != SceneProgress.Scene1:
		Progress = SceneProgress.Scene1
	TriggerScene2()

func StartCashierDialogue() -> void:
	TriggerMarketScene()

func StartNunDialogue() -> void:
	TriggerChurchScene()

func StartCoachDialogue() -> void:
	TriggerGymScene()

func StartStepSisterDialogue() -> void:
	TriggerHomeScene()

func StartOfficerDialogue() -> void:
	TriggerOfficeScene()

func TriggerHomeScene() -> void:
	Progress = SceneProgress.SceneHome
	TryStartDialogue(12)

func TriggerMarketScene() -> void:
	Progress = SceneProgress.SceneMarket
	TryStartDialogue(9)

func TriggerGymScene() -> void:
	Progress = SceneProgress.SceneGym
	TryStartDialogue(11)

func TriggerOfficeScene() -> void:
	Progress = SceneProgress.SceneOffice
	TryStartDialogue(13)

func TriggerChurchScene() -> void:
	Progress = SceneProgress.SceneChurch
	TryStartDialogue(10)

func TriggerScene2() -> void:
	if Progress != SceneProgress.Scene1:
		return
	Progress = SceneProgress.Scene2
	SetBackground(1)
	SetCharacter(8)
	TryStartDialogue(1)

func TriggerScene3() -> void:
	if Progress != SceneProgress.Scene2:
		return
	Progress = SceneProgress.Scene3
	SetBackground(2)
	SetCharacter(8)
	TryStartDialogue(2)

func TriggerScene4() -> void:
	if Progress != SceneProgress.Scene3:
		return
	Progress = SceneProgress.Scene4
	SetBackground(3)
	TryStartDialogue(3)

func TriggerScene5() -> void:
	if Progress != SceneProgress.Scene4:
		return
	await _wait_combat_panel_closed()
	Progress = SceneProgress.Scene5
	SetCharacter(8)
	TryStartDialogue(4)

func TriggerScene6() -> void:
	if Progress != SceneProgress.Scene5:
		return
	Progress = SceneProgress.Scene6
	SetBackground(4)
	SetCharacter(8)
	TryStartDialogue(5)

func TriggerScene7() -> void:
	if Progress != SceneProgress.Scene6:
		return
	Progress = SceneProgress.Scene7
	SetBackground(5)
	SetCharacter(8)
	TryStartDialogue(6)

func TriggerScene8() -> void:
	if Progress != SceneProgress.Scene7:
		return
	Progress = SceneProgress.Scene8
	SetBackground(6)
	SetCharacter(8)
	TryStartDialogue(7)

func TriggerScene9() -> void:
	if Progress != SceneProgress.Scene8:
		return
	Progress = SceneProgress.Scene9
	SetBackground(7)
	SetCharacter(8)
	TryStartDialogue(8)
