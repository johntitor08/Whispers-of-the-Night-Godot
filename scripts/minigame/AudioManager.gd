class_name AudioManager
extends Mono

static var Instance: AudioManager
var _src
var brushStroke
var eraserStroke
var fillSound
var undoSound
var saveSound
var masterVolume := 0.6

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance):
		Instance = self
	else:
		U.Destroy(gameObject)
		return
	_src = AddComponent(UAudioSource)
	_src.playOnAwake = false
	_src.volume = masterVolume

func Play(clip) -> void:
	if clip == null or _src == null:
		return
	_src.PlayOneShot(clip, masterVolume)

func PlayBrush() -> void:
	Play(brushStroke)

func PlayEraser() -> void:
	Play(eraserStroke)

func PlayFill() -> void:
	Play(fillSound)

func PlayUndo() -> void:
	Play(undoSound)

func PlaySave() -> void:
	Play(saveSound)
