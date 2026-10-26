class_name FusionUI
extends Mono

static var Instance: FusionUI
var selectedA
var selectedB
var slotA
var slotB
var iconA
var iconB
var nameA
var nameB
var resultIcon
var resultName
var successChanceText
var fuseButton
var statusText

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func OnEnable() -> void:
	if fuseButton != null:
		fuseButton.onClick.RemoveAllListeners()
		fuseButton.onClick.AddListener(OnFuseClicked)
	ClearAll()

func SelectItem(eq) -> void:
	if eq == null:
		return
	if selectedA == null:
		selectedA = eq
	elif selectedB == null:
		selectedB = eq
	else:
		selectedA = selectedB
		selectedB = eq
	RefreshSlots()
	RefreshPreview()

func RefreshSlots() -> void:
	SetSlot(iconA, nameA, selectedA)
	SetSlot(iconB, nameB, selectedB)

func SetSlot(icon, label, eq) -> void:
	if icon == null or label == null:
		return
	if eq != null:
		icon.sprite = eq.icon
		icon.enabled = true
		label.text = eq.DisplayName
	else:
		icon.enabled = false
		label.text = "—"

func RefreshPreview() -> void:
	if resultIcon == null:
		return
	if selectedA == null or selectedB == null:
		resultIcon.enabled = false
		resultName.text = ""
		successChanceText.text = ""
		fuseButton.interactable = false
		return
	var r = FusionManager.Instance.FindRecipe(selectedA, selectedB)
	if r != null:
		resultIcon.sprite = r.result.icon
		resultIcon.enabled = true
		resultName.text = r.result.DisplayName
		successChanceText.text = "%s: %d%%" % [Loc.T("Success", "Başarı"), roundi(float(r.successChance) * 100)]
		fuseButton.interactable = FusionManager.Instance.CanFuse(selectedA, selectedB)
		statusText.text = ""
	else:
		resultIcon.enabled = false
		resultName.text = Loc.T("No recipe found", "Tarif bulunamadı")
		successChanceText.text = ""
		fuseButton.interactable = false

func OnFuseClicked() -> void:
	if selectedA == null or selectedB == null or FusionManager.Instance == null:
		statusText.text = Loc.T("Select two items to fuse.", "Birleştirmek için iki eşya seç.")
		return
	var res = FusionManager.Instance.Fuse(selectedA, selectedB)
	ClearAll()
	statusText.text = ("%s: %s!" % [Loc.T("Created", "Oluşturuldu"), res.DisplayName]) if res != null else Loc.T("Fusion failed — items were lost.", "Birleştirme başarısız — eşyalar kayboldu.")

func ClearAll() -> void:
	selectedA = null
	selectedB = null
	RefreshSlots()
	RefreshPreview()
