class_name UIRim
extends Mono

var theme
var radius := 22
var width := 2
var opacity := 0.75

func _on_injected(_root: Node) -> void:
	Apply()

func OnEnable() -> void:
	Apply()

func Apply() -> void:
	var img = gameObject
	if not (img is UImage):
		return
	img.sprite = UISprites.RoundedRing(radius, width)
	img.type = UImage.Type.SLICED
	img.raycastTarget = false
	img.enabled = true
	var c: Color = theme.accent if theme != null else Color(0.784, 0.659, 0.431)
	c.a = opacity
	img.color = c
