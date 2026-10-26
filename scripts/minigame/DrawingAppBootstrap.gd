class_name DrawingAppBootstrap
extends Mono

var brushSettings

func Awake() -> void:
	if brushSettings == null:
		push_error("[DrawingAppBootstrap] BrushSettings asset not assigned.")
		return
	BrushSettings.Instance = brushSettings
