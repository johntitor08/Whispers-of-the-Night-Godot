class_name UIClickSound
extends Mono

func Start() -> void:
	if GetComponent(UIHoverRegion) != null:
		return
	var b = GetComponent(UButton)
	if b != null:
		b.onClick.AddListener(_click)

func _click() -> void:
	if GameAudioManager.Instance != null:
		GameAudioManager.Instance.PlayUiClick()

static func AddToChildren(root) -> void:
	for b in U.GetComponentsInChildren(root, UButton, true):
		if U.GetComponent(b.gameObject, UIClickSound) == null:
			U.AddComponent(b.gameObject, UIClickSound)
