class_name SettingsManager
extends Mono

static var Instance: SettingsManager
const QualityLevels := [1, 3, 5]
const MaxFrameRateWithoutVSync := 144
var resolutions: Array = []
var _snapMaster := 1.0
var _snapMusic := 0.8
var _snapSfx := 1.0
var _snapDiff := 1.0
var _snapQuality := 2
var _snapLang := 0
var _qualityLevel := 5
var settingsPanel
var savePanel
var masterVolumeSlider
var musicVolumeSlider
var sfxVolumeSlider
var masterVolumeText
var musicVolumeText
var sfxVolumeText
var qualityDropdown
var resolutionDropdown
var fullscreenToggle
var vsyncToggle
var difficultySlider
var difficultyText
var subtitlesToggle
var autosaveToggle
var languageDropdown
var savePanelButton
var applyButton
var resetButton
var closeButton
var mainMenuButton
var quitButton

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)

func Start() -> void:
	SetupDropdowns()
	LoadSettings()
	BindListeners()
	LanguageManager.OnLanguageChanged.AddListener(OnGameLanguageChanged)

func OnDestroy() -> void:
	LanguageManager.OnLanguageChanged.RemoveListener(OnGameLanguageChanged)

func OnGameLanguageChanged(_l) -> void:
	RefreshQualityOptions()
	if difficultySlider != null:
		OnDifficultyChanged(difficultySlider.value)

func OnOpenFromMenu() -> void:
	BindCloseButton()

func BindCloseButton() -> void:
	if closeButton == null:
		return
	closeButton.onClick.RemoveAllListeners()
	if MainMenuManager.Instance != null and is_instance_valid(MainMenuManager.Instance):
		closeButton.onClick.AddListener(MainMenuManager.Instance.OnSettingsClose)
	elif GameMenuManager.Instance != null and is_instance_valid(GameMenuManager.Instance):
		closeButton.onClick.AddListener(GameMenuManager.Instance.OnSettingsClose)

static func Fit(w: int, h: int) -> Vector2i:
	var fw := mini(w, U.RoundToInt(h * 16.0 / 9.0))
	return Vector2i(fw, U.RoundToInt(fw * 9.0 / 16.0))

func SetupDropdowns() -> void:
	if languageDropdown != null:
		languageDropdown.ClearOptions()
		languageDropdown.AddOptions(["English", "Türkçe"])
		languageDropdown.SetValueWithoutNotify(LanguageManager.Current)
		languageDropdown.RefreshShownValue()
	RefreshQualityOptions()
	if resolutionDropdown != null:
		var screen := DisplayServer.screen_get_size()
		var cands := [Vector2i(1280, 720), Vector2i(1366, 768), Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(3840, 2160), screen]
		var seen := {}
		var filtered := []
		for r in cands:
			if r.x > screen.x or r.y > screen.y:
				continue
			var f := Fit(r.x, r.y)
			if not seen.has(f):
				seen[f] = true
				filtered.append(f)
		filtered.sort_custom(func(a, b): return a.x < b.x if a.x != b.x else a.y < b.y)
		var cur := DisplayServer.window_get_size()
		var opts := []
		var idx := 0
		var best := 1 << 30
		for i in filtered.size():
			var r: Vector2i = filtered[i]
			opts.append("%d x %d" % [r.x, r.y])
			var dd: int = absi(r.x - cur.x) + absi(r.y - cur.y)
			if dd < best:
				best = dd
				idx = i
		resolutions = filtered
		resolutionDropdown.ClearOptions()
		resolutionDropdown.AddOptions(opts)
		resolutionDropdown.SetValueWithoutNotify(idx)
		resolutionDropdown.RefreshShownValue()

func BindListeners() -> void:
	for pair in [[masterVolumeSlider, OnMasterVolumeChanged], [musicVolumeSlider, OnMusicVolumeChanged], [sfxVolumeSlider, OnSFXVolumeChanged], [qualityDropdown, OnQualityChanged], [languageDropdown, OnLanguageChanged]]:
		if pair[0] != null:
			pair[0].onValueChanged.RemoveAllListeners()
			pair[0].onValueChanged.AddListener(pair[1])
	if difficultySlider != null:
		difficultySlider.minValue = 0
		difficultySlider.maxValue = 3
		difficultySlider.wholeNumbers = true
		difficultySlider.onValueChanged.RemoveAllListeners()
		difficultySlider.onValueChanged.AddListener(OnDifficultyChanged)
	for pair in [[savePanelButton, OpenSavePanel], [applyButton, ApplySettings], [resetButton, ResetSettings], [closeButton, ClosePanel], [mainMenuButton, func(): if GameMenuManager.Instance != null: GameMenuManager.Instance.OnMainMenuClicked()], [quitButton, func(): if GameMenuManager.Instance != null: GameMenuManager.Instance.OnQuitClicked()]]:
		if pair[0] != null:
			pair[0].onClick.RemoveAllListeners()
			pair[0].onClick.AddListener(pair[1])

