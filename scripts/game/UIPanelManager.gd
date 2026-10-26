class_name UIPanelManager
extends Mono

static var Instance: UIPanelManager
var panels: Array = []
var enforceMutualExclusion := true

func Awake() -> void:
	if Instance != null and is_instance_valid(Instance) and Instance != self:
		U.Destroy(gameObject)
		return
	Instance = self
	for e in panels:
		if e != null and e.get("root") != null:
			e["wasActive"] = e.root.visible

func OnDestroy() -> void:
	if Instance == self:
		Instance = null

func Update() -> void:
	for e in panels:
		if e == null or e.get("root") == null or not is_instance_valid(e.root):
			continue
		var act: bool = e.root.visible
		if enforceMutualExclusion and act and not e.get("wasActive", false):
			CloseOthers(e)
		e["wasActive"] = act

func OpenPanel(e) -> void:
	if e == null:
		return
	SetEntryActive(e, true)
	if enforceMutualExclusion:
		CloseOthers(e)

func CloseOpenPanels() -> bool:
	var any := false
	for e in panels:
		if e == null or e.get("root") == null or not is_instance_valid(e.root):
			continue
		if e.root.visible:
			SetEntryActive(e, false)
			any = true
	return any

func AnyPanelOpen() -> bool:
	for e in panels:
		if e != null and e.get("root") != null and is_instance_valid(e.root) and e.root.visible:
			return true
	return false

func CloseOthers(keep) -> void:
	for e in panels:
		if e == null or e == keep or e.get("root") == null or not is_instance_valid(e.root):
			continue
		if e.root.visible:
			SetEntryActive(e, false)

func SetEntryActive(e, active: bool) -> void:
	if active:
		if not e.root.visible:
			U.SetActive(e.root, true)
		SetCompanions(e, true)
		e["wasActive"] = true
		return
	var anim = U.GetComponent(e.root, UIPanelAnimator)
	if anim != null and U.activeInHierarchy(e.root):
		var root = e.root
		var done := func() -> void:
			if is_instance_valid(root):
				U.SetActive(root, false)
			SetCompanions(e, false)
		anim.PlayClose(done)
		return
	U.SetActive(e.root, false)
	SetCompanions(e, false)
	e["wasActive"] = false

func SetCompanions(e, active: bool) -> void:
	var comps = e.get("companions")
	if comps == null:
		return
	for c in comps:
		if c != null and is_instance_valid(c) and c.visible != active:
			U.SetActive(c, active)
