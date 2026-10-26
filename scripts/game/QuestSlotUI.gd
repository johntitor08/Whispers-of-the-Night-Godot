class_name QuestSlotUI
extends Mono

var questNameText
var questTypeText
var questIcon
var difficultyIcon
var detailsButton
var completedIndicator
var newIndicator
var fallbackQuestIcon
var quest

func Setup(q, done := false, is_new := false) -> void:
	quest = q
	if questNameText != null:
		questNameText.text = q.DisplayName
	if questTypeText != null:
		questTypeText.text = QuestData.TypeName(int(q.questType))
	if questIcon != null:
		questIcon.sprite = q.icon if q.icon != null else fallbackQuestIcon
		questIcon.preserveAspect = true
		questIcon.enabled = questIcon.sprite != null
	if completedIndicator != null:
		U.SetActive(completedIndicator, done)
	if newIndicator != null:
		U.SetActive(newIndicator, is_new)
	if difficultyIcon != null:
		difficultyIcon.color = GetDifficultyColor(int(q.difficulty))
	if detailsButton != null:
		detailsButton.onClick.RemoveAllListeners()
		detailsButton.onClick.AddListener(OnDetailsClicked)

func OnDetailsClicked() -> void:
	if QuestUI.Instance != null and quest != null:
		QuestUI.Instance.ShowQuestDetails(quest)

func GetDifficultyColor(d: int) -> Color:
	match d:
		QuestDifficulty.Easy:
			return UIPalette.Muted
		QuestDifficulty.Normal:
			return UIPalette.Cream
		QuestDifficulty.Hard:
			return UIPalette.Gold
		QuestDifficulty.Elite:
			return UIPalette.Legendary
		QuestDifficulty.Epic:
			return UIPalette.Epic
	return UIPalette.Cream
