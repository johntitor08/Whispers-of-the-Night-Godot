class_name ProfileUI
extends Mono

static var Instance: ProfileUI
var statsSubscribed := false
var pendingStatIncreases := [0, 0, 0, 0, 0, 0]
var _originalTextScales: Dictionary = {}
var _pulse_gen: Dictionary = {}
var gameStarted := false
var profilePanel
var playerNameText
var levelText
var currencyText
var expText
var expBar
var statPointsText
var profileIcon
var healthBar
var healthText
var healthFillImage
var healthHighColor := Color.GREEN
var healthMediumColor := Color.YELLOW
var healthLowColor := Color.RED
var energyBar
var energyText
var energyFillImage
var energyColor := Color(0.3, 0.5, 1)
var strengthText
var intelligenceText
var charismaText
var defenseText
var speedText
var luckText
var powerScoreText
var strengthIncrementButton
var intelligenceIncrementButton
var charismaIncrementButton
var defenseIncrementButton
var speedIncrementButton
var luckIncrementButton
var strengthDecrementButton
var intelligenceDecrementButton
var charismaDecrementButton
var defenseDecrementButton
var speedDecrementButton
var luckDecrementButton
var incrementButtonDefault
var incrementButtonAvailable
var slot1
var slot1Icon
var slot2
var slot2Icon
var slot3
var slot3Icon
var slot4
var slot4Icon
var slot5
var slot5Icon
var slot6
var slot6Icon
var commonBorder
var rareBorder
var epicBorder
var legendaryBorder
var godlyBorder
var emptyBorder
var emptySlotColor := Color(0.160, 0.138, 0.120, 1)
var toggleKey := KEY_P
var iconDatabase

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func Update() -> void:
	if not gameStarted:
		return
	if U.GetKeyDown(toggleKey) and profilePanel != null:
		if profilePanel.visible:
			UIPanelAnimator.Hide(profilePanel)
		else:
			UIPanelAnimator.Show(profilePanel)
			RefreshAll()

func OnEnable() -> void:
	var pm = ProfileManager.Instance
	if pm != null:
		U.on(pm.OnProfileChanged, RefreshProfile)
		U.on(pm.OnCurrencyChanged, RefreshProfile)
	else:
		ProfileManager.OnReady.AddListener(OnProfileManagerReady)
	if EquipmentManager.Instance != null:
		U.on(EquipmentManager.Instance.OnEquipmentChanged, RefreshEquipmentSlots)
		U.on(EquipmentManager.Instance.OnEquipmentChanged, RefreshPowerScore)
	else:
		EquipmentManager.OnReady.AddListener(OnEquipmentManagerReady)
	SetupEquipmentSlots()
	if PlayerStats.Instance != null:
		SubscribeToStats()
	else:
		PlayerStats.OnReady.AddListener(SubscribeToStats)
	WireStatButtons()
	LanguageManager.OnLanguageChanged.AddListener(_lang)
	RefreshAll()

func _lang(_l) -> void:
	RefreshAll()

func OnDisable() -> void:
	LanguageManager.OnLanguageChanged.RemoveListener(_lang)
	var pm = ProfileManager.Instance
	if pm != null:
		U.off(pm.OnProfileChanged, RefreshProfile)
		U.off(pm.OnCurrencyChanged, RefreshProfile)
	ProfileManager.OnReady.RemoveListener(OnProfileManagerReady)
	if EquipmentManager.Instance != null:
		U.off(EquipmentManager.Instance.OnEquipmentChanged, RefreshEquipmentSlots)
		U.off(EquipmentManager.Instance.OnEquipmentChanged, RefreshPowerScore)
	EquipmentManager.OnReady.RemoveListener(OnEquipmentManagerReady)
	if statsSubscribed and PlayerStats.Instance != null:
		U.off(PlayerStats.Instance.OnHealthChanged, UpdateHealthBar)
		U.off(PlayerStats.Instance.OnEnergyChanged, UpdateEnergyBar)
		U.off(PlayerStats.Instance.OnStatChanged, OnStatChanged)
		statsSubscribed = false
	PlayerStats.OnReady.RemoveListener(SubscribeToStats)
	for k in _pulse_gen:
		_pulse_gen[k] += 1
	for k in _originalTextScales:
		var t = GetTextForStat(k)
		if t != null:
			t.scale = _originalTextScales[k]
	pendingStatIncreases = [0, 0, 0, 0, 0, 0]

func OnGameStarted() -> void:
	gameStarted = true

func SlotDefs() -> Array:
	return [[slot1, slot1Icon, EquipmentSlot.Weapon], [slot2, slot2Icon, EquipmentSlot.Armor], [slot3, slot3Icon, EquipmentSlot.Helmet], [slot4, slot4Icon, EquipmentSlot.Accessory], [slot5, slot5Icon, EquipmentSlot.Shield], [slot6, slot6Icon, EquipmentSlot.Boots]]

func SetupEquipmentSlots() -> void:
	for d in SlotDefs():
		if d[0] == null:
			continue
		var st: int = d[2]
		d[0].onClick.RemoveAllListeners()
		d[0].onClick.AddListener(func(): OnSlotClicked(st))
	RefreshEquipmentSlots()

