class_name AshenveilQuestTriggerCatalog

class Entry:
	var questID := ""
	var objectiveID := ""
	var tag := ""
	var suggestedSceneObjectName := ""
	var recommendedKind := 1
	var component := ""
	var progressAmount := 1
	var anchoredPosition := Vector2.ZERO
	var size := Vector2(60, 60)

const RAW := [
	["q01_bir_fincan_huzur", "q01_obj1", "Ashenveil_Garden_ApplePickup", 1, "WorldItem", "q01_obj1", 1],
	["q01_bir_fincan_huzur", "q01_obj2", "Ashenveil_Kitchen_CinnamonShelf", 1, "WorldItem", "q01_obj2", 1],
	["q01_bir_fincan_huzur", "q01_obj3", "Ashenveil_Kitchen_Stove", 1, "UIHoverBridge", "q01_obj3", 1],
	["q01_bir_fincan_huzur", "q01_obj4", "Ashenveil_Maren_TeaHandIn", 0, "UIHoverBridge", "q01_obj4", 1],
	["q02_hala_duman", "q02_obj1", "Ashenveil_House_Blacksmith_Search", 1, "WorldItem", "q02_obj1", 1],
	["q02_hala_duman", "q02_obj2", "Ashenveil_House_Baker_Search", 1, "WorldItem", "q02_obj2", 1],
	["q02_hala_duman", "q02_obj3", "Ashenveil_House_Healer_Search", 1, "WorldItem", "q02_obj3", 1],
	["q02_hala_duman", "q02_obj4", "Ashenveil_Outskirts_ShadowLurker", 1, "CombatTrigger", "q02_obj4", 1],
	["q02_hala_duman", "q02_obj5", "Ashenveil_NPC_Corvin", 0, "UIHoverBridge", "q02_obj5", 1],
	["q03_kirik_muhur", "q03_obj1", "Ashenveil_Villager_Talk_01", 3, "UIHoverBridge", "q03_obj1", 1],
	["q03_kirik_muhur", "q03_obj1", "Ashenveil_Villager_Talk_02", 3, "UIHoverBridge", "q03_obj1", 1],
	["q03_kirik_muhur", "q03_obj1", "Ashenveil_Villager_Talk_03", 3, "UIHoverBridge", "q03_obj1", 1],
	["q03_kirik_muhur", "q03_obj2", "Ashenveil_Square_HiddenTrail", 1, "UIHoverBridge", "q03_obj2", 1],
	["q03_kirik_muhur", "q03_obj3", "Ashenveil_Barn_BackChest", 1, "UIHoverBridge", "q03_obj3", 1],
	["q04_yasli_adamin_itirafi", "q04_obj1", "Ashenveil_NPC_Corvin_Evening", 0, "UIHoverBridge", "q04_obj1", 1],
	["q04_yasli_adamin_itirafi", "q04_obj2", "Ashenveil_OldSquare_Fountain", 1, "UIHoverBridge", "q04_obj2", 1],
	["q04_yasli_adamin_itirafi", "q04_obj3", "Ashenveil_Fountain_HiddenDocument", 1, "UIHoverBridge", "q04_obj3", 1],
	["q05_acik_el", "q05_obj1", "Ashenveil_Mill_Investigate", 1, "UIHoverBridge", "q05_obj1", 1],
	["q05_acik_el", "q05_obj2", "Ashenveil_Mill_CaveEntrance", 1, "UIHoverBridge", "q05_obj2", 1],
	["q05_acik_el", "q05_obj3", "Ashenveil_Cave_ShadowGuards", 1, "CombatTrigger", "q05_obj3", 1],
	["q05_acik_el", "q05_obj4", "Ashenveil_Cave_PrisonerCage", 1, "UIHoverBridge", "q05_obj4", 1],
	["q05_acik_el", "q05_obj5", "Ashenveil_Village_ReturnPrisoner", 1, "UIHoverBridge", "q05_obj5", 1],
	["q06_tarif_defteri", "q06_obj1", "Ashenveil_Field_RecipePage", 1, "WorldItem", "q06_obj1", 1],
	["q06_tarif_defteri", "q06_obj2", "Ashenveil_Maren_RecipeDelivery", 0, "UIHoverBridge", "q06_obj2", 1],
	["q07_corvinin_borcu", "q07_obj1", "Ashenveil_ChurchRuins_Entrance", 1, "UIHoverBridge", "q07_obj1", 1],
	["q07_corvinin_borcu", "q07_obj2", "Ashenveil_ChurchRuins_CursedGuards", 1, "CombatTrigger", "q07_obj2", 1],
	["q07_corvinin_borcu", "q07_obj3", "Ashenveil_ChurchRuins_Vault", 1, "UIHoverBridge", "q07_obj3", 1],
	["q07_corvinin_borcu", "q07_obj4", "Ashenveil_Corvin_DocumentReturn", 0, "UIHoverBridge", "q07_obj4", 1],
	["q08_defterdeki_sesler", "q08_obj1", "Ashenveil_NPC_MysteriousStranger", 0, "UIHoverBridge", "q08_obj1", 1],
	["q08_defterdeki_sesler", "q08_obj2", "Ashenveil_Village_Symbol", 1, "UIHoverBridge", "q08_obj2", 1],
	["q08_defterdeki_sesler", "q08_obj3", "Ashenveil_Village_Symbol_Seal", 1, "UIHoverBridge", "q08_obj3", 1],
	["q09_bekleyis", "q09_obj1", "Ashenveil_Gate_VossWait", 1, "UIHoverBridge", "q09_obj1", 1],
	["q09_bekleyis", "q09_obj2", "Ashenveil_Voss_Stall", 1, "UIHoverBridge", "q09_obj2", 1],
	["q09_bekleyis", "q09_obj3", "Ashenveil_Gate_FollowVoss", 1, "UIHoverBridge", "q09_obj3", 1],
	["q09_bekleyis", "q09_obj4", "Ashenveil_Voss_HiddenWarehouse", 1, "UIHoverBridge", "q09_obj4", 1],
	["q10_acik_hesap", "q10_obj1", "Ashenveil_Warehouse_ShadowGuards", 1, "CombatTrigger", "q10_obj1", 1],
	["q10_acik_hesap", "q10_obj2", "Ashenveil_Warehouse_PrisonCages", 1, "UIHoverBridge", "q10_obj2", 1],
	["q10_acik_hesap", "q10_obj3", "Ashenveil_Warehouse_VossConfront", 0, "WorldTalk", "q10_obj3", 1],
	["q10_acik_hesap", "q10_obj4", "Ashenveil_Warehouse_VossBoss", 1, "CombatTrigger", "q10_obj4", 1],
	["q11_fincan_basinda", "q11_obj1", "Ashenveil_Maren_FinaleTalk", 0, "UIHoverBridge", "q11_obj1", 1],
	["q11_fincan_basinda", "q11_obj2", "Ashenveil_Garden_FinaleWalk", 1, "UIHoverBridge", "q11_obj2", 1],
	["q11_fincan_basinda", "q11_obj3", "Ashenveil_Garden_FinaleTea", 1, "UIHoverBridge", "q11_obj3", 1],
]