func _pct(v: float) -> String:
	return str(int(round(v * 100))) + "%"

func OnMasterVolumeChanged(v) -> void:
	if GameAudioManager.Instance != null:
		GameAudioManager.Instance.SetMasterVolume(float(v))
	if masterVolumeText != null:
		masterVolumeText.text = _pct(float(v))

func OnMusicVolumeChanged(v) -> void:
	if GameAudioManager.Instance != null:
		GameAudioManager.Instance.SetMusicVolume(float(v))
	if musicVolumeText != null:
		musicVolumeText.text = _pct(float(v))

func OnSFXVolumeChanged(v) -> void:
	if GameAudioManager.Instance != null:
		GameAudioManager.Instance.SetSfxVolume(float(v))
	if sfxVolumeText != null:
		sfxVolumeText.text = _pct(float(v))

func RefreshQualityOptions() -> void:
	if qualityDropdown == null:
		return
	var cur: int = qualityDropdown.value
	qualityDropdown.ClearOptions()
	qualityDropdown.AddOptions([Loc.T("Low", "Düşük"), Loc.T("Medium", "Orta"), Loc.T("High", "Yüksek")])
	qualityDropdown.SetValueWithoutNotify(clampi(cur, 0, QualityLevels.size() - 1))
	qualityDropdown.RefreshShownValue()

static func QualityOptionFor(level: int) -> int:
	var o := 0
	for i in QualityLevels.size():
		if QualityLevels[i] <= level:
			o = i
	return o

func ApplyQualityOption(o: int) -> void:
	_qualityLevel = QualityLevels[clampi(o, 0, QualityLevels.size() - 1)]
	var vp := get_viewport()
	if vp != null:
		vp.msaa_2d = Viewport.MSAA_DISABLED if _qualityLevel <= 1 else (Viewport.MSAA_2X if _qualityLevel <= 3 else Viewport.MSAA_4X)
	ApplyVSync(vsyncToggle.isOn if vsyncToggle != null else DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED)

static func ApplyVSync(on: bool) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if on else DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0 if on else MaxFrameRateWithoutVSync

func OnQualityChanged(i) -> void:
	ApplyQualityOption(int(i))

func OnLanguageChanged(i) -> void:
	LanguageManager.SetLanguage(GameLanguage.EN if int(i) == 0 else GameLanguage.TR)

func OnDifficultyChanged(v) -> void:
	if difficultyText == null:
		return
	match U.RoundToInt(float(v)):
		0:
			difficultyText.text = Loc.T("Easy", "Kolay")
		1:
			difficultyText.text = Loc.T("Normal", "Normal")
		2:
			difficultyText.text = Loc.T("Hard", "Zor")
		_:
			difficultyText.text = Loc.T("Nightmare", "Kâbus")

func OpenSavePanel() -> void:
	if settingsPanel != null and savePanel != null:
		U.SetActive(settingsPanel, false)
		U.SetActive(savePanel, true)

static func _is_fullscreen() -> bool:
	var m := DisplayServer.window_get_mode()
	return m == DisplayServer.WINDOW_MODE_FULLSCREEN or m == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func ApplySettings() -> void:
	var fs: bool = fullscreenToggle.isOn if fullscreenToggle != null else _is_fullscreen()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fs else DisplayServer.WINDOW_MODE_WINDOWED)
	if not fs and resolutionDropdown != null and not resolutions.is_empty():
		var r: Vector2i = resolutions[clampi(resolutionDropdown.value, 0, resolutions.size() - 1)]
		DisplayServer.window_set_size(r)
		var scr := DisplayServer.screen_get_size()
		DisplayServer.window_set_position((scr - r) / 2)
	if vsyncToggle != null:
		ApplyVSync(vsyncToggle.isOn)
	SaveSettings()
	CaptureSnapshot()

func CaptureSnapshot() -> void:
	_snapMaster = masterVolumeSlider.value if masterVolumeSlider != null else 1.0
	_snapMusic = musicVolumeSlider.value if musicVolumeSlider != null else 0.8
	_snapSfx = sfxVolumeSlider.value if sfxVolumeSlider != null else 1.0
	_snapDiff = difficultySlider.value if difficultySlider != null else 1.0
	_snapQuality = qualityDropdown.value if qualityDropdown != null else QualityOptionFor(_qualityLevel)
	_snapLang = languageDropdown.value if languageDropdown != null else LanguageManager.Current

