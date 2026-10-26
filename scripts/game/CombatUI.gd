class_name CombatUI
extends Mono

static var Instance: CombatUI
var actionButtons: Array = []
var actionLocked := false
var logLines: Array = []
var combatPanel
var combatMapPanel
var enemySprite
var enemyNameText
var enemyHealthBar
var enemyHealthText
var playerNameText
var playerHealthBar
var playerHealthText
var playerEnergyBar
var playerEnergyText
var playerTurnIndicator
var enemyTurnIndicator
var turnText
var actionsParent
var actionButtonPrefab
var combatLogText
var maxLogLines := 8
var _subscribed := false

var IsInCombat: bool:
	get:
		return CombatManager.Instance != null and CombatManager.Instance.inCombat

func Awake() -> void:
	Instance = self

func Start() -> void:
	if combatPanel != null:
		U.SetActive(combatPanel, false)

func OnEnable() -> void:
	SubscribeWhenReady()

func OnDisable() -> void:
	var cm = CombatManager.Instance
	if cm != null:
		U.off(cm.OnCombatStateChanged, UpdateUI)
		U.off(cm.OnCombatLog, AddLogMessage)
		U.off(cm.OnCombatStarted, OnCombatStarted)
		U.off(cm.OnCombatEnded, OnCombatEnded)
		U.off(cm.OnTurnChanged, OnTurnChanged)
	if PlayerStats.Instance != null:
		U.off(PlayerStats.Instance.OnHealthChanged, UpdatePlayerHealth)
		U.off(PlayerStats.Instance.OnEnergyChanged, UpdatePlayerEnergy)

func SubscribeWhenReady() -> void:
	var e := co()
	var t := 0.0
	while (CombatManager.Instance == null or PlayerStats.Instance == null) and t < 10.0:
		t += U.deltaTime
		await U.frame()
		if dead(e):
			return
	if CombatManager.Instance == null or PlayerStats.Instance == null:
		return
	var cm = CombatManager.Instance
	U.on(cm.OnCombatStateChanged, UpdateUI)
	U.on(cm.OnCombatLog, AddLogMessage)
	U.on(cm.OnCombatStarted, OnCombatStarted)
	U.on(cm.OnCombatEnded, OnCombatEnded)
	U.on(cm.OnTurnChanged, OnTurnChanged)
	U.on(PlayerStats.Instance.OnHealthChanged, UpdatePlayerHealth)
	U.on(PlayerStats.Instance.OnEnergyChanged, UpdatePlayerEnergy)

func OnCombatStarted() -> void:
	if combatPanel != null:
		U.SetActive(combatPanel, true)
	var pm = ProfileManager.Instance
	if playerNameText != null and pm != null and pm.profile != null and not U.blank(pm.profile.playerName):
		playerNameText.text = pm.profile.playerName
	logLines.clear()
	UpdateUI()
	SetupActionButtons()
	ES.rebuild_layout()

func OnCombatEnded() -> void:
	DelayedCombatClose()

func DelayedCombatClose() -> void:
	await U.wait(2.0)
	if combatPanel != null:
		U.SetActive(combatPanel, false)
	logLines.clear()
	UpdateLogDisplay()

func OnTurnChanged(is_player: bool) -> void:
	if is_player:
		actionLocked = false
	if playerTurnIndicator != null:
		U.SetActive(playerTurnIndicator, is_player)
	if enemyTurnIndicator != null:
		U.SetActive(enemyTurnIndicator, not is_player)
	if turnText != null:
		turnText.text = Loc.T("YOUR TURN", "SIRA SENDE") if is_player else Loc.T("ENEMY TURN", "DÜŞMAN SIRASI")
	UpdateActionButtons(is_player)

func UpdateUI() -> void:
	if CombatManager.Instance == null or not CombatManager.Instance.inCombat:
		if combatPanel != null:
			U.SetActive(combatPanel, false)
		return
	UpdateEnemyDisplay()
	UpdatePlayerHealth()
	UpdatePlayerEnergy()

