class_name CombatManager
extends Mono

static var Instance: CombatManager
signal OnCombatLog(msg: String)
signal OnCombatStarted
signal OnCombatEnded
signal OnCombatStateChanged
signal OnTurnChanged(is_player: bool)
signal OnCombatVictory(enemy)
signal OnCombatDefeat
signal OnCombatFled

var inCombat := false
var currentEnemy
var enemyStats
var combatResolved := false
var isPlayerTurn := false
var waitingForInput := false
var playerDefenseBonus := 0
var enemyDefenseBonus := 0
var defaultActions: Array = []
var unlockedActions: Array = []
var turnDelay := 1.0
var enemyActionDelay := 1.5
var baseCritChance := 0.1
var critDamageMultiplier := 1.5
var maxDefenseBonus := 50
var defenseDecayPerTurn := 2
var defenseSoftcap := 150.0
var maxDamageReduction := 0.75
var combatEnergyRegenPerTurn := 5
var baseFleeChance := 0.3
var fleeSpeedScaling := 0.002
var fleeEnergyGain := 20
var combatEndEnergyFloorPercent := 0.6
var stunEffect
var poisonEffect
var stunApplyChance := 0.2
var poisonApplyChance := 0.3
var _flee_gen := 0
var _player_effects

var PlayerBuffs:
	get:
		return PlayerBuffManager.Instance

var PS:
	get:
		return PlayerStats.Instance

var PlayerEffects:
	get:
		if (_player_effects == null or not is_instance_valid(_player_effects)) and PS != null:
			_player_effects = PS.GetComponent(StatusEffectManager)
		return _player_effects

func _on_injected(_root: Node) -> void:
	var acts := []
	for a in defaultActions:
		if a is Dictionary:
			acts.append(CombatAction.from_dict(a))
	defaultActions = acts

func Awake() -> void:
	Instance = self

func Start() -> void:
	unlockedActions.clear()
	unlockedActions.append_array(defaultActions)
	if PS != null:
		U.on(PS.OnHealthChanged, OnPlayerHealthChanged)

func OnDestroy() -> void:
	if PS != null:
		U.off(PS.OnHealthChanged, OnPlayerHealthChanged)

func _enemy_fx():
	return enemyStats.GetComponent(StatusEffectManager) if enemyStats != null else null

func SubscribeToEnemyEvents() -> void:
	var fx = _enemy_fx()
	if fx != null:
		U.on(fx.OnEffectTick, OnEnemyEffectTick)
	if PlayerEffects != null:
		U.on(PlayerEffects.OnEffectTick, OnPlayerEffectTick)

func UnsubscribeFromEnemyEvents() -> void:
	var fx = _enemy_fx()
	if fx != null:
		U.off(fx.OnEffectTick, OnEnemyEffectTick)
	if PlayerEffects != null:
		U.off(PlayerEffects.OnEffectTick, OnPlayerEffectTick)

func StartCombat(enemy) -> void:
	if inCombat or enemy == null:
		return
	if PS != null and not PS.IsAlive():
		return
	_flee_gen += 1
	currentEnemy = enemy
	inCombat = true
	if enemyStats != null:
		enemyStats.InitializeFromData(currentEnemy)
	SubscribeToEnemyEvents()
	combatResolved = false
	isPlayerTurn = true
	waitingForInput = true
	playerDefenseBonus = 0
	enemyDefenseBonus = 0
	PS.enableHealthRegen = false
	PS.enableEnergyRegen = false
	OnCombatStarted.emit()
	OnTurnChanged.emit(true)
	OnCombatStateChanged.emit()

func ExecutePlayerAction(action) -> void:
	if action.isFlee:
		TryFleeAction()
		return
	if not CanExecutePlayerAction(action):
		return
	PS.Modify(StatType.Energy, -action.energyCost, false)
	waitingForInput = false
	if action.isDefensive:
		HandleDefensiveAction(action)
	else:
		HandleOffensiveAction(action)
	OnCombatStateChanged.emit()
	DelayedCall(turnDelay, StartEnemyTurn)

func CanExecutePlayerAction(action) -> bool:
	if not inCombat or not IsPlayerTurn():
		return false
	if not PS.HasEnoughEnergy(action.energyCost):
		Log("Not enough energy!")
		return false
	return true

func IsPlayerTurn() -> bool:
	return isPlayerTurn and waitingForInput

