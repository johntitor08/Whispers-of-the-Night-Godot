class_name ConfirmDialog
extends Mono

static var Instance: ConfirmDialog
var onConfirm = null
var onCancel = null
var confirmationPanel
var titleText
var messageText
var confirmButton
var cancelButton
var confirmButtonText
var cancelButtonText

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)
	if confirmationPanel != null:
		U.SetActive(confirmationPanel, false)

func Start() -> void:
	if confirmButton != null:
		confirmButton.onClick.AddListener(OnConfirmClicked)
	if cancelButton != null:
		cancelButton.onClick.AddListener(OnCancelClicked)

func Show(title: String, message: String, confirm, cancel = null, confirm_label := "Yes", cancel_label := "No") -> void:
	if titleText != null:
		titleText.text = title
	if messageText != null:
		messageText.text = message
	onConfirm = confirm
	onCancel = cancel
	SetButtonText(confirm_label, cancel_label)
	if confirmationPanel != null:
		U.SetActive(confirmationPanel, true)

func OnConfirmClicked() -> void:
	Hide()
	if onConfirm is Callable:
		onConfirm.call()

func OnCancelClicked() -> void:
	Hide()
	if onCancel is Callable:
		onCancel.call()

func Hide() -> void:
	if confirmationPanel != null:
		U.SetActive(confirmationPanel, false)

func SetButtonText(c := "Yes", x := "No") -> void:
	if confirmButtonText != null:
		confirmButtonText.text = c
	if cancelButtonText != null:
		cancelButtonText.text = x