func OnSlotClicked(st: int) -> void:
	if EquipmentManager.Instance == null or EquipmentInfoPanel.Instance == null:
		return
	var inst = EquipmentManager.Instance.GetEquipped(st)
	if inst != null:
		EquipmentInfoPanel.Instance.ShowPanel(inst)

func RefreshEquipmentSlots() -> void:
	if EquipmentManager.Instance == null:
		return
	for d in SlotDefs():
		var btn = d[0]
		if btn == null:
			continue
		var inst = EquipmentManager.Instance.GetEquipped(d[2])
		var filled: bool = inst != null
		var data = inst.baseData if filled else null
		if d[1] != null:
			d[1].sprite = data.icon if filled else null
			d[1].enabled = filled
		var well: Color = emptySlotColor.lerp(data.GetRarityColor(), 0.45) if filled else emptySlotColor
		var img = btn.gameObject
		if img is UImage:
			img.sprite = UISprites.Rounded(12)
			img.type = UImage.Type.SLICED
			img.color = well
		var ci = U.GetComponent(img, ClickableIcon)
		if filled:
			if ci == null:
				ci = U.AddComponent(img, ClickableIcon)
				ci.Awake()
			ci.SetBaseColor(well)
		elif ci != null:
			ci.SetBaseColor(well)
			U.Destroy(ci)
		btn.interactable = filled
	UpdateHealthBar()

func SubscribeToStats() -> void:
	if PlayerStats.Instance == null or statsSubscribed:
		return
	U.on(PlayerStats.Instance.OnHealthChanged, UpdateHealthBar)
	U.on(PlayerStats.Instance.OnEnergyChanged, UpdateEnergyBar)
	U.on(PlayerStats.Instance.OnStatChanged, OnStatChanged)
	statsSubscribed = true
	RefreshAll()

func OnProfileManagerReady() -> void:
	ProfileManager.OnReady.RemoveListener(OnProfileManagerReady)
	U.on(ProfileManager.Instance.OnProfileChanged, RefreshProfile)
	U.on(ProfileManager.Instance.OnCurrencyChanged, RefreshProfile)
	RefreshAll()

func OnEquipmentManagerReady() -> void:
	EquipmentManager.OnReady.RemoveListener(OnEquipmentManagerReady)
	U.on(EquipmentManager.Instance.OnEquipmentChanged, RefreshEquipmentSlots)
	U.on(EquipmentManager.Instance.OnEquipmentChanged, RefreshPowerScore)
	SetupEquipmentSlots()

func _incs() -> Array:
	return [strengthIncrementButton, intelligenceIncrementButton, charismaIncrementButton, defenseIncrementButton, speedIncrementButton, luckIncrementButton]

func _decs() -> Array:
	return [strengthDecrementButton, intelligenceDecrementButton, charismaDecrementButton, defenseDecrementButton, speedDecrementButton, luckDecrementButton]

const STAT_ORDER := [StatType.Strength, StatType.Intelligence, StatType.Charisma, StatType.Defense, StatType.Speed, StatType.Luck]

func WireStatButtons() -> void:
	var inc := _incs()
	var dec := _decs()
	for i in 6:
		var t: int = STAT_ORDER[i]
		var idx := i
		if inc[i] != null:
			inc[i].onClick.RemoveAllListeners()
			inc[i].onClick.AddListener(func(): IncrementStat(t, idx))
		if dec[i] != null:
			dec[i].onClick.RemoveAllListeners()
			dec[i].onClick.AddListener(func(): DecrementStat(t, idx))
	RefreshStatButtons()

func IncrementStat(t: int, i: int) -> void:
	if ProfileManager.Instance == null:
		return
	var p = ProfileManager.Instance.profile
	if p == null or p.statPoints <= 0 or PlayerStats.Instance == null:
		return
	PlayerStats.Instance.Modify(t, 1)
	p.statPoints -= 1
	pendingStatIncreases[i] += 1
	RefreshStatButtons()
	RefreshStatPointsText()
	SaveSystem.SaveGame()

func DecrementStat(t: int, i: int) -> void:
	if pendingStatIncreases[i] <= 0 or PlayerStats.Instance == null:
		return
	PlayerStats.Instance.Modify(t, -1)
	if ProfileManager.Instance != null:
		ProfileManager.Instance.profile.statPoints += 1
	pendingStatIncreases[i] -= 1
	RefreshStatButtons()
	RefreshStatPointsText()
	SaveSystem.SaveGame()

func RefreshStatButtons() -> void:
	if ProfileManager.Instance == null:
		return
	var p = ProfileManager.Instance.profile
	var can: bool = p != null and p.statPoints > 0
	for b in _incs():
		if b == null:
			continue
		b.interactable = can
		if incrementButtonDefault != null and b.gameObject is UImage:
			b.gameObject.sprite = incrementButtonAvailable if can and incrementButtonAvailable != null else incrementButtonDefault
	var dec := _decs()
	for i in 6:
		if dec[i] != null:
			dec[i].interactable = pendingStatIncreases[i] > 0