static var _all: Array = []
static var _by_id: Dictionary = {}

static func All() -> Array:
	if _all.is_empty():
		for r in RAW:
			var e := Entry.new()
			e.questID = r[0]
			e.objectiveID = r[1]
			e.suggestedSceneObjectName = r[2]
			e.recommendedKind = r[3]
			e.component = r[4]
			e.tag = r[5]
			e.progressAmount = r[6]
			_all.append(e)
			if not _by_id.has(e.objectiveID):
				_by_id[e.objectiveID] = e
	return _all

static func TryGet(id):
	All()
	return _by_id.get(str(id))

static func GetForQuest(qid: String) -> Array:
	return All().filter(func(e): return e.questID == qid)

static func BackgroundFor(n: String) -> String:
	if n == "":
		return ""
	if "TeaHandIn" in n or "Archive" in n or "Library" in n:
		return "bg_templeborn_archives"
	if "Garden" in n:
		return "bg_apple_garden"
	if "Kitchen" in n or "Maren" in n:
		return "bg_maren_kitchen"
	if "House_Blacksmith" in n:
		return "bg_blacksmith_home"
	if "House_Baker" in n:
		return "bg_baker_home"
	if "House_Healer" in n:
		return "bg_healer_home"
	if "Outskirts" in n or "Field" in n:
		return "bg_village_fields"
	if "Barn" in n:
		return "bg_barn"
	if "Mill" in n:
		return "bg_village_mill"
	if "Cave" in n:
		return "bg_cave"
	if "ChurchRuins" in n:
		return "bg_church_ruins"
	if "Warehouse" in n:
		return "bg_voss_warehouse"
	if "Voss_Stall" in n:
		return "bg_voss_stall"
	if "Gate" in n or "ReturnPrisoner" in n:
		return "bg_village_gate"
	if "Corvin" in n or "Villager" in n or "Square" in n or "Fountain" in n or "Symbol" in n or "Mysterious" in n:
		return "bg_village_square"
	return ""