func StartPlayerTurn() -> void:
	if not inCombat or combatResolved:
		return
	if PlayerEffects != null:
		PlayerEffects.OnPlayerTurnStart()
	var efx = _enemy_fx()
	if efx != null:
		efx.OnPlayerTurnStart()
	if not inCombat or combatResolved:
		return
	if PlayerEffects != null and not PlayerEffects.CanAct():
		isPlayerTurn = false
		waitingForInput = false
		Log(Loc.T("You cannot act this turn!", "Bu tur hareket edemiyorsun!"))
		OnCombatStateChanged.emit()
		DelayedCall(turnDelay, StartEnemyTurn)
		return
	if combatEnergyRegenPerTurn > 0 and PS != null:
		PS.Modify(StatType.Energy, combatEnergyRegenPerTurn, false)
	isPlayerTurn = true
	waitingForInput = true
	OnTurnChanged.emit(true)

func StartEnemyTurn() -> void:
	if not inCombat or combatResolved:
		return
	isPlayerTurn = false
	OnTurnChanged.emit(false)
	DelayedCall(enemyActionDelay, ExecuteEnemyAction)

func HandleDefensiveAction(action) -> void:
	var bonus: int = action.CalculateDefenseBonus()
	playerDefenseBonus = clampi(playerDefenseBonus + bonus, 0, maxDefenseBonus)
	if action.healAmount > 0:
		PS.Modify(StatType.Health, action.healAmount, false)
	Log(Loc.T("%s used! +%d defense." % [action.DisplayActionName, bonus], "%s kullanıldı! +%d savunma." % [action.DisplayActionName, bonus]))
	if action.healAmount > 0:
		Log(Loc.T("+%d health restored." % action.healAmount, "+%d can yenilendi." % action.healAmount))
	if action.applyBuff and PlayerBuffs != null:
		var b := PlayerBuffManager.Buff.new()
		b.id = action.buffId
		b.displayName = action.DisplayBuffName
		b.type = action.buffType
		b.damageMultiplier = action.buffDamageMultiplier
		b.damageReduction = action.buffDamageReduction
		b.duration = action.buffDuration
		b.icon = action.buffIcon
		b.stackable = false
		PlayerBuffs.AddBuff(b)
		Log(Loc.T("%s active! (%ss)" % [action.DisplayBuffName, _fmt(action.buffDuration)], "%s etkin! (%ss)" % [action.DisplayBuffName, _fmt(action.buffDuration)]))

func _fmt(f: float) -> String:
	return str(int(f)) if f == floor(f) else str(f)

func HandleOffensiveAction(action) -> void:
	if enemyStats == null:
		return
	var dmg := CalculatePlayerDamage(action)
	ApplyDamageToEnemy(dmg)
	if IsEnemyDefeated():
		ResolveCombat(true)

func TryFleeAction() -> void:
	if not inCombat or not IsPlayerTurn():
		return
	waitingForInput = false
	var chance := GetFleeChance()
	if U.value() <= chance:
		Log("You successfully fled!")
		OnCombatStateChanged.emit()
		FleeCombat()
	else:
		Log("Failed to flee! (%d%% chance)" % U.RoundToInt(chance * 100))
		OnCombatStateChanged.emit()
		DelayedCall(turnDelay, StartEnemyTurn)

func GetFleeChance() -> float:
	var speed: int = PS.Get(StatType.Speed) if PS != null else 0
	var mult := 1.0
	if PlayerBuffManager.Instance != null:
		for b in PlayerBuffManager.Instance.GetActiveBuffs():
			if b.type == PlayerBuffManager.BuffType.Speed:
				mult += b.multiplier
	return clampf(baseFleeChance + speed * fleeSpeedScaling * mult, 0.0, 1.0)

func FleeCombat() -> void:
	if combatResolved:
		return
	combatResolved = true
	HandleFleeAfterDelay(turnDelay)

func CalculatePlayerDamage(action) -> int:
	var dmg: int = action.CalculateDamage()
	if CheckCriticalHit(action):
		dmg = U.RoundToInt(dmg * critDamageMultiplier)
		Log("Critical Hit!")
	var mult := 1.0
	if PlayerBuffs != null:
		mult = PlayerBuffs.GetDamageMultiplier()
	if PlayerEffects != null:
		mult *= PlayerEffects.GetDamageMultiplier()
	dmg = CalculateFinalDamage(dmg, GetEnemyTotalDefense(), action.ignoreDefense, action.armorPenetration, mult)
	var fx = _enemy_fx()
	if fx != null:
		dmg = U.RoundToInt(dmg * (1.0 - fx.GetDamageReduction()))
	return dmg

