class_name SettingsRevertGuard
extends Mono

func OnEnable() -> void:
	if SettingsManager.Instance != null:
		SettingsManager.Instance.CaptureSnapshot()

func OnDisable() -> void:
	if SettingsManager.Instance != null:
		SettingsManager.Instance.RestoreSnapshot()