func RestoreSnapshot() -> void:
	if masterVolumeSlider != null:
		masterVolumeSlider.value = _snapMaster
	if musicVolumeSlider != null:
		musicVolumeSlider.value = _snapMusic
	if sfxVolumeSlider != null:
		sfxVolumeSlider.value = _snapSfx
	if difficultySlider != null:
		difficultySlider.value = _snapDiff
	if qualityDropdown != null:
		qualityDropdown.SetValueWithoutNotify(_snapQuality)
		qualityDropdown.RefreshShownValue()
		ApplyQualityOption(_snapQuality)
	if languageDropdown != null:
		languageDropdown.value = _snapLang
		LanguageManager.SetLanguage(GameLanguage.EN if _snapLang == 0 else GameLanguage.TR)

func ResetSettings() -> void:
	if masterVolumeSlider != null:
		masterVolumeSlider.value = 1.0
	if musicVolumeSlider != null:
		musicVolumeSlider.value = 0.8
	if sfxVolumeSlider != null:
		sfxVolumeSlider.value = 1.0
	if qualityDropdown != null:
		qualityDropdown.value = QualityLevels.size() - 1
	if fullscreenToggle != null:
		fullscreenToggle.isOn = true
	if vsyncToggle != null:
		vsyncToggle.isOn = true
	if difficultySlider != null:
		difficultySlider.value = 1.0
	if subtitlesToggle != null:
		subtitlesToggle.isOn = true
	if autosaveToggle != null:
		autosaveToggle.isOn = true
	ApplySettings()

func SaveSettings() -> void:
	U.SetFloat("Master", masterVolumeSlider.value if masterVolumeSlider != null else 1.0)
	U.SetFloat("Music", musicVolumeSlider.value if musicVolumeSlider != null else 0.8)
	U.SetFloat("SFX", sfxVolumeSlider.value if sfxVolumeSlider != null else 1.0)
	U.SetInt("QualityLevel", _qualityLevel)
	U.SetInt("Fullscreen", (1 if fullscreenToggle.isOn else 0) if fullscreenToggle != null else (1 if _is_fullscreen() else 0))
	U.SetInt("VSync", 1 if DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED else 0)
	U.SetFloat("Difficulty", difficultySlider.value if difficultySlider != null else 1.0)
	U.SetInt("Subtitles", 1 if subtitlesToggle != null and subtitlesToggle.isOn else 0)
	U.SetInt("Autosave", 1 if autosaveToggle != null and autosaveToggle.isOn else 0)
	if resolutionDropdown != null and not resolutions.is_empty():
		var r: Vector2i = resolutions[clampi(resolutionDropdown.value, 0, resolutions.size() - 1)]
		U.SetInt("ResW", r.x)
		U.SetInt("ResH", r.y)
	U.PrefsSave()

func LoadSettings() -> void:
	var mv := U.GetFloat("Master", 1.0)
	var mu := U.GetFloat("Music", 0.8)
	var sf := U.GetFloat("SFX", 1.0)
	var df := U.GetFloat("Difficulty", 1.0)
	if masterVolumeSlider != null:
		masterVolumeSlider.value = mv
	if musicVolumeSlider != null:
		musicVolumeSlider.value = mu
	if sfxVolumeSlider != null:
		sfxVolumeSlider.value = sf
	if difficultySlider != null:
		difficultySlider.value = df
	if GameAudioManager.Instance != null:
		GameAudioManager.Instance.SetMasterVolume(mv)
		GameAudioManager.Instance.SetMusicVolume(mu)
		GameAudioManager.Instance.SetSfxVolume(sf)
	if masterVolumeText != null:
		masterVolumeText.text = _pct(mv)
	if musicVolumeText != null:
		musicVolumeText.text = _pct(mu)
	if sfxVolumeText != null:
		sfxVolumeText.text = _pct(sf)
	if difficultySlider != null:
		OnDifficultyChanged(df)
	if vsyncToggle != null:
		vsyncToggle.SetIsOnWithoutNotify(U.GetInt("VSync", 1) > 0)
	var q := QualityOptionFor(U.GetInt("QualityLevel", 5))
	if qualityDropdown != null:
		qualityDropdown.SetValueWithoutNotify(q)
		qualityDropdown.RefreshShownValue()
	ApplyQualityOption(q)
	if languageDropdown != null:
		languageDropdown.SetValueWithoutNotify(LanguageManager.Current)
	if fullscreenToggle != null:
		fullscreenToggle.SetIsOnWithoutNotify(_is_fullscreen())
	if subtitlesToggle != null:
		subtitlesToggle.isOn = U.GetInt("Subtitles", 1) == 1
	if autosaveToggle != null:
		autosaveToggle.isOn = U.GetInt("Autosave", 1) == 1

func ClosePanel() -> void:
	UIPanelAnimator.Hide(settingsPanel)

func IsAutosaveEnabled() -> bool:
	return autosaveToggle != null and autosaveToggle.isOn

func IsSubtitlesEnabled() -> bool:
	return subtitlesToggle != null and subtitlesToggle.isOn

func GetDifficulty() -> float:
	return difficultySlider.value if difficultySlider != null else 1.0
