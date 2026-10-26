class_name SceneMusic
extends Mono

var music
var ambience
var playOnEnable := false

func Start() -> void:
	Apply()

func OnEnable() -> void:
	if playOnEnable:
		Apply()

func Apply() -> void:
	if GameAudioManager.Instance == null:
		return
	if music != null:
		GameAudioManager.Instance.PlayMusic(music)
	if ambience != null:
		GameAudioManager.Instance.PlayAmbience(ambience)