func ApplyDamageToEnemy(dmg: int) -> void:
	enemyStats.Modify(StatType.Health, -dmg)
	TryApplyOnHitEffects()
	Log(Loc.T("Dealt %d damage to %s." % [dmg, currentEnemy.DisplayName], "%s hedefine %d hasar verildi." % [currentEnemy.DisplayName, dmg]))

func IsEnemyDefeated() -> bool:
	return enemyStats.Get(StatType.Health) <= 0

func TryApplyOnHitEffects() -> void:
	var fx = _enemy_fx()
	if fx == null:
		return
	if stunEffect != null and U.value() < stunApplyChance:
		fx.ApplyEffect(stunEffect)
	if poisonEffect != null and U.value() < poisonApplyChance:
		fx.ApplyEffect(poisonEffect)
	if EquipmentManager.Instance == null:
		return
	var w = EquipmentManager.Instance.GetEquipped(EquipmentSlot.Weapon)
	if w == null or w.baseData == null or w.baseData.onHitEffect == null:
		return
	if U.value() < float(w.baseData.onHitChance):
		fx.ApplyEffect(w.baseData.onHitEffect)

func TryEnemyAbility() -> void:
	if currentEnemy == null or currentEnemy.combatAbility == null or float(currentEnemy.abilityChance) <= 0.0 or U.value() >= float(currentEnemy.abilityChance):
		return
	var ab = currentEnemy.combatAbility
	if currentEnemy.abilityTargetsSelf:
		var fx = _enemy_fx()
		if fx != null:
			fx.ApplyEffect(ab)
			Log(Loc.T("%s uses %s!" % [currentEnemy.DisplayName, ab.DisplayName], "%s, %s kullanıyor!" % [currentEnemy.DisplayName, ab.DisplayName]))
	elif PlayerEffects != null:
		PlayerEffects.ApplyEffect(ab)
		Log(Loc.T("%s afflicts you with %s!" % [currentEnemy.DisplayName, ab.DisplayName], "%s sana %s bulaştırıyor!" % [currentEnemy.DisplayName, ab.DisplayName]))

func CheckCriticalHit(action) -> bool:
	if action.guaranteedCrit:
		return true
	var c: float = baseCritChance + action.critChanceBonus + PS.Get(StatType.Luck) * 0.01
	if PlayerBuffs != null:
		for b in PlayerBuffs.GetActiveBuffs():
			if b.type == PlayerBuffManager.BuffType.CritChance:
				c += b.multiplier
	return U.value() <= clampf(c, 0.0, 1.0)

func ExecuteEnemyAction() -> void:
	if not (inCombat and not combatResolved and enemyStats != null and currentEnemy != null):
		return
	if PlayerEffects != null:
		PlayerEffects.OnEnemyTurnStart()
		if not PS.IsAlive():
			if not combatResolved:
				HandleDefeatAfterDelay(turnDelay)
			return
	var fx = _enemy_fx()
	if fx != null:
		var can_act: bool = fx.CanAct()
		fx.OnEnemyTurnStart()
		if combatResolved:
			return
		if IsEnemyDefeated():
			ResolveCombat(true)
			return
		if not can_act:
			Log(Loc.T("%s is stunned and cannot act!" % currentEnemy.DisplayName, "%s sersemledi ve hareket edemiyor!" % currentEnemy.DisplayName))
			DecayDefenseBonuses()
			OnCombatStateChanged.emit()
			DelayedCall(turnDelay, StartPlayerTurn)
			return
	TryEnemyAbility()
	var ehp: float = float(enemyStats.Get(StatType.Health)) / enemyStats.Get(StatType.MaxHealth)
	var php: float = float(PS.Get(StatType.Health)) / PS.Get(StatType.MaxHealth)
	match int(currentEnemy.aiPattern):
		EnemyAIPattern.Aggressive:
			if ehp < float(currentEnemy.lowHealthThreshold) and U.value() < float(currentEnemy.defendChance):
				Defend()
			elif U.value() < float(currentEnemy.specialAttackChance):
				SpecialAttack()
			else:
				Attack()
		EnemyAIPattern.Defensive:
			var odds: float = clampf(float(currentEnemy.defendChance) + 0.35, 0.0, 1.0) if ehp < 0.5 else float(currentEnemy.defendChance)
			if U.value() < odds:
				Defend()
			else:
				Attack()
		EnemyAIPattern.Finisher:
			if php < float(currentEnemy.finisherThreshold):
				SpecialAttack()
			else:
				Attack()
		_:
			var roll := U.value()
			if roll < float(currentEnemy.defendChance):
				Defend()
			elif roll < float(currentEnemy.defendChance) + float(currentEnemy.specialAttackChance):
				SpecialAttack()
			else:
				Attack()
	DecayDefenseBonuses()
	OnCombatStateChanged.emit()
	if not PS.IsAlive():
		if not combatResolved:
			HandleDefeatAfterDelay(turnDelay)
		return
	DelayedCall(turnDelay, StartPlayerTurn)

