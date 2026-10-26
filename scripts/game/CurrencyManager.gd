class_name CurrencyManager
extends Mono

static var Instance: CurrencyManager
signal OnCurrencyChanged(type: int, old_value: int, new_value: int)
signal OnCurrencyAdded(type: int, amount: int)
signal OnCurrencySpent(type: int, amount: int)
signal OnInsufficientFunds(type: int)

var currencyDict: Dictionary = {}
var currencies: Array = []
var gainSound
var spendSound
var insufficientFundsSound

func _on_injected(_root: Node) -> void:
	var out := []
	for c in currencies:
		if c is Dictionary:
			out.append({"type": int(c.get("type", 0)), "amount": int(c.get("amount", 0)), "maxAmount": int(c.get("maxAmount", 999999)), "icon": c.get("icon"), "displayColor": c.get("displayColor", Color.YELLOW)})
	currencies = out

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)
		return
	if currencies.is_empty():
		for t in [[CurrencyType.Gold, 100], [CurrencyType.Gems, 0], [CurrencyType.Tokens, 0], [CurrencyType.Credits, 0]]:
			currencies.append({"type": t[0], "amount": t[1], "maxAmount": 999999, "icon": null, "displayColor": Color.YELLOW})
	InitializeCurrencies()

func InitializeCurrencies() -> void:
	currencyDict.clear()
	for c in currencies:
		if not currencyDict.has(c.type):
			currencyDict[c.type] = c

func Get(type: int) -> int:
	return currencyDict[type].amount if currencyDict.has(type) else 0

func Has(type: int, amount: int) -> bool:
	return Get(type) >= amount

func GetCurrencyInfo(type: int):
	return currencyDict.get(type)

func GetAllCurrencies() -> Dictionary:
	var r := {}
	for c in currencies:
		r[c.type] = c.amount
	return r

func AddMultiple(amounts: Dictionary, showNotification := true) -> void:
	if amounts.is_empty():
		return
	var changes := {}
	for t in amounts:
		if not currencyDict.has(t) or amounts[t] <= 0:
			continue
		var c: Dictionary = currencyDict[t]
		var old: int = c.amount
		c.amount = mini(c.amount + amounts[t], c.maxAmount)
		var delta: int = c.amount - old
		if delta > 0:
			changes[t] = delta
			OnCurrencyAdded.emit(t, delta)
			OnCurrencyChanged.emit(t, old, c.amount)
	FinalizeTransaction(changes, true, showNotification)

func SpendMultiple(amounts: Dictionary, showNotification := true) -> bool:
	if amounts.is_empty():
		return false
	for t in amounts:
		if not Has(t, amounts[t]):
			OnInsufficientFunds.emit(t)
			PlaySound(insufficientFundsSound)
			return false
	var changes := {}
	for t in amounts:
		if not currencyDict.has(t):
			continue
		var c: Dictionary = currencyDict[t]
		var old: int = c.amount
		c.amount -= amounts[t]
		changes[t] = -amounts[t]
		OnCurrencySpent.emit(t, amounts[t])
		OnCurrencyChanged.emit(t, old, c.amount)
	FinalizeTransaction(changes, false, showNotification)
	return true

func Add(type: int, amount: int, showNotification := true) -> void:
	if amount <= 0 or not currencyDict.has(type):
		return
	var c: Dictionary = currencyDict[type]
	var old: int = c.amount
	c.amount = mini(c.amount + amount, c.maxAmount)
	var delta: int = c.amount - old
	if delta <= 0:
		return
	OnCurrencyAdded.emit(type, delta)
	OnCurrencyChanged.emit(type, old, c.amount)
	FinalizeSingle(true, showNotification, type, delta)

func Spend(type: int, amount: int, showNotification := true) -> bool:
	if not Has(type, amount):
		OnInsufficientFunds.emit(type)
		PlaySound(insufficientFundsSound)
		return false
	var c: Dictionary = currencyDict[type]
	var old: int = c.amount
	c.amount -= amount
	OnCurrencySpent.emit(type, amount)
	OnCurrencyChanged.emit(type, old, c.amount)
	FinalizeSingle(false, showNotification, type, amount)
	return true

func Set(type: int, amount: int) -> void:
	if not currencyDict.has(type):
		return
	var c: Dictionary = currencyDict[type]
	var old: int = c.amount
	c.amount = clampi(amount, 0, c.maxAmount)
	if old != c.amount:
		OnCurrencyChanged.emit(type, old, c.amount)
		SaveSystem.SaveGame()

func ResetAllCurrencies() -> void:
	for c in currencies:
		var old: int = c.amount
		if old == 0:
			continue
		c.amount = 0
		OnCurrencyChanged.emit(c.type, old, 0)
	SaveSystem.SaveGame()

func FinalizeTransaction(changes: Dictionary, isGain: bool, showNotification: bool) -> void:
	if changes.is_empty():
		return
	if showNotification and CurrencyNotificationUI.Instance != null:
		CurrencyNotificationUI.Instance.Show(changes)
	PlaySound(gainSound if isGain else spendSound)
	SaveSystem.SaveGame()

func FinalizeSingle(isGain: bool, showNotification: bool, type := CurrencyType.Gold, amount := 0) -> void:
	PlaySound(gainSound if isGain else spendSound)
	if showNotification and CurrencyNotificationUI.Instance != null and amount != 0:
		CurrencyNotificationUI.Instance.Show({type: amount if isGain else -amount})
	SaveSystem.SaveGame()

func PlaySound(clip) -> void:
	if clip != null:
		UAudioSource.PlayClipAtPoint(clip, null, 0.5)
