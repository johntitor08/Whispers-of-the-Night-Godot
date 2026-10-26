class_name CombatMusicHook
extends Mono

var combatMusic
var _hooked := false

func Update() -> void:
	if _hooked or CombatManager.Instance == null:
		return
	U.on(CombatManager.Instance.OnCombatStarted, OnStart)
	U.on(CombatManager.Instance.OnCombatEnded, OnEnd)
	_hooked = true

func OnStart() -> void:
	if GameAudioManager.Instance != null and combatMusic != null:
		GameAudioManager.Instance.PlayMusic(combatMusic)

func OnEnd() -> void:
	var am = GameAudioManager.Instance
	if am == null:
		return
	var resume = am.currentAmbientMusic if am.currentAmbientMusic != null else am.defaultMusic
	if resume != null:
		am.PlayMusic(resume)

func OnDestroy() -> void:
	if CombatManager.Instance == null:
		return
	U.off(CombatManager.Instance.OnCombatStarted, OnStart)
	U.off(CombatManager.Instance.OnCombatEnded, OnEnd)
