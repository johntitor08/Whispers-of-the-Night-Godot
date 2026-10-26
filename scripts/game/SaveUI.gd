class_name SaveUI
extends Mono

static var Instance: SaveUI
var savePanel
var settingsPanel
var slots: Array = []
var toastCanvasGroup
var toastText
var toastDuration := 2.0
var fadeDuration := 0.3
var _toast_gen := 0

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)

func Start() -> void:
	for i in slots.size():
		slots[i].Initialize(i, self)
	if toastCanvasGroup != null:
		toastCanvasGroup.alpha = 0.0
		toastCanvasGroup.blocksRaycasts = false
	if savePanel != null:
		U.SetActive(savePanel, false)

func OpenPanel() -> void:
	if savePanel != null:
		U.SetActive(savePanel, true)
	RefreshAllSlots()

func ClosePanel() -> void:
	UIPanelAnimator.Hide(savePanel)

func TogglePanel() -> void:
	if savePanel == null:
		return
	if U.activeSelf(savePanel):
		ClosePanel()
	else:
		OpenPanel()

func BackToSettingsPanel() -> void:
	if savePanel != null and settingsPanel != null:
		UIPanelAnimator.Hide(savePanel)
		UIPanelAnimator.Show(settingsPanel)

func RefreshAllSlots() -> void:
	for s in slots:
		s.Refresh()

func SetAllSlotsInteractable(v: bool) -> void:
	for s in slots:
		s.SetInteractable(v)

func ShowToast(message: String) -> void:
	if toastCanvasGroup == null:
		return
	if toastText != null:
		toastText.text = message
	_toast_gen += 1
	ToastRoutine(_toast_gen)

func ToastRoutine(g: int) -> void:
	toastCanvasGroup.blocksRaycasts = false
	await Fade(0.0, 1.0, g)
	if g != _toast_gen or dead(co()):
		return
	await U.wait(toastDuration)
	if g != _toast_gen or not is_inside_tree():
		return
	await Fade(1.0, 0.0, g)
	if g != _toast_gen or not is_inside_tree():
		return
	toastCanvasGroup.alpha = 0.0

func Fade(from: float, to: float, g: int) -> void:
	var elapsed := 0.0
	toastCanvasGroup.alpha = from
	while elapsed < fadeDuration:
		elapsed += get_process_delta_time() * Engine.time_scale
		toastCanvasGroup.alpha = lerpf(from, to, elapsed / fadeDuration)
		await U.frame()
		if g != _toast_gen or not is_inside_tree():
			return
	toastCanvasGroup.alpha = to
