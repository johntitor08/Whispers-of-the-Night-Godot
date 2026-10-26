class_name SaveSlotUI
extends Mono

var slotIndex := 0
var slotLabel
var metaText
var saveButton
var loadButton
var deleteButton
var parentUI

func Initialize(index: int, parent) -> void:
	slotIndex = index
	parentUI = parent
	if saveButton != null:
		saveButton.onClick.AddListener(OnSave)
	if loadButton != null:
		loadButton.onClick.AddListener(OnLoad)
	if deleteButton != null:
		deleteButton.onClick.AddListener(OnDelete)
	Refresh()

func Refresh() -> void:
	var hasSave := SaveSystem.HasSaveFileSlot(slotIndex)
	if slotLabel != null:
		slotLabel.text = "%s %d" % [Loc.T("Slot", "Yuva"), slotIndex + 1]
	SetButton(loadButton, hasSave)
	SetButton(deleteButton, hasSave)
	if metaText != null:
		if hasSave:
			var data = SaveSystem.PeekSlot(slotIndex)
			metaText.text = BuildMeta(data) if data != null else Loc.T("Corrupted", "Bozuk")
		else:
			metaText.text = Loc.T("Empty", "Boş")

func BuildMeta(data) -> String:
	var phase := TimeUI.GetPhaseName(int(data.get("currentTimePhase", 0)))
	var day := "%s %d" % [Loc.T("Day", "Gün"), int(data.get("currentDay", 1))]
	var saved := str(data.get("savedAt", ""))
	var t := "" if saved.is_empty() else "\n" + saved
	return "%s · %s%s" % [day, phase, t]

func SetInteractable(v: bool) -> void:
	SetButton(saveButton, v)
	if v:
		Refresh()
	else:
		SetButton(loadButton, false)
		SetButton(deleteButton, false)

static func SetButton(button, v: bool) -> void:
	if button == null:
		return
	button.interactable = v
	var label = U.GetComponentInChildren(button, UText, true)
	if label != null:
		label.alpha = 1.0 if v else 0.35

func OnSave() -> void:
	if SaveSystem.IsLoading:
		return
	if parentUI != null:
		parentUI.SetAllSlotsInteractable(false)
	SaveSystem.SetActiveSlot(slotIndex)
	SaveSystem.SaveGameSlot(slotIndex)
	Refresh()
	if parentUI != null:
		parentUI.SetAllSlotsInteractable(true)
		parentUI.ShowToast(Loc.T("Game Saved!", "Oyun Kaydedildi!"))

func OnLoad() -> void:
	if not SaveSystem.HasSaveFileSlot(slotIndex):
		return
	SaveSystem.SetActiveSlot(slotIndex)
	SaveSystem.LoadGameSlot(slotIndex)

func OnDelete() -> void:
	SaveSystem.DeleteSaveSlot(slotIndex)
	Refresh()

func OnDestroy() -> void:
	if saveButton != null:
		saveButton.onClick.RemoveListener(OnSave)
	if loadButton != null:
		loadButton.onClick.RemoveListener(OnLoad)
	if deleteButton != null:
		deleteButton.onClick.RemoveListener(OnDelete)
