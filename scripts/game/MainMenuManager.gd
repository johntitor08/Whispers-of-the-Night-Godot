class_name MainMenuManager
extends Mono

static var Instance: MainMenuManager
var _audio
var buttonPanel
var settingsMenu
var newGameButton
var continueButton
var settingsButton
var quitButton
var loadingScreen
var loadingBar
var loadingText
var buttonClickSound
var menuOpenSound
var menuCloseSound
var gameSceneName := "GameScene"

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self
	_audio = AddComponent(UAudioSource)
	_audio.playOnAwake = false

func Start() -> void:
	SetupButtons()
	UpdateContinueButton()
	if loadingScreen != null:
		U.SetActive(loadingScreen, false)
	if settingsMenu != null:
		U.SetActive(settingsMenu, false)

func SetupButtons() -> void:
	for pair in [[newGameButton, OnNewGameClicked], [continueButton, OnContinueClicked], [settingsButton, OnSettingsClicked], [quitButton, OnQuitClicked]]:
		if pair[0] != null:
			pair[0].onClick.RemoveAllListeners()
			pair[0].onClick.AddListener(pair[1])

func OnNewGameClicked() -> void:
	PlaySound(buttonClickSound)
	if SaveSystem.HasSaveFile() and ConfirmDialog.Instance != null:
		ConfirmDialog.Instance.Show(Loc.T("New Game", "Yeni Oyun"), Loc.T("This will overwrite your save. Continue?", "Bu, mevcut kaydının üzerine yazacak. Devam edilsin mi?"), StartNewGame, func(): SetButtonPanel(true), Loc.T("Yes", "Evet"), Loc.T("No", "Hayır"))
	else:
		StartNewGame()

func OnContinueClicked() -> void:
	PlaySound(buttonClickSound)
	if not SaveSystem.HasSaveFile():
		return
	U.timeScale = 1.0
	ResetGameManagers()
	SaveSystem.LoadGame()
	UpdateContinueButton()

func OnSettingsClicked() -> void:
	PlaySound(buttonClickSound)
	PlaySound(menuOpenSound)
	SetButtonPanel(false)
	if settingsMenu != null:
		U.SetActive(settingsMenu, true)

func OnSettingsClose() -> void:
	PlaySound(menuCloseSound)
	if settingsMenu != null:
		U.SetActive(settingsMenu, false)
	SetButtonPanel(true)

func OnQuitClicked() -> void:
	PlaySound(buttonClickSound)
	if ConfirmDialog.Instance != null:
		ConfirmDialog.Instance.Show(Loc.T("Quit Game", "Oyundan Çık"), Loc.T("Are you sure?", "Emin misin?"), QuitGame, null, Loc.T("Yes", "Evet"), Loc.T("No", "Hayır"))
	else:
		QuitGame()

func StartNewGame() -> void:
	SetButtonPanel(false)
	ResetGameManagers()
	SaveSystem.DeleteSave()
	SaveSystem.SavingEnabled = false
	U.timeScale = 1.0
	if loadingScreen != null:
		U.SetActive(loadingScreen, true)
	if loadingBar != null:
		loadingBar.value = 1.0
	if loadingText != null:
		loadingText.text = "%s 100%%" % Loc.T("Loading", "Yükleniyor")
	await U.wait_rt(0.5)
	U.LoadScene("res://scenes/%s.tscn" % gameSceneName)

func UpdateContinueButton() -> void:
	if continueButton != null:
		continueButton.interactable = SaveSystem.HasSaveFile()

func SetButtonPanel(v: bool) -> void:
	if buttonPanel != null:
		U.SetActive(buttonPanel, v)

func ResetGameManagers() -> void:
	StoryFlags.Reset()
	AffinityManager.ResetAll()
	GuideManager.ResetAll()
	Achievements.Wins = 0

func QuitGame() -> void:
	get_tree().quit()

func PlaySound(c) -> void:
	if c != null and _audio != null:
		_audio.PlayOneShot(c, 0.5)
