class_name StatModifierItem
extends StatModifierItemFields

func Use() -> void:
	if PlayerStats.Instance == null:
		return
	if d.get("modifyMaxStat", 0):
		PlayerStats.Instance.ModifyMax(int(d.get("targetStat", 0)), int(d.get("modifyAmount", 0)))
	else:
		PlayerStats.Instance.Modify(int(d.get("targetStat", 0)), int(d.get("modifyAmount", 0)))
	SaveSystem.SaveGame()
