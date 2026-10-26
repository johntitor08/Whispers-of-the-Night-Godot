class_name QuestObjectiveUI
extends Mono

var descriptionText
var progressText
var progressBar
var checkmarkIcon

func Setup(o, st) -> void:
	if descriptionText != null:
		descriptionText.text = QuestData.ObjDesc(o)
	UpdateProgress(o, st)

func UpdateProgress(o, st) -> void:
	var req := QuestData.ObjRequired(o)
	if progressText != null:
		progressText.text = "%d/%d" % [int(st.currentProgress), req]
	if progressBar != null:
		progressBar.value = 1.0 if req == 0 else clampf(float(st.currentProgress) / req, 0.0, 1.0)
	if checkmarkIcon != null:
		U.SetActive(checkmarkIcon, bool(st.isCompleted))
