class_name GameStartNameInput
extends Mono

static var Instance: GameStartNameInput
var typewriterFinished := false
var hasStarted := false
var nameInputPanel
var nameInputField
var characterCountText
var errorMessageText
var confirmButton
var randomNameButton
var playerPreviewImage
var welcomeText
var instructionText
var minNameLength := 3
var maxNameLength := 15
var allowSpaces := true
var allowNumbers := false
var allowSpecialCharacters := false
var randomNames: Array = ["Raven", "Blaze", "Shadow", "Storm", "Ash"]
var confirmSound
var errorSound
var typeSound
var panelAnimator
var useTypewriterEffect := true
var typewriterSpeed := 0.05

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)

func Start() -> void:
	SetupUI()
	CheckExistingProfile()

func SetupUI() -> void:
	typewriterFinished = not useTypewriterEffect
	if confirmButton != null:
		confirmButton.onClick.AddListener(TryConfirm)
		confirmButton.interactable = false
	if randomNameButton != null:
		randomNameButton.onClick.AddListener(OnRandomNameClicked)
	if nameInputField != null:
		nameInputField.characterLimit = maxNameLength
		if nameInputField.edit != null:
			nameInputField.edit.max_length = maxNameLength
			nameInputField.edit.placeholder_text = Loc.T("Hero's name...", "Kahraman adı...")
		nameInputField.onValueChanged.AddListener(OnNameChanged)
		nameInputField.onSubmit.AddListener(OnSubmit)
		if nameInputField.placeholder is UText:
			nameInputField.placeholder.text = Loc.T("Hero's name...", "Kahraman adı...")
	if errorMessageText != null:
		U.SetActive(errorMessageText, false)
	if welcomeText != null:
		var t := Loc.T("Welcome to the adventure!", "Maceraya hoş geldin!")
		if useTypewriterEffect:
			welcomeText.text = ""
			TypewriterEffect(welcomeText, t, typewriterSpeed)
		else:
			welcomeText.text = t

func FocusInputField() -> void:
	await U.wait(0.5)
	if nameInputField != null:
		nameInputField.ActivateInputField()

func OnNameChanged(n) -> void:
	var s := str(n)
	if characterCountText != null:
		characterCountText.text = "%d / %d" % [s.length(), maxNameLength]
	var r := ValidateName(s)
	if errorMessageText != null:
		if not r[0] and s.length() > 0:
			errorMessageText.text = r[1]
			U.SetActive(errorMessageText, true)
		else:
			U.SetActive(errorMessageText, false)
	if confirmButton != null:
		confirmButton.interactable = r[0] and typewriterFinished
	if typeSound != null and s.length() > 0:
		PlaySound(typeSound)

func ValidateName(n: String) -> Array:
	if n.strip_edges() == "":
		return [false, Loc.T("Name cannot be empty!", "İsim boş olamaz!")]
	if n.length() < minNameLength:
		return [false, Loc.T("Name must be at least %d characters!" % minNameLength, "İsim en az %d karakter olmalı!" % minNameLength)]
	if n.length() > maxNameLength:
		return [false, Loc.T("Name can be at most %d characters!" % maxNameLength, "İsim en fazla %d karakter olabilir!" % maxNameLength)]
	if not allowSpaces and " " in n:
		return [false, Loc.T("Name cannot contain spaces!", "İsim boşluk içeremez!")]
	if not allowNumbers and ContainsNumbers(n):
		return [false, Loc.T("Name cannot contain numbers!", "İsim rakam içeremez!")]
	if not allowSpecialCharacters and ContainsSpecial(n):
		return [false, Loc.T("Name cannot contain special characters!", "İsim özel karakter içeremez!")]
	return [true, ""]

static func ContainsNumbers(s: String) -> bool:
	for ch in s:
		if ch >= "0" and ch <= "9":
			return true
	return false

static func ContainsSpecial(s: String) -> bool:
	var re := RegEx.create_from_string("^[\\p{L}\\p{N} _]*$")
	return re.search(s) == null

func OnSubmit(_v) -> void:
	if typewriterFinished:
		TryConfirm()

func TryConfirm() -> void:
	if not typewriterFinished or nameInputField == null:
		return
	var n: String = nameInputField.text.strip_edges()
	var r := ValidateName(n)
	if not r[0]:
		ShowError(r[1])
		PlaySound(errorSound)
		return
	if confirmButton != null:
		U.SetActive(confirmButton, false)
	if randomNameButton != null:
		U.SetActive(randomNameButton, false)
	StartGame(n)

func OnRandomNameClicked() -> void:
	if randomNames.is_empty():
		return
	if nameInputField != null:
		nameInputField.text = str(randomNames[U.rangei(0, randomNames.size())])

func StartGame(n: String) -> void:
	if hasStarted:
		return
	hasStarted = true
	if ProfileManager.Instance != null:
		ProfileManager.Instance.SetPlayerName(n)
	if ProfileUI.Instance != null:
		ProfileUI.Instance.RefreshAll()
	if welcomeText != null:
		ShowWelcomeMessage(n)
	else:
		CompleteStart()
	PlaySound(confirmSound)

func ShowWelcomeMessage(n: String) -> void:
	welcomeText.text = ""
	await TypewriterEffect(welcomeText, Loc.T("Welcome, %s!" % n, "Hoş geldin, %s!" % n), typewriterSpeed)
	await U.wait(1.5)
	CompleteStart()

func CompleteStart() -> void:
	if panelAnimator != null:
		panelAnimator.SetTrigger("FadeOut")
		await U.wait(1.0)
	FinalizeStart()

func FinalizeStart() -> void:
	if nameInputPanel != null:
		U.SetActive(nameInputPanel, false)
	if StorySelectionUI.Instance != null:
		StorySelectionUI.Instance.ShowMainPanel()

func CheckExistingProfile() -> void:
	if SaveSystem.HasSaveFile() and SaveSystem.IsLoading:
		SaveSystem.SavingEnabled = true
		if nameInputPanel != null:
			U.SetActive(nameInputPanel, false)
		if SceneEvent.Instance != null:
			SceneEvent.Instance.InitializeGameContinue()
		return
	if nameInputPanel != null:
		U.SetActive(nameInputPanel, true)
		if nameInputField != null:
			FocusInputField()

func ShowError(msg: String) -> void:
	if errorMessageText != null:
		errorMessageText.text = msg
		U.SetActive(errorMessageText, true)
		ShakeEffect(errorMessageText)

func ShakeEffect(t) -> void:
	var orig: Vector2 = t.position
	var e := 0.0
	while e < 0.5:
		t.position = orig + Vector2(U.rangef(-1, 1) * 5.0, 0)
		e += U.deltaTime
		await U.frame()
	t.position = orig

func TypewriterEffect(t, full: String, spd: float) -> void:
	for ch in full:
		t.text += ch
		await U.wait(spd)
	typewriterFinished = true
	if confirmButton != null and nameInputField != null and ValidateName(nameInputField.text)[0]:
		confirmButton.interactable = true

func PlaySound(c) -> void:
	if c != null:
		UAudioSource.PlayClipAtPoint(c, null, 0.7)

func ShowNameInput() -> void:
	hasStarted = false
	if nameInputPanel != null:
		U.SetActive(nameInputPanel, true)
	if nameInputField != null:
		nameInputField.text = ""
		nameInputField.ActivateInputField()