func GetEnemyTotalDefense() -> int:
	return enemyStats.Get(StatType.Defense) + enemyDefenseBonus

func OnEnemyEffectTick(data, dmg: int) -> void:
	if not inCombat or combatResolved:
		return
	Log(Loc.T("%s takes %d %s damage." % [currentEnemy.DisplayName, dmg, data.DisplayName], "%s, %d %s hasarı alıyor." % [currentEnemy.DisplayName, dmg, data.DisplayName]))
	if IsEnemyDefeated():
		ResolveCombat(true)

func OnPlayerEffectTick(data, dmg: int) -> void:
	if inCombat:
		Log(Loc.T("You take %d %s damage." % [dmg, data.DisplayName], "%d %s hasarı alıyorsun." % [dmg, data.DisplayName]))

func DecayDefenseBonuses() -> void:
	playerDefenseBonus = maxi(0, playerDefenseBonus - defenseDecayPerTurn)
	enemyDefenseBonus = maxi(0, enemyDefenseBonus - defenseDecayPerTurn)

func Attack() -> void:
	DealDamageToPlayer(int(currentEnemy.attack))

func Defend() -> void:
	var b := maxi(15, U.RoundToInt(int(currentEnemy.defense) * 1.2))
	enemyDefenseBonus = clampi(enemyDefenseBonus + b, 0, maxDefenseBonus)
	Log(Loc.T("%s defends! (+%d | Total: %d)" % [currentEnemy.DisplayName, b, GetEnemyTotalDefense()], "%s savunuyor! (+%d | Toplam: %d)" % [currentEnemy.DisplayName, b, GetEnemyTotalDefense()]))

func SpecialAttack() -> void:
	DealDamageToPlayer(U.RoundToInt(int(currentEnemy.attack) * 1.5))
	Log(Loc.T("%s uses a special attack!" % currentEnemy.DisplayName, "%s özel bir saldırı kullanıyor!" % currentEnemy.DisplayName))

func DealDamageToPlayer(base_dmg: int) -> void:
	var dmg := CalculateEnemyDamageToPlayer(base_dmg, playerDefenseBonus + PS.Get(StatType.Defense))
	PS.Modify(StatType.Health, -dmg, false)
	Log(Loc.T("%s deals %d damage." % [currentEnemy.DisplayName, dmg], "%s, %d hasar veriyor." % [currentEnemy.DisplayName, dmg]))

func CalculateEnemyDamageToPlayer(base_dmg: int, defense: int) -> int:
	var red := 0.0
	if PlayerBuffs != null:
		red = PlayerBuffs.GetDamageReduction()
	if PlayerEffects != null:
		red = clampf(red + PlayerEffects.GetDamageReduction(), 0.0, 1.0)
	var fx = _enemy_fx()
	if fx != null:
		base_dmg = U.RoundToInt(base_dmg * fx.GetDamageMultiplier())
	var diff := 1.0
	if SettingsManager.Instance != null:
		match int(SettingsManager.Instance.GetDifficulty()):
			0:
				diff = 0.7
			1:
				diff = 1.0
			2:
				diff = 1.3
			_:
				diff = 1.6
	var dmg := CalculateFinalDamage(base_dmg, defense, false, 0.0, diff)
	return U.RoundToInt(dmg * (1.0 - red))

func CalculateFinalDamage(base_dmg: int, defense: int, ignore := false, pen := 0.0, mult := 1.0) -> int:
	if ignore:
		return maxi(1, U.RoundToInt(base_dmg * mult))
	var eff := defense * (1.0 - pen)
	var red := clampf(eff / (eff + defenseSoftcap), 0.0, maxDamageReduction)
	return maxi(1, U.RoundToInt(base_dmg * (1.0 - red) * mult))

