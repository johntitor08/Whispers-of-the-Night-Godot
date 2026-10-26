class_name PhaseMusicSwitcher
extends Mono

var eveningMusic
var nightMusic
var _hooked := false

func OnEnable() -> void:
	TryHook()

func Start() -> void:
	TryHook()
	Apply(CurrentPhase())

func OnDisable() -> void:
	if TimePhaseManager.Instance != null:
		U.off(TimePhaseManager.Instance.OnPhaseChanged, Apply)
	_hooked = false

func TryHook() -> void:
	if _hooked or TimePhaseManager.Instance == null:
		return
	U.on(TimePhaseManager.Instance.OnPhaseChanged, Apply)
	_hooked = true

func CurrentPhase() -> int:
	return TimePhaseManager.Instance.currentPhase if TimePhaseManager.Instance != null else TimePhase.Morning

func Apply(phase: int) -> void:
	var am = GameAudioManager.Instance
	if am == null:
		return
	var target = am.defaultMusic
	if phase == TimePhase.Night and nightMusic != null:
		target = nightMusic
	elif phase == TimePhase.Evening and eveningMusic != null:
		target = eveningMusic
	am.currentAmbientMusic = target
	var inCombat: bool = CombatManager.Instance != null and CombatManager.Instance.inCombat
	if not inCombat:
		am.PlayMusic(target)
