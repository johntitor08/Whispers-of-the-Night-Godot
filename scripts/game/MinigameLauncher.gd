class_name MinigameLauncher
extends Mono

const PuzzleSceneName := "PuzzleGame"
const DrawingSceneName := "DrawingApp"
const PERSISTENT := ["MinigameLauncher", "TimePhaseManager", "GameAudioManager", "ScenarioManager", "ProfileManager", "CurrencyManager", "PlayerBuffManager", "CombatManager", "ShopManager", "PlayerStats", "EquipmentManager", "QuestManager", "DialogueManager", "InventoryManager", "OriginManager"]
static var Instance: MinigameLauncher
var _busy := false
var _inMinigame := false
var _activeScene: Node
var _hiddenRoots: Array = []
var _pausedTimePhase
var _timePhaseWasEnabled := false

var InMinigame: bool:
	get:
		return _inMinigame

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self

func LaunchPuzzle() -> void:
	Launch(PuzzleSceneName)

func LaunchDrawing() -> void:
	Launch(DrawingSceneName)

func Launch(sceneName: String) -> void:
	if _busy or _inMinigame:
		return
	_busy = true
	var root := U.scene_root()
	var mine := _top_of(root)
	_hiddenRoots.clear()
	for c in root.get_children():
		if c == mine or not (c is CanvasItem or c is CanvasLayer) or _is_persistent(c):
			continue
		if c.visible:
			_hiddenRoots.append(c)
			U.SetActive(c, false)
	_pausedTimePhase = U.FindAnyObjectByType(TimePhaseManager)
	if _pausedTimePhase != null:
		_timePhaseWasEnabled = _pausedTimePhase.enabled
		_pausedTimePhase.enabled = false
	var path := "res://scenes/%s.tscn" % sceneName
	if not ResourceLoader.exists(path):
		push_error("[MinigameLauncher] Scene not found: " + path)
		RestoreGameRoots()
		_busy = false
		return
	var ps: PackedScene = load(path)
	_activeScene = ps.instantiate()
	ES.reset()
	root.add_child(_activeScene)
	await U.frame()
	_inMinigame = true
	_busy = false

func _is_persistent(n: Node) -> bool:
	for c in n.get_children():
		if c is Mono and c.get_script() != null and str(c.get_script().get_global_name()) in PERSISTENT:
			return true
	return false

func _top_of(root: Node) -> Node:
	var n: Node = gameObject
	while n != null and n.get_parent() != root:
		n = n.get_parent()
	return n

func ReturnToGame() -> void:
	if _busy or not _inMinigame:
		return
	_busy = true
	if _activeScene != null and is_instance_valid(_activeScene):
		_activeScene.queue_free()
		await U.frame()
	_activeScene = null
	ES.reset()
	RestoreGameRoots()
	_inMinigame = false
	_busy = false

func RestoreGameRoots() -> void:
	for r in _hiddenRoots:
		if is_instance_valid(r):
			U.SetActive(r, true)
	_hiddenRoots.clear()
	if _pausedTimePhase != null and is_instance_valid(_pausedTimePhase):
		_pausedTimePhase.enabled = _timePhaseWasEnabled
	_pausedTimePhase = null
