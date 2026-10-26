class_name HotkeyPanelUI
extends Mono

static func PanelInputBlocked() -> bool:
	return GameMenuManager.Instance != null and is_instance_valid(GameMenuManager.Instance) and GameMenuManager.Instance.IsPaused()