func UpdateEnemyDisplay() -> void:
	var es = CombatManager.Instance.enemyStats
	var ed = CombatManager.Instance.currentEnemy
	if es == null or ed == null:
		return
	if enemySprite != null:
		enemySprite.sprite = ed.sprite
		enemySprite.preserveAspect = true
	if enemyNameText != null:
		enemyNameText.text = ed.DisplayName
	if enemyHealthBar != null:
		enemyHealthBar.maxValue = es.Get(StatType.MaxHealth)
		enemyHealthBar.value = es.Get(StatType.Health)
	if enemyHealthText != null:
		enemyHealthText.text = "%s: %d / %d" % [Loc.T("HP", "Can"), es.Get(StatType.Health), es.Get(StatType.MaxHealth)]

func UpdatePlayerHealth() -> void:
	if PlayerStats.Instance == null:
		return
	var c: int = PlayerStats.Instance.Get(StatType.Health)
	var m: int = PlayerStats.Instance.Get(StatType.MaxHealth)
	if playerHealthBar != null:
		playerHealthBar.maxValue = m
		playerHealthBar.value = c
	if playerHealthText != null:
		playerHealthText.text = "%s: %d / %d" % [Loc.T("HP", "Can"), c, m]

func UpdatePlayerEnergy() -> void:
	if PlayerStats.Instance == null:
		return
	var c: int = PlayerStats.Instance.Get(StatType.Energy)
	var m: int = PlayerStats.Instance.Get(StatType.MaxEnergy)
	if playerEnergyBar != null:
		playerEnergyBar.maxValue = m
		playerEnergyBar.value = c
	if playerEnergyText != null:
		playerEnergyText.text = "%s: %d / %d" % [Loc.T("Energy", "Enerji"), c, m]
	if IsInCombat:
		RefreshActionButtonsByEnergy()

func RefreshActionButtonsByEnergy() -> void:
	if CombatManager.Instance == null or not CombatManager.Instance.IsPlayerTurn() or actionLocked:
		return
	var e: int = PlayerStats.Instance.Get(StatType.Energy)
	for b in actionButtons:
		if not is_instance_valid(b):
			continue
		b.UpdateInteractable(true if b.action.isFlee else e >= b.action.energyCost)

func SetupActionButtons() -> void:
	var acts: Array = CombatManager.Instance.GetAvailableActions() if CombatManager.Instance != null else []
	for i in range(actionButtons.size() - 1, acts.size() - 1, -1):
		if is_instance_valid(actionButtons[i]):
			U.Destroy(actionButtons[i].gameObject)
		actionButtons.remove_at(i)
	for i in acts.size():
		var a = acts[i]
		if a.isFlee:
			var chance := U.RoundToInt(CombatManager.Instance.GetFleeChance() * 100)
			a.actionName = "Run (%d%%)" % chance
			a.actionNameTR = "Kaç (%%%d)" % chance
		if i < actionButtons.size():
			actionButtons[i].Setup(a)
		else:
			var b = U.Instantiate(actionButtonPrefab, actionsParent)
			b.Setup(a)
			actionButtons.append(b)
	UpdateActionButtons(CombatManager.Instance.IsPlayerTurn())

func DisableAllActionButtons() -> void:
	actionLocked = true
	for b in actionButtons:
		if is_instance_valid(b):
			b.UpdateInteractable(false)

func UpdateActionButtons(is_player: bool) -> void:
	if not is_player:
		for b in actionButtons:
			if is_instance_valid(b):
				b.UpdateInteractable(false)
	else:
		RefreshActionButtonsByEnergy()

func AddLogMessage(msg: String) -> void:
	logLines.append(msg)
	while logLines.size() > maxLogLines:
		logLines.remove_at(0)
	UpdateLogDisplay()

func UpdateLogDisplay() -> void:
	if combatLogText != null:
		combatLogText.text = "\n".join(logLines)

func CloseButton() -> void:
	if combatMapPanel != null:
		U.SetActive(combatMapPanel, false)
