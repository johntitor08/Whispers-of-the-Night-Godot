class_name GameMenuManager
extends Mono

static var Instance: GameMenuManager
static var OnGamePaused := UEvent.new()
static var OnGameResumed := UEvent.new()
var _isPaused := false
var _isLoading := false
var _audio
var pauseMenu
var settingsMenu
var resumeButton
var settingsButton
var mainMenuButton
var quitButton
var loadingScreen
var loadingBar
var loadingText
var buttonClickSound
var menuOpenSound
var menuCloseSound
var mainMenuSceneName := "MainMenu"
var pauseKey := KEY_ESCAPE

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self
	_audio = AddComponent(UAudioSource)
	_audio.playOnAwake = false

func Start() -> void:
	SetupButtons()
	for p in [pauseMenu, settingsMenu, loadingScreen]:
		if p != null:
			U.SetActive(p, false)

func Update() -> void:
	if _isLoading:
		return
	if U.GetKeyDown(pauseKey):
		if not _isPaused and UIPanelManager.Instance != null and UIPanelManager.Instance.CloseOpenPanels():
			return
		if _isPaused:
			ResumeGame()
		else:
			PauseGame()

func SetupButtons() -> void:
	for pair in [[resumeButton, ResumeGame], [settingsButton, OnSettingsClicked], [mainMenuButton, OnMainMenuClicked], [quitButton, OnQuitClicked]]:
		if pair[0] != null:
			pair[0].onClick.RemoveAllListeners()
			pair[0].onClick.AddListener(pair[1])

func PauseGame() -> void:
	if _isPaused:
		return
	_isPaused = true
	U.timeScale = 0.0
	if pauseMenu != null:
		U.SetActive(pauseMenu, true)
	PlaySound(menuOpenSound)
	OnGamePaused.Invoke()

func ResumeGame() -> void:
	if not _isPaused:
		return
	_isPaused = false
	U.timeScale = 1.0
	if settingsMenu != null:
		U.SetActive(settingsMenu, false)
	if pauseMenu != null:
		U.SetActive(pauseMenu, false)
	PlaySound(menuCloseSound)
	OnGameResumed.Invoke()

func OnSettingsClicked() -> void:
	PlaySound(buttonClickSound)
	PlaySound(menuOpenSound)
	if pauseMenu != null and settingsMenu != null:
		U.SetActive(pauseMenu, false)
		U.SetActive(settingsMenu, true)

func OnSettingsClose() -> void:
	PlaySound(menuCloseSound)
	if settingsMenu != null and pauseMenu != null:
		U.SetActive(settingsMenu, false)
		U.SetActive(pauseMenu, true)

func OnMainMenuClicked() -> void:
	PlaySound(buttonClickSound)
	if ConfirmDialog.Instance != null:
		ConfirmDialog.Instance.Show(Loc.T("Main Menu", "Ana Menü"), Loc.T("Your progress will be saved.", "İlerlemen kaydedilecek."), ReturnToMainMenu, null, Loc.T("Yes", "Evet"), Loc.T("No", "Hayır"))
	else:
		ReturnToMainMenu()

func OnQuitClicked() -> void:
	PlaySound(buttonClickSound)
	if ConfirmDialog.Instance != null:
		ConfirmDialog.Instance.Show(Loc.T("Quit Game", "Oyundan Çık"), Loc.T("Your progress will be saved. Quit to the desktop?", "İlerlemen kaydedilecek. Masaüstüne çıkılsın mı?"), QuitToDesktop, null, Loc.T("Yes", "Evet"), Loc.T("No", "Hayır"))
	else:
		QuitToDesktop()

func QuitToDesktop() -> void:
	SaveSystem.SaveGame()
	U.timeScale = 1.0
	get_tree().quit()

func ReturnToMainMenu() -> void:
	SaveSystem.SaveGame()
	_isPaused = false
	U.timeScale = 1.0
	_isLoading = true
	if loadingScreen != null:
		U.SetActive(loadingScreen, true)
	if pauseMenu != null:
		U.SetActive(pauseMenu, false)
	if settingsMenu != null:
		U.SetActive(settingsMenu, false)
	if loadingBar != null:
		loadingBar.value = 1.0
	if loadingText != null:
		loadingText.text = "%s 100%%" % Loc.T("Loading", "Yükleniyor")
	await U.wait_rt(0.5)
	U.LoadScene("res://scenes/%s.tscn" % mainMenuSceneName)

func IsPaused() -> bool:
	return _isPaused

func PlaySound(c) -> void:
	if c != null and _audio != null:
		_audio.PlayOneShot(c, 0.5)
