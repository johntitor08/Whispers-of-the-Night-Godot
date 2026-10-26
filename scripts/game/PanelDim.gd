class_name PanelDim
extends Mono

var darkness := 0.7
var _dim
var _group

func LateUpdate() -> void:
	if _dim == null or not is_instance_valid(_dim):
		return
	if _group == null:
		_group = GetComponent(UCanvasGroup)
	var a: float = _group.alpha if _group != null else 1.0
	var c: Color = _dim.color
	if not is_equal_approx(c.a, darkness * a):
		_dim.color = Color(c.r, c.g, c.b, darkness * a)

func OnEnable() -> void:
	EnsureDim()
	if _dim == null:
		return
	_dim.visible = true
	if _group == null:
		_group = GetComponent(UCanvasGroup)
	_dim.color = Color(0, 0, 0, darkness * (_group.alpha if _group != null else 1.0))
	var p = _dim.get_parent()
	p.move_child(_dim, -1)
	var go = gameObject
	if go.get_parent() == p:
		p.move_child(go, -1)
	ES.mark_layout_dirty()

func OnDisable() -> void:
	if _dim != null and is_instance_valid(_dim):
		_dim.visible = false

func EnsureDim() -> void:
	if _dim != null and is_instance_valid(_dim):
		return
	var c: Node = gameObject
	while c.get_parent() != null and c.get_parent() is Control and c.get_parent().has_meta("u"):
		c = c.get_parent()
	var img := UImage.new()
	img.name = "Dim"
	img.set_meta("u", "{\"name\":\"Dim\",\"image\":{\"color\":[0,0,0,0.7],\"raycastTarget\":true}}")
	img.set_meta("pivot", [0.5, 0.5])
	c.add_child(img)
	img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim = img
