class_name AmbientDialogueTrigger
extends Mono

var pool
var autoHook := true
var runtimeNode
var isHooked := false

func OnEnable() -> void:
	if not autoHook or isHooked:
		return
	var b = GetComponent(UButton)
	if b != null:
		b.onClick.AddListener(Play)
	var h = GetComponent(UIHoverRegion)
	if h != null:
		U.on(h.OnRegionClicked, Play)
	isHooked = true

func OnDisable() -> void:
	if not isHooked:
		return
	var b = GetComponent(UButton)
	if b != null:
		b.onClick.RemoveListener(Play)
	var h = GetComponent(UIHoverRegion)
	if h != null:
		U.off(h.OnRegionClicked, Play)
	isHooked = false

func Play() -> void:
	if pool == null or DialogueManager.Instance == null or DialogueManager.Instance.IsInDialogue():
		return
	if runtimeNode == null:
		runtimeNode = DialogueNode.make()
		runtimeNode.d.isFinalNode = 1
	runtimeNode.d.speakerName = pool.speakerName
	runtimeNode.d.speakerPortrait = pool.speakerPortrait
	runtimeNode.d.speakerNameColor = pool.speakerNameColor
	runtimeNode.d.lines = [pool.PickLine()]
	DialogueManager.Instance.StartDialogue(runtimeNode)