func RefreshAll() -> void:
	RefreshProfile()
	UpdateHealthBar()
	UpdateEnergyBar()
	RefreshAllStats()
	RefreshEquipmentSlots()
	RefreshPowerScore()

func RefreshProfile(p = null) -> void:
	if ProfileManager.Instance == null:
		return
	if p == null:
		p = ProfileManager.Instance.profile
	if p == null:
		return
	playerNameText.text = p.playerName
	levelText.text = "%s %d" % [Loc.T("Level", "Seviye"), p.level]
	var gold: int = CurrencyManager.Instance.Get(CurrencyType.Gold) if CurrencyManager.Instance != null else 0
	currencyText.text = "%d %s" % [gold, Loc.T("Gold", "Altın")]
	expBar.maxValue = maxi(1, p.experienceToNextLevel)
	expBar.value = clampi(p.experience, 0, p.experienceToNextLevel)
	expText.text = "%d / %d XP" % [p.experience, p.experienceToNextLevel]
	if profileIcon != null and iconDatabase != null:
		var ic = iconDatabase.GetIconSprite(p.profileIconID)
		if ic != null:
			profileIcon.sprite = ic
	RefreshStatPointsText()
	RefreshStatButtons()

func RefreshPowerScore() -> void:
	if powerScoreText == null or PlayerStats.Instance == null:
		return
	powerScoreText.text = "%s: %d" % [Loc.T("Power Score", "Güç Puanı"), int(PlayerStats.Instance.GetPowerScore())]

func RefreshStatPointsText() -> void:
	if statPointsText == null or ProfileManager.Instance == null:
		return
	var pts: int = ProfileManager.Instance.profile.statPoints if ProfileManager.Instance.profile != null else 0
	statPointsText.text = "%s: %d" % [Loc.T("Stat Points", "Yetenek Puanı"), pts]
	statPointsText.color = Color(0.95, 0.8, 0.45) if pts > 0 else UIPalette.Cream

func _stat_label(t: int) -> String:
	return DisplayNames.Stat(t)

func RefreshAllStats() -> void:
	if PlayerStats.Instance == null:
		return
	for t in STAT_ORDER:
		var lbl = GetTextForStat(t)
		if lbl != null:
			lbl.text = "%s: %d" % [_stat_label(t), PlayerStats.Instance.Get(t)]

func OnStatChanged(t: int, _o: int, _n: int) -> void:
	if PlayerStats.Instance == null:
		return
	var lbl = GetTextForStat(t)
	if lbl != null:
		lbl.text = "%s: %d" % [_stat_label(t), PlayerStats.Instance.Get(t)]
	if t == StatType.Health or t == StatType.Energy:
		return
	_pulse_gen[t] = _pulse_gen.get(t, 0) + 1
	PulseText(t, lbl, _pulse_gen[t])
	RefreshPowerScore()

func GetTextForStat(t: int):
	match t:
		StatType.Strength:
			return strengthText
		StatType.Intelligence:
			return intelligenceText
		StatType.Charisma:
			return charismaText
		StatType.Defense:
			return defenseText
		StatType.Speed:
			return speedText
		StatType.Luck:
			return luckText
	return null

func UpdateHealthBar() -> void:
	var ps = PlayerStats.Instance
	if ps == null:
		return
	var cur: int = ps.Get(StatType.Health)
	var mx: int = ps.Get(StatType.MaxHealth)
	var pct: float = ps.GetHealthPercentage()
	if healthBar != null:
		healthBar.maxValue = mx
		healthBar.value = cur
	if healthText != null:
		healthText.text = "%s: %d / %d" % [DisplayNames.Stat(StatType.Health), cur, mx]
	if healthFillImage != null:
		healthFillImage.color = healthHighColor if pct > 0.6 else (healthMediumColor if pct > 0.3 else healthLowColor)

func UpdateEnergyBar() -> void:
	var ps = PlayerStats.Instance
	if ps == null:
		return
	var cur: int = ps.Get(StatType.Energy)
	var mx: int = ps.Get(StatType.MaxEnergy)
	if energyBar != null:
		energyBar.maxValue = mx
		energyBar.value = cur
	if energyText != null:
		energyText.text = "%s: %d / %d" % [Loc.T("Energy", "Enerji"), cur, mx]
	if energyFillImage != null:
		energyFillImage.color = energyColor

func PulseText(t: int, lbl, g: int) -> void:
	if lbl == null:
		return
	if not _originalTextScales.has(t):
		_originalTextScales[t] = lbl.scale
	var orig: Vector2 = _originalTextScales[t]
	var target := orig * 1.2
	var e := 0.0
	while e < 0.2:
		if _pulse_gen.get(t) != g:
			return
		e += U.deltaTime
		lbl.scale = orig.lerp(target, clampf(e / 0.2, 0.0, 1.0))
		await U.frame()
	e = 0.0
	while e < 0.2:
		if _pulse_gen.get(t) != g:
			return
		e += U.deltaTime
		lbl.scale = target.lerp(orig, clampf(e / 0.2, 0.0, 1.0))
		await U.frame()
	lbl.scale = orig
