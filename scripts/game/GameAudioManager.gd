class_name GameAudioManager
extends Mono

static var Instance: GameAudioManager
const PP_MASTER := "audio_master"
const PP_MUSIC := "audio_music"
const PP_AMB := "audio_amb"
const PP_SFX := "audio_sfx"
var _musicFade := false
var _fade_gen := 0
var _pendingMusic
var musicSource
var ambienceSource
var sfxSource
var defaultMusic
var currentAmbientMusic
var defaultAmbience
var uiClick
var uiBack
var pageTurn
var masterVolume := 1.0
var musicVolume := 0.7
var ambienceVolume := 0.6
var sfxVolume := 1.0
var crossfadeDuration := 1.2

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self
	EnsureSources()
	LoadVolumes()
	ApplyVolumes()

func Start() -> void:
	if currentAmbientMusic == null:
		currentAmbientMusic = defaultMusic
	if defaultMusic != null:
		PlayMusic(defaultMusic)
	if defaultAmbience != null:
		PlayAmbience(defaultAmbience)

func EnsureSources() -> void:
	if musicSource == null:
		musicSource = CreateSource(true)
	if ambienceSource == null:
		ambienceSource = CreateSource(true)
	if sfxSource == null:
		sfxSource = CreateSource(false)

func CreateSource(loop: bool):
	var s = AddComponent(UAudioSource)
	s.loop = loop
	s.playOnAwake = false
	return s

func PlayMusic(clip, restartIfSame := false) -> void:
	if clip == null:
		return
	var effective = _pendingMusic if _musicFade else musicSource.clip
	if not restartIfSame and effective == clip and (musicSource.isPlaying or _musicFade):
		return
	_fade_gen += 1
	_pendingMusic = clip
	_musicFade = true
	CrossfadeMusic(clip, _fade_gen)

func CrossfadeMusic(clip, g: int) -> void:
	var dur := maxf(0.01, crossfadeDuration)
	var t := 0.0
	var startVol: float = musicSource.volume
	if musicSource.isPlaying:
		while t < dur:
			t += U.unscaledDeltaTime
			musicSource.volume = lerpf(startVol, 0.0, t / dur)
			await U.frame()
			if g != _fade_gen or not is_inside_tree():
				return
	musicSource.clip = clip
	musicSource.Play()
	var target := musicVolume * masterVolume
	t = 0.0
	while t < dur:
		t += U.unscaledDeltaTime
		musicSource.volume = lerpf(0.0, target, t / dur)
		await U.frame()
		if g != _fade_gen or not is_inside_tree():
			return
	musicSource.volume = target
	_musicFade = false
	_pendingMusic = null

func StopMusic() -> void:
	_fade_gen += 1
	_musicFade = false
	musicSource.Stop()

func PlayAmbience(clip) -> void:
	if clip == null or (ambienceSource.clip == clip and ambienceSource.isPlaying):
		return
	ambienceSource.clip = clip
	ambienceSource.volume = ambienceVolume * masterVolume
	ambienceSource.Play()

func StopAmbience() -> void:
	ambienceSource.Stop()

func PlaySfx(clip, volumeScale := 1.0) -> void:
	if clip == null:
		return
	sfxSource.PlayOneShot(clip, clampf(sfxVolume * masterVolume, 0.0, 1.0) * volumeScale)

func PlayUiClick() -> void:
	PlaySfx(uiClick)

func PlayUiBack() -> void:
	PlaySfx(uiBack)

func PlayPageTurn() -> void:
	PlaySfx(pageTurn)

func SetMasterVolume(v: float) -> void:
	masterVolume = clampf(v, 0.0, 1.0)
	ApplyVolumes()
	Save()

func SetMusicVolume(v: float) -> void:
	musicVolume = clampf(v, 0.0, 1.0)
	ApplyVolumes()
	Save()

func SetAmbienceVolume(v: float) -> void:
	ambienceVolume = clampf(v, 0.0, 1.0)
	ApplyVolumes()
	Save()

func SetSfxVolume(v: float) -> void:
	sfxVolume = clampf(v, 0.0, 1.0)
	Save()

func ApplyVolumes() -> void:
	if musicSource != null and not _musicFade:
		musicSource.volume = musicVolume * masterVolume
	if ambienceSource != null:
		ambienceSource.volume = ambienceVolume * masterVolume

func LoadVolumes() -> void:
	masterVolume = U.GetFloat(PP_MASTER, masterVolume)
	musicVolume = U.GetFloat(PP_MUSIC, musicVolume)
	ambienceVolume = U.GetFloat(PP_AMB, ambienceVolume)
	sfxVolume = U.GetFloat(PP_SFX, sfxVolume)

func Save() -> void:
	U.SetFloat(PP_MASTER, masterVolume)
	U.SetFloat(PP_MUSIC, musicVolume)
	U.SetFloat(PP_AMB, ambienceVolume)
	U.SetFloat(PP_SFX, sfxVolume)
	U.PrefsSave()
