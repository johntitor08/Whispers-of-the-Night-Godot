class_name ReadingPanel
extends Mono

static var Instance: ReadingPanel
var currentPage := 1
var pageCount := 1
var panel
var title
var body
var icon
var closeButton
var prevButton
var nextButton
var pageLabel

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func Start() -> void:
	for pair in [[prevButton, PrevPage], [nextButton, NextPage], [closeButton, Close]]:
		if pair[0] != null:
			pair[0].onClick.RemoveAllListeners()
			pair[0].onClick.AddListener(pair[1])
	if panel != null:
		U.SetActive(panel, false)

func Show(item_name: String, content, item_icon = null) -> void:
	if title != null:
		title.text = item_name
	if icon != null:
		icon.sprite = item_icon
		icon.enabled = item_icon != null
	if body != null:
		body.overflowMode = 5
		body.text = "" if content == null else str(content)
	UIPanelAnimator.Show(panel)
	InitPages()

func InitPages() -> void:
	await U.frame()
	await U.frame()
	RecomputePages()
	GoToPage(1)

func RecomputePages() -> void:
	if body == null:
		pageCount = 1
		return
	body.ForceMeshUpdate()
	pageCount = maxi(1, body.pageCount)

func NextPage() -> void:
	GoToPage(currentPage + 1)

func PrevPage() -> void:
	GoToPage(currentPage - 1)

func GoToPage(p: int) -> void:
	if body == null:
		return
	if pageCount <= 1:
		RecomputePages()
	currentPage = clampi(p, 1, pageCount)
	body.SetPage(currentPage)
	UpdateNav()

func UpdateNav() -> void:
	if pageLabel != null:
		pageLabel.text = "%d / %d" % [currentPage, pageCount]
	if prevButton != null:
		prevButton.interactable = currentPage > 1
	if nextButton != null:
		nextButton.interactable = currentPage < pageCount

func Close() -> void:
	UIPanelAnimator.Hide(panel)
