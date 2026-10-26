class_name PanelMusic
extends Mono

var music

func OnEnable() -> void:
	if GameAudioManager.Instance != null and music != null:
		GameAudioManager.Instance.PlayMusic(music)

func OnDisable() -> void:
	var am = GameAudioManager.Instance
	if am != null and is_instance_valid(am) and am.defaultMusic != null:
		am.PlayMusic(am.defaultMusic)
