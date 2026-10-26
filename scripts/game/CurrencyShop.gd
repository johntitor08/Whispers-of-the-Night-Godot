class_name CurrencyShop
extends Mono

var shopItems: Array = []

func PurchaseItem(item) -> bool:
	if CurrencyManager.Instance == null or item == null:
		return false
	var cost := {}
	if item.costs != null and not item.costs.is_empty():
		for c in item.costs:
			cost[int(c.type)] = int(c.amount)
	else:
		cost[int(item.costType)] = int(item.cost)
	if CurrencyManager.Instance.SpendMultiple(cost):
		CurrencyManager.Instance.AddMultiple({int(item.rewardType): int(item.rewardAmount)})
		return true
	return false
