class_name TimeUI
extends Mono

static var Instance: TimeUI
var currentDay := 1
var _tgen := 0
var _igen := 0
var phaseText
var dayCounterText
var phaseIcon
var progressBar
var morningIcon
var noonIcon
var eveningIcon
var nightIcon
var showDayCounter := true
var showProgressBar := true
var animateTransitions := true

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)

func Start() -> void:
	if TimePhaseManager.Instance != null:
		U.on(TimePhaseManager.Instance.OnPhaseChanged, UpdateTimeDisplay)
		UpdateTimeDisplay(TimePhaseManager.Instance.currentPhase)
	if dayCounterText != null:
		U.SetActive(dayCounterText, showDayCounter)
	if progressBar != null:
		U.SetActive(progressBar, ShouldShowProgressBar())

func Update() -> void:
	if progressBar == null:
		return
	var on := ShouldShowProgressBar()
	if U.activeSelf(progressBar) != on:
		U.SetActive(progressBar, on)
	if on:
		progressBar.value = TimePhaseManager.Instance.GetPhaseProgress()

func ShouldShowProgressBar() -> bool:
	return showProgressBar and TimePhaseManager.Instance != null and TimePhaseManager.Instance.autoProgress

func OnDestroy() -> void:
	if TimePhaseManager.Instance != null:
		U.off(TimePhaseManager.Instance.OnPhaseChanged, UpdateTimeDisplay)

func UpdateTimeDisplay(p: int) -> void:
	if phaseText != null:
		phaseText.text = GetPhaseName(p)
		if animateTransitions:
			TextScaleAnimation()
	if phaseIcon != null:
		phaseIcon.sprite = [morningIcon, noonIcon, eveningIcon, nightIcon][p] if p >= 0 and p < 4 else null
		if animateTransitions:
			IconRotateAnimation()
	UpdateDayCounter()

func UpdateDayCounter() -> void:
	if dayCounterText != null and showDayCounter:
		dayCounterText.text = Loc.T("Day", "Gün") + " " + str(currentDay)

static func GetPhaseName(p: int) -> String:
	match p:
		TimePhase.Morning:
			return Loc.T("Morning", "Sabah")
		TimePhase.Noon:
			return Loc.T("Noon", "Öğle")
		TimePhase.Evening:
			return Loc.T("Evening", "Akşam")
		TimePhase.Night:
			return Loc.T("Night", "Gece")
	return Loc.T("Unknown", "Bilinmiyor")

func TextScaleAnimation() -> void:
	_tgen += 1
	var g := _tgen
	var e := co()
	var t := 0.0
	phaseText.scale = Vector2.ONE * 1.2
	while t < 0.3:
		if g != _tgen or dead(e):
			return
		t += U.deltaTime
		var k := 1.0 - pow(1.0 - clampf(t / 0.3, 0.0, 1.0), 3.0)
		phaseText.scale = (Vector2.ONE * 1.2).lerp(Vector2.ONE, k)
		await U.frame()
	phaseText.scale = Vector2.ONE

func IconRotateAnimation() -> void:
	_igen += 1
	var g := _igen
	var e := co()
	var t := 0.0
	phaseIcon.rotation = 0.0
	while t < 0.5:
		if g != _igen or dead(e):
			return
		t += U.deltaTime
		var k := 1.0 - pow(1.0 - clampf(t / 0.5, 0.0, 1.0), 2.0)
		phaseIcon.rotation = -deg_to_rad(lerpf(360.0, 0.0, k))
		await U.frame()
	phaseIcon.rotation = 0.0

func SetDay(d: int) -> void:
	currentDay = d
	UpdateDayCounter()

func GetCurrentDay() -> int:
	return currentDay

func IncrementDay() -> void:
	currentDay += 1
	UpdateDayCounter()
