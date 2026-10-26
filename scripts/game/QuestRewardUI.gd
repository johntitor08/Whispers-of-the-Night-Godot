class_name QuestRewardUI
extends Mono

static var Instance: QuestRewardUI
var _close_gen := 0
var rewardPanel
var titleText
var questNameText
var rewardsContainer
var rewardItemPrefab
var closeButton
var optionalRewardsContainer
var optionalRewardsLabel
var rewardsScrollRect
var optionalRewardsScrollRect
var maxRewardsHeight := 300.0
var displayDuration := 5.0
var completionTitle := "Quest Complete!"

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self
	if rewardPanel != null:
		U.SetActive(rewardPanel, false)

func Start() -> void:
	if closeButton != null:
		closeButton.onClick.AddListener(Close)

func OnDestroy() -> void:
	if Instance == self:
		Instance = null

func ShowRewards(q, sel = null) -> void:
	if q == null or rewardItemPrefab == null:
		return
	_close_gen += 1
	if rewardPanel != null:
		U.SetActive(rewardPanel, true)
	if questNameText != null:
		questNameText.text = q.DisplayName
	if titleText != null:
		titleText.text = Loc.T(completionTitle, "Görev Tamamlandı!")
	ClearContainer(rewardsContainer)
	if int(q.experienceReward) > 0:
		SpawnRewardItem(rewardsContainer, Loc.T("Experience", "Deneyim"), str(int(q.experienceReward)), null)
	if q.currencyRewards != null:
		for r in q.currencyRewards:
			var info = CurrencyManager.Instance.GetCurrencyInfo(int(r.type)) if CurrencyManager.Instance != null else null
			SpawnRewardItem(rewardsContainer, CurrencyType.name_of(int(r.type)), str(int(r.amount)), info.icon if info != null else null)
	if q.itemRewards != null:
		for i in q.itemRewards.size():
			var it = q.itemRewards[i]
			if it == null:
				continue
			var ql = q.itemRewardQuantities
			SpawnRewardItem(rewardsContainer, it.DisplayName, "x%d" % (int(ql[i]) if ql != null and i < ql.size() else 1), it.icon)
	var has_opt: bool = sel != null or (q.optionalRewards != null and q.optionalRewards.size() > 0)
	if optionalRewardsLabel != null:
		U.SetActive(optionalRewardsLabel, has_opt)
	ClearContainer(optionalRewardsContainer)
	if sel != null:
		SpawnRewardItem(optionalRewardsContainer, sel.DisplayName, "x1", sel.icon)
	elif q.optionalRewards != null and optionalRewardsContainer != null:
		for it in q.optionalRewards:
			if it != null:
				SpawnRewardItem(optionalRewardsContainer, it.DisplayName, "x1", it.icon)
	AutoClose(_close_gen)
	UpdateScrollsNextFrame()

func UpdateScrollsNextFrame() -> void:
	await U.frame()
	for pair in [[rewardsContainer, rewardsScrollRect], [optionalRewardsContainer, optionalRewardsScrollRect]]:
		var c = pair[0]
		var sr = pair[1]
		if sr == null or c == null:
			continue
		var needs: bool = c.size.y > maxRewardsHeight
		sr.horizontal = false
		sr.vertical = needs
		if not needs:
			sr.verticalScrollbar = null
		sr.verticalNormalizedPosition = 1.0

func ClearContainer(c) -> void:
	if c == null:
		return
	for k in U.kids(c):
		U.Destroy(k)

func SpawnRewardItem(c, label: String, value: String, icon) -> void:
	if c == null:
		return
	var ui = U.Instantiate(rewardItemPrefab, c)
	ui.Setup(label, value, icon)

func AutoClose(g: int) -> void:
	await U.wait(displayDuration)
	if g == _close_gen:
		Close()

func Close() -> void:
	_close_gen += 1
	if rewardPanel != null:
		U.SetActive(rewardPanel, false)
