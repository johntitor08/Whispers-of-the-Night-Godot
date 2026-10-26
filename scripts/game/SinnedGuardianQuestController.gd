class_name SinnedGuardianQuestController
extends OriginQuestBase

static func IsGuardian() -> bool:
	return StoryFlags.Has(QuestFlags.SinnedGuardianStart)

func OnOpeningSceneComplete() -> void:
	if StoryFlags.Has(QuestFlags.SinnedGuardianOpeningComplete):
		return
	Flags([QuestFlags.SinnedGuardianOpeningComplete, QuestFlags.SinnedGuardianStart])
	TryAutoStartQuest(QuestIds.Q_SG01)

func OnMarenNightMet() -> void:
	if not IsGuardian():
		return
	Flags([QuestFlags.MarenFirstMeeting, QuestFlags.MarenToldGuardianMission, QuestFlags.VossCollectsNotDestroysKnown, QuestFlags.ShadowGardenQuestAssigned])
	UpdateObjective(QuestIds.Q_SG01, "q_sg01_obj1")

func OnAsludeMet() -> void:
	if not IsGuardian():
		return
	Flags([QuestFlags.AsludeMet, QuestFlags.VossReturnsDay3Known])
	UpdateObjective(QuestIds.Q_SG01, "q_sg01_obj2")

func OnCorvinOptionalSpoken() -> void:
	if not IsGuardian():
		return
	StoryFlags.Add(QuestFlags.CorvinOptionalSpoken)
	UpdateObjective(QuestIds.Q_SG01, "q_sg01_obj3")

func OnWesternEdgeLearned() -> void:
	if not IsGuardian():
		return
	StoryFlags.Add(QuestFlags.DragsimEastClue)
	UpdateObjective(QuestIds.Q_SG01, "q_sg01_obj4")

func OnVossTracked() -> void:
	if not IsGuardian():
		return
	StoryFlags.Add(QuestFlags.VossTrackedGuardian)
	UpdateObjective(QuestIds.Q_SG01, "q_sg01_obj5")

func OnVossDay3Complete() -> void:
	if not IsGuardian():
		return
	Flags([QuestFlags.VossDay3Guardian, QuestFlags.VossReversalClauseHinted])
	UpdateObjective(QuestIds.Q_SG01, "q_sg01_obj6")

func OnSecondWallFound() -> void:
	if not IsGuardian():
		return
	StoryFlags.Add(QuestFlags.DragsimSecondWallKnown)
	UpdateObjective(QuestIds.Q_SG01, "q_sg01_obj7")

func OnSecondWallExamined() -> void:
	if not IsGuardian():
		return
	Flags([QuestFlags.FourthCrystalSlotSeen, QuestFlags.VossPreparedGuardianContract])
	UpdateObjective(QuestIds.Q_SG01, "q_sg01_obj8")

func OnQuestComplete() -> void:
	if not IsGuardian():
		return
	UpdateObjective(QuestIds.Q_SG01, "q_sg01_obj9")
	CompleteOr(QuestIds.Q_SG01, [QuestFlags.ThreeFamiliesLocated, QuestFlags.ShadowGardenRank1, QuestFlags.SinnedGuardianQuest1Done])
