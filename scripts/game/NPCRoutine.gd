class_name NPCRoutine
extends Mono

var dayForm
var eveningForm
var nightForm

func Start() -> void:
	if TimePhaseManager.Instance == null:
		return
	U.on(TimePhaseManager.Instance.OnPhaseChanged, Apply)
	Apply(TimePhaseManager.Instance.currentPhase)

func OnDestroy() -> void:
	if TimePhaseManager.Instance != null:
		U.off(TimePhaseManager.Instance.OnPhaseChanged, Apply)

func Apply(phase: int) -> void:
	if dayForm == null or eveningForm == null or nightForm == null:
		return
	U.SetActive(dayForm, false)
	U.SetActive(eveningForm, false)
	U.SetActive(nightForm, false)
	match phase:
		TimePhase.Morning, TimePhase.Noon:
			U.SetActive(dayForm, true)
		TimePhase.Evening:
			U.SetActive(eveningForm, true)
		TimePhase.Night:
			U.SetActive(nightForm, true)
