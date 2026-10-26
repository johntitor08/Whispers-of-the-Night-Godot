class_name Typewriter
extends Mono

static var Instance: Typewriter
signal OnTypingComplete
var _gen := 0
var isTyping := false
var cachedText := ""
var cachedTextUI
var _audio
var speed := 0.03
var skipPunctuation := true
var punctuationDelay := 0.2
var typeSound
var typeSoundVolume := 0.3
var playSoundPerCharacter := true

var IsTyping: bool:
	get:
		return isTyping

var CurrentTarget:
	get:
		return cachedTextUI

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self
	_audio = AddComponent(UAudioSource)
	_audio.playOnAwake = false

func StartTyping(ui, text: String) -> void:
	_gen += 1
	cachedText = text
	cachedTextUI = ui
	_type(_gen)

func _type(g: int) -> void:
	var e := co()
	isTyping = true
	cachedTextUI.text = ""
	var acc := ""
	for ch in cachedText:
		if g != _gen or dead(e):
			return
		acc += ch
		cachedTextUI.text = acc
		if playSoundPerCharacter and typeSound != null and ch.strip_edges() != "":
			_audio.PlayOneShot(typeSound, typeSoundVolume)
		await U.wait(punctuationDelay if skipPunctuation and ch in [".", ",", "!", "?", ";", ":"] else speed)
	if g != _gen or dead(e):
		return
	isTyping = false
	OnTypingComplete.emit()

func Complete() -> void:
	if not isTyping:
		return
	_gen += 1
	cachedTextUI.text = cachedText
	isTyping = false
	OnTypingComplete.emit()
