class_name AshenveilQuestMapRegions
extends Mono

var spawned: Array = []
var regionRoot
var subscribed := false
var hoverRegionPrefab
var regionParentOverride

func OnEnable() -> void:
	QuestManager.OnReady.AddListener(TryInitialize)
	TryInitialize()

func OnDisable() -> void:
	QuestManager.OnReady.RemoveListener(TryInitialize)
	var qm = QuestManager.Instance
	if subscribed and qm != null:
		U.off(qm.OnQuestStarted, _q)
		U.off(qm.OnQuestCompleted, _q)
		U.off(qm.OnQuestAbandoned, _q)
		U.off(qm.OnObjectiveUpdated, _o)
		U.off(qm.OnObjectiveCompleted, _o)
		subscribed = false

func TryInitialize() -> void:
	if QuestManager.Instance == null or hoverRegionPrefab == null:
		return
	EnsureRegionRoot()
	if spawned.is_empty() and regionRoot != null:
		for e in AshenveilQuestTriggerCatalog.All():
			if e.component != "UIHoverBridge":
				continue
			var dup := false
			for s in spawned:
				if s.objectiveID == e.objectiveID:
					dup = true
			if not dup:
				SpawnRegion(e)
	var qm = QuestManager.Instance
	if not subscribed:
		U.on(qm.OnQuestStarted, _q)
		U.on(qm.OnQuestCompleted, _q)
		U.on(qm.OnQuestAbandoned, _q)
		U.on(qm.OnObjectiveUpdated, _o)
		U.on(qm.OnObjectiveCompleted, _o)
		subscribed = true
	RefreshAllVisibility()

func _q(_x) -> void:
	RefreshAllVisibility()

func _o(_x, _y) -> void:
	RefreshAllVisibility()

func EnsureRegionRoot() -> void:
	if regionRoot != null:
		return
	if regionParentOverride != null:
		regionRoot = regionParentOverride
		return
	var map = FindMapRect()
	if map == null:
		return
	var ex = U.FindChild(map, "AshenveilQuestRegions")
	if ex != null:
		regionRoot = ex
		return
	var go := UImage.new()
	go.name = "AshenveilQuestRegions"
	go.set_meta("u", "{\"name\":\"AshenveilQuestRegions\"}")
	go.set_meta("pivot", [0.5, 0.5])
	map.add_child(go)
	RT.set_anchor_min(go, Vector2(0.5, 0.5))
	RT.set_anchor_max(go, Vector2(0.5, 0.5))
	RT.set_size_delta(go, Vector2.ZERO)
	RT.set_anchored_position(go, Vector2.ZERO)
	regionRoot = go

func SpawnRegion(e) -> void:
	var inst = U.Instantiate(hoverRegionPrefab, regionRoot)
	inst.set_meta("u_name", e.suggestedSceneObjectName)
	inst.anchoredPosition = e.anchoredPosition
	inst.sizeDelta = e.size
	var b = U.GetComponent(inst, QuestUIHoverBridge)
	if b == null:
		b = U.AddComponent(inst, QuestUIHoverBridge)
	b.catalogObjectiveID = e.objectiveID
	b.requireQuestActive = true
	b.ApplyCatalogEntry()
	U.SetActive(inst, false)
	spawned.append({"questID": e.questID, "objectiveID": e.objectiveID, "instance": inst})

func RefreshAllVisibility() -> void:
	var qm = QuestManager.Instance
	if qm == null:
		return
	for s in spawned:
		if not is_instance_valid(s.instance):
			continue
		var show: bool = qm.IsQuestActive(s.questID) and not qm.GetObjectiveState(s.questID, s.objectiveID).isCompleted
		if s.instance.visible != show:
			U.SetActive(s.instance, show)

static func FindMapRect():
	if SceneEvent.Instance != null and SceneEvent.Instance.mapPanel != null:
		var m = U.FindChild(SceneEvent.Instance.mapPanel, "Map")
		if m != null:
			return m
	var mc = U.Find("MapCanvas")
	if mc != null:
		return U.FindChild(mc, "MapPanel/Map")
	return null
