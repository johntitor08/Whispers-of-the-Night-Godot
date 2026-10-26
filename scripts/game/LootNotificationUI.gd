class_name LootNotificationUI
extends Mono

static var Instance: LootNotificationUI
static var notificationPool: Array = []
var notificationPrefab
var notificationParent
var notificationDuration := 3.0

func Awake() -> void:
	if Instance == null or not is_instance_valid(Instance) or Instance == self:
		Instance = self
	else:
		U.Destroy(gameObject)

func OnDestroy() -> void:
	notificationPool.clear()

func ShowLoot(item) -> void:
	if item == null:
		return
	var c: Color = item.GetRarityColor() if item is EquipmentData else UIPalette.Cream
	ShowNotification("+1 %s" % item.DisplayName, c, item.icon)

func ShowMessage(msg: String, c: Color) -> void:
	ShowNotification(msg, c)

func ShowNotification(msg: String, c: Color, icon = null) -> void:
	var n = GetNotification()
	var s = U.GetComponent(n, LootNotification)
	if s != null:
		s.Setup(msg, c, icon, notificationDuration)
	U.SetActive(n, true)

func GetNotification():
	while not notificationPool.is_empty():
		var n = notificationPool.pop_front()
		if is_instance_valid(n):
			return n
	return U.Instantiate(notificationPrefab, notificationParent)

func ReturnToPool(n) -> void:
	U.SetActive(n, false)
	notificationPool.append(n)
