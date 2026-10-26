class_name GuideUI
extends Mono

static var Instance: GuideUI
var _current := GuideCategory.Book
var _spawned: Array = []
var _entryStyles: Dictionary = {}
var panel
var closeButton
var booksTab
var charactersTab
var loreTab
var listContent
var listFont
var detailTitle
var detailBody
var detailIcon
var theme
var goldColor := Color(0.784, 0.659, 0.431)

var ThemeRef:
	get:
		if theme != null:
			return theme
		if booksTab != null:
			var s = U.GetComponent(booksTab, UIButtonStyle)
			if s != null:
				return s.theme
		return null

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func Start() -> void:
	if closeButton != null:
		closeButton.onClick.RemoveAllListeners()
		closeButton.onClick.AddListener(Close)
	if booksTab != null:
		booksTab.onClick.RemoveAllListeners()
		booksTab.onClick.AddListener(Show.bind(GuideCategory.Book))
	if charactersTab != null:
		charactersTab.onClick.RemoveAllListeners()
		charactersTab.onClick.AddListener(Show.bind(GuideCategory.Character))
	if loreTab != null:
		loreTab.onClick.RemoveAllListeners()
		loreTab.onClick.AddListener(Show.bind(GuideCategory.Lore))
	if panel != null:
		U.SetActive(panel, false)

func Open() -> void:
	if panel != null and U.activeSelf(panel):
		Close()
		return
	if SceneEvent.Instance != null:
		SceneEvent.Instance.HideAllPanels()
	UIPanelAnimator.Show(panel)
	Show(GuideCategory.Book)

func Close() -> void:
	UIPanelAnimator.Hide(panel)

func Show(category: int) -> void:
	_current = category
	MarkTab(category)
	ClearList()
	ClearDetail()
	var all: Array = GuideManager.Instance.GetEntries(category) if GuideManager.Instance != null else []
	var list := []
	for e in all:
		if e.bookItem == null or HasItem(e.bookItem):
			list.append(e)
	for e in list:
		SpawnListButton(e)
	if list.size() > 0:
		ShowDetail(list[0])

static func HasItem(item) -> bool:
	return InventoryManager.Instance != null and InventoryManager.Instance.GetQuantity(item) > 0

func SpawnListButton(e) -> void:
	var go = U.NewGO(str(e.title), listContent, UImage, {"image": {"color": [1, 1, 1, 1], "raycastTarget": true}})
	var btn = U.AddComponent(go, UButton)
	btn.targetGraphic = go
	var le = U.AddComponent(go, ULayoutElement)
	le.minHeight = 56
	var lbl = U.NewGO("Label", go, UText, {"text": {"text": ""}})
	if listFont != null:
		lbl.font = listFont
	lbl.text = e.DisplayTitle
	lbl.alignment = 513
	lbl.margin = Vector4(18, 0, 8, 0)
	RT.set_anchor_min(lbl, Vector2.ZERO)
	RT.set_anchor_max(lbl, Vector2.ONE)
	RT.set_offset_min(lbl, Vector2.ZERO)
	RT.set_offset_max(lbl, Vector2.ZERO)
	var style = U.AddComponent(go, UIButtonStyle)
	style.theme = ThemeRef
	style.kind = UIButtonStyle.Kind.Compact
	style.labelFontSize = 26
	style.resizeToMetrics = false
	style.Apply()
	_entryStyles[e] = style
	btn.onClick.AddListener(Select.bind(e))
	_spawned.append(go)

func MarkTab(category: int) -> void:
	SetPrimary(booksTab, category == GuideCategory.Book)
	SetPrimary(charactersTab, category == GuideCategory.Character)
	SetPrimary(loreTab, category == GuideCategory.Lore)

func MarkEntry(selected) -> void:
	for k in _entryStyles:
		var st = _entryStyles[k]
		if is_instance_valid(st) and st.primary != (k == selected):
			st.primary = k == selected
			st.Apply()

static func SetPrimary(button, on: bool) -> void:
	if button == null:
		return
	var style = U.GetComponent(button, UIButtonStyle)
	if style != null and style.primary != on:
		style.primary = on
		style.Apply()

func Select(e) -> void:
	if int(e.category) == GuideCategory.Book and e.bookItem != null and ReadingPanel.Instance != null:
		Close()
		ReadingPanel.Instance.Show(e.bookItem.DisplayName, e.bookItem.DisplayReadText, e.bookItem.icon)
		return
	ShowDetail(e)

func ShowDetail(e) -> void:
	MarkEntry(e)
	if detailTitle != null:
		detailTitle.text = e.DisplayTitle
		detailTitle.color = goldColor
	if detailBody != null:
		var body: String = e.DisplayBody
		if int(e.category) == GuideCategory.Book:
			body += Loc.T("\n\n(Click to open and read.)", "\n\n(Açıp okumak için tıkla.)")
		elif int(e.category) == GuideCategory.Character and AffinityManager.Instance != null:
			var am = AffinityManager.Instance
			body += "\n\n%s: %s  %d/%d  (%s)" % [Loc.T("Affinity", "Yakınlık"), am.HeartBar(e.title), am.Get(e.title), am.maxAffinity, am.Tier(e.title)]
		detailBody.text = body
	if detailIcon != null:
		var sprite = e.bookItem.icon if e.bookItem != null and e.bookItem.icon != null else e.icon
		detailIcon.sprite = sprite
		detailIcon.enabled = sprite != null

func ClearList() -> void:
	for g in _spawned:
		if is_instance_valid(g):
			U.Destroy(g)
	_spawned.clear()
	_entryStyles.clear()

func ClearDetail() -> void:
	if detailTitle != null:
		detailTitle.text = ""
	if detailBody != null:
		detailBody.text = ""
	if detailIcon != null:
		detailIcon.enabled = false
