class_name AshenveilVossWeakPoint
extends Mono

const SerenaBondBroken := "serena_bond_broken"
const VossKilled := "voss_killed"
const CourtLanternKnown := "court_lantern_known"
var vossData
var _subscribed := false

func OnEnable() -> void:
	SubscribeWhenReady()

func OnDisable() -> void:
	if _subscribed and CombatManager.Instance != null:
		U.off(CombatManager.Instance.OnCombatStarted, OnCombatStarted)
	_subscribed = false

func SubscribeWhenReady() -> void:
	var e := co()
	while CombatManager.Instance == null:
		await U.frame()
		if dead(e):
			return
	U.on(CombatManager.Instance.OnCombatStarted, OnCombatStarted)
	_subscribed = true

func OnCombatStarted() -> void:
	var cm = CombatManager.Instance
	if cm == null:
		return
	ApplyVossFateToVanguard()
	if cm.currentEnemy != vossData:
		return
	ApplySerenasThread()
	if not StoryFlags.Has(QuestFlags.VossWeakPointKnown):
		return
	var es = cm.enemyStats
	if es == null:
		return
	var cur: int = es.Get(StatType.Defense)
	es.Set(StatType.Defense, U.RoundToInt(cur * 0.5), false)
	StoryFlags.Add(QuestFlags.VossWeakPointApplied)
	if CombatUI.Instance != null:
		CombatUI.Instance.AddLogMessage(Loc.T("Voss's defenses are weakened...", "Voss'un savunması zayıf başlıyor..."))

func ApplySerenasThread() -> void:
	var sm = ScenarioManager.Instance
	var cur = sm.GetCurrentScenario() if sm != null else null
	if cur == null or cur.scenarioID != "ashenveil_day3" or StoryFlags.Has(SerenaBondBroken):
		return
	var st = CombatManager.Instance.enemyStats
	if st == null:
		return
	ScaleHealth(st, 1.25)
	st.Set(StatType.Strength, U.RoundToInt(st.Get(StatType.Strength) * 1.1), false)
	if CombatUI.Instance != null:
		CombatUI.Instance.AddLogMessage(Loc.T("Voss draws strength from Serena's thread...", "Voss, Serena'nın ipliğiyle güçleniyor..."))

func ApplyVossFateToVanguard() -> void:
	var sm = ScenarioManager.Instance
	var cur = sm.GetCurrentScenario() if sm != null else null
	if cur == null or cur.scenarioID != "ashenveil_day4" or cur.steps == null:
		return
	var idx: int = sm.GetCurrentStepIndex()
	if idx < 0 or idx >= cur.steps.size() or cur.steps[idx].stepName != "d4_vanguard":
		return
	var st = CombatManager.Instance.enemyStats
	if st == null:
		return
	if StoryFlags.Has(VossKilled):
		ScaleHealth(st, 1.2)
		st.Set(StatType.Strength, U.RoundToInt(st.Get(StatType.Strength) * 1.15), false)
		if CombatUI.Instance != null:
			CombatUI.Instance.AddLogMessage(Loc.T("The Court has sent its angriest for its dead clerk...", "Saray, öldürülen kâtibi için en öfkelilerini göndermiş..."))
	elif StoryFlags.Has(CourtLanternKnown):
		ScaleHealth(st, 0.85)
		st.Set(StatType.Defense, U.RoundToInt(st.Get(StatType.Defense) * 0.5), false)
		if CombatUI.Instance != null:
			CombatUI.Instance.AddLogMessage(Loc.T("You strike the lantern, as Voss told you. Their shadows thin...", "Voss'un dediği gibi fenere vuruyorsun; gölgeleri inceliyor..."))

static func ScaleHealth(st, f: float) -> void:
	var hp := maxi(1, U.RoundToInt(st.Get(StatType.MaxHealth) * f))
	for s in st.stats:
		if s.type == StatType.MaxHealth or s.type == StatType.Health:
			s.maxValue = maxi(s.maxValue, hp)
	st.Set(StatType.MaxHealth, hp, false)
	st.Set(StatType.Health, hp, false)
