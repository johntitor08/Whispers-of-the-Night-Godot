class_name LayerPanelUI
extends Mono

var listParent
var layerItemPrefab

func Start() -> void:
	U.on(LayerManager.Instance.OnLayersChanged, Refresh)
	Refresh()

func OnDestroy() -> void:
	if LayerManager.Instance != null and is_instance_valid(LayerManager.Instance):
		U.off(LayerManager.Instance.OnLayersChanged, Refresh)

func Refresh() -> void:
	for c in U.kids(listParent):
		U.Destroy(c)
	var layers: Array = LayerManager.Instance.Layers
	for i in range(layers.size() - 1, -1, -1):
		var layer = layers[i]
		var item = U.go_of(U.Instantiate(layerItemPrefab, listParent))
		var label = U.GetComponentInChildren(item, UText)
		if label != null:
			label.text = layer.name
		var toggle = U.GetComponentInChildren(item, UToggle)
		if toggle != null:
			toggle.isOn = layer.visible
			toggle.onValueChanged.AddListener(_on_visible.bind(layer))
		var btn = U.GetComponent(item, UButton)
		if btn != null:
			btn.onClick.AddListener(LayerManager.Instance.SetActive.bind(i))
		for s in U.GetComponentsInChildren(item, USlider):
			if str(U.go_of(s).name).to_lower().contains("opacity"):
				s.value = layer.opacity
				s.onValueChanged.AddListener(_on_opacity.bind(layer))

func _on_visible(v: bool, layer) -> void:
	layer.visible = v
	DrawingCanvas.Instance.RefreshDisplay()

func _on_opacity(v: float, layer) -> void:
	layer.opacity = v
	DrawingCanvas.Instance.RefreshDisplay()