func OnPlayerHealthChanged() -> void:
	if not inCombat or combatResolved:
		return
	if not PS.IsAlive():
		ResolveCombat(false)

func ResolveCombat(victory: bool) -> void:
	if combatResolved:
		return
	if victory and (PS == null or not PS.IsAlive()):
		victory = false
	combatResolved = true
	if victory:
		HandleVictoryAfterDelay(turnDelay)
	else:
		HandleDefeatAfterDelay(turnDelay)

func HandleFleeAfterDelay(delay: float) -> void:
	var g := _flee_gen
	OnCombatFled.emit()
	OnCombatEnded.emit()
	await U.wait(delay)
	if g != _flee_gen and inCombat:
		return
	EndCombatInternal()

func HandleVictoryAfterDelay(delay: float) -> void:
	Log(Loc.T("Defeated %s!" % currentEnemy.DisplayName, "%s yenildi!" % currentEnemy.DisplayName))
	await U.wait(delay)
	if ProfileManager.Instance != null:
		ProfileManager.Instance.AddExperience(int(currentEnemy.experienceReward))
		ProfileManager.Instance.AddCurrency(int(currentEnemy.currencyReward))
		Log("Gained %d XP and %d Gold." % [int(currentEnemy.experienceReward), int(currentEnemy.currencyReward)])
	DropEnemyLoot()
	var defeated = currentEnemy
	OnCombatVictory.emit(defeated)
	OnCombatEnded.emit()
	await U.wait(2.0)
	EndCombatInternal()

func HandleDefeatAfterDelay(delay: float) -> void:
	await U.wait(delay)
	Log("You have been defeated and lost some gold.")
	if CurrencyManager.Instance != null:
		var g: int = CurrencyManager.Instance.Get(CurrencyType.Gold)
		CurrencyManager.Instance.Spend(CurrencyType.Gold, mini(g / 4, 50))
	var gold: int = CurrencyManager.Instance.Get(CurrencyType.Gold) if CurrencyManager.Instance != null else 0
	Log("Remaining gold: %d" % gold)
	OnCombatDefeat.emit()
	OnCombatEnded.emit()
	await U.wait(2.0)
	EndCombatInternal()

func EndCombatInternal() -> void:
	inCombat = false
	combatResolved = false
	UnsubscribeFromEnemyEvents()
	if PlayerBuffs != null:
		PlayerBuffs.NotifyCombatEnded()
	var fx = _enemy_fx()
	if fx != null:
		fx.RemoveAllEffects()
	if PlayerEffects != null:
		PlayerEffects.RemoveAllEffects()
	currentEnemy = null
	playerDefenseBonus = 0
	enemyDefenseBonus = 0
	isPlayerTurn = true
	waitingForInput = true
	PS.enableHealthRegen = true
	PS.enableEnergyRegen = true
	var mx: int = PS.Get(StatType.MaxEnergy)
	var cur: int = PS.Get(StatType.Energy)
	var floor_e := U.RoundToInt(mx * combatEndEnergyFloorPercent)
	if cur < floor_e:
		PS.Modify(StatType.Energy, floor_e - cur)
	if not PS.IsAlive():
		PS.Set(StatType.Health, 1, true)
	OnCombatStateChanged.emit()
	if ProfileUI.Instance != null:
		ProfileUI.Instance.RefreshAll()
	SaveSystem.SaveGame()

func DropEnemyLoot() -> void:
	if enemyStats == null:
		return
	var loot = enemyStats.GetComponent(EnemyLoot)
	if loot == null:
		loot = enemyStats.GetComponentInChildren(EnemyLoot)
	if loot != null:
		loot.DropLoot(currentEnemy)

func RestorePlayerEnergy() -> void:
	PS.Modify(StatType.Energy, PS.Get(StatType.MaxEnergy) - PS.Get(StatType.Energy))

func GetAvailableActions() -> Array:
	return unlockedActions.duplicate()

func UnlockAction(a) -> void:
	if a != null and not unlockedActions.has(a):
		unlockedActions.append(a)

func DelayedCall(delay: float, f: Callable) -> void:
	await U.wait(delay)
	if inCombat and not combatResolved:
		f.call()

func Log(msg: String) -> void:
	OnCombatLog.emit(msg)
