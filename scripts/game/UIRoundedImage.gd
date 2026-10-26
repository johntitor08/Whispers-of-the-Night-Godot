class_name UIRoundedImage
extends Mono

var radius := 6

func _on_injected(_root: Node) -> void:
	Apply()

func OnEnable() -> void:
	Apply()

func Apply() -> void:
	var img = gameObject
	if img is UImage:
		img.sprite = UISprites.Rounded(radius)
		img.type = UImage.Type.SLICED
