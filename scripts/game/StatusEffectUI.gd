class_name StatusEffectUI
extends Mono

var effectManager
var bindToPlayer := false
var iconContainer
var iconPrefab
var activeIcons: Array = []
var isSubscribed := false
var group

func OnEnable() -> void:
	TrySubscribe()

func OnDisable() -> void:
	if isSubscribed and effectManager != null:
		U.off(effectManager.OnEffectApplied, OnEffectApplied)
		U.off(effectManager.OnEffectRemoved, OnEffectRemoved)
		U.off(effectManager.OnEffectHeal, OnEffectHeal)
	isSubscribed = false

func TrySubscribe() -> void:
	if bindToPlayer and effectManager == null and PlayerStats.Instance != null:
		effectManager = PlayerStats.Instance.GetComponent(StatusEffectManager)
	if effectManager != null and not isSubscribed:
		U.on(effectManager.OnEffectApplied, OnEffectApplied)
		U.on(effectManager.OnEffectRemoved, OnEffectRemoved)
		U.on(effectManager.OnEffectHeal, OnEffectHeal)
		isSubscribed = true

func LateUpdate() -> void:
	if group == null:
		group = GetComponent(UCanvasGroup)
		if group == null:
			group = AddComponent(UCanvasGroup)
	var any := false
	for i in activeIcons:
		if is_instance_valid(i):
			any = true
	group.alpha = 1.0 if any else 0.0
	group.blocksRaycasts = any

func Update() -> void:
	if effectManager == null:
		isSubscribed = false
		TrySubscribe()
		if effectManager == null:
			return
	for i in range(activeIcons.size() - 1, -1, -1):
		var icon = activeIcons[i]
		if not is_instance_valid(icon):
			continue
		var eff = effectManager.GetActiveEffect(icon.effectType)
		if eff != null:
			icon.UpdateEffect(eff)
		else:
			activeIcons.remove_at(i)
			U.Destroy(icon.gameObject)

func _find(t: int):
	for i in activeIcons:
		if is_instance_valid(i) and i.effectType == t:
			return i
	return null

func OnEffectApplied(data) -> void:
	var icon = _find(int(data.effectType))
	if icon != null:
		icon.UpdateEffect(effectManager.GetActiveEffect(int(data.effectType)))
	else:
		icon = U.Instantiate(iconPrefab, iconContainer)
		icon.Setup(effectManager.GetActiveEffect(int(data.effectType)))
		activeIcons.append(icon)

func OnEffectRemoved(data) -> void:
	var icon = _find(int(data.effectType))
	if icon != null:
		activeIcons.erase(icon)
		U.Destroy(icon.gameObject)

func OnEffectHeal(data, _amount: int) -> void:
	var icon = _find(int(data.effectType))
	if icon != null:
		FlashHeal(icon)

func FlashHeal(icon) -> void:
	var bg = icon.backgroundImage
	if bg == null:
		return
	var orig: Color = bg.color
	var fl := Color(0.3, 1, 0.3, 0.9)
	var t := 0.0
	while t < 0.25:
		if not is_instance_valid(bg):
			return
		t += U.deltaTime
		bg.color = fl.lerp(orig, clampf(t / 0.25, 0.0, 1.0))
		await U.frame()
	if is_instance_valid(bg):
		bg.color = orig
