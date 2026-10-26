class_name CurrencyReward

static func Grant(reward, showNotification := true) -> void:
	if reward == null or CurrencyManager.Instance == null:
		return
	var amount := int(reward.get("amount", 0))
	if amount <= 0:
		return
	CurrencyManager.Instance.Add(int(reward.get("type", 0)), amount, showNotification)

static func GrantAll(rewards, showNotification := true) -> void:
	if rewards == null or rewards.is_empty() or CurrencyManager.Instance == null:
		return
	var d := {}
	for r in rewards:
		if r == null or int(r.get("amount", 0)) <= 0:
			continue
		var t := int(r.get("type", 0))
		d[t] = d.get(t, 0) + int(r.amount)
	if not d.is_empty():
		CurrencyManager.Instance.AddMultiple(d, showNotification)
