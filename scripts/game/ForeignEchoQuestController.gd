class_name ForeignEchoQuestController
extends OriginQuestBase

static func IsForeignEcho() -> bool:
	return StoryFlags.Has(QuestFlags.ForeignEchoStart)

func OnOpeningSceneComplete() -> void:
	if StoryFlags.Has(QuestFlags.ForeignEchoOpeningComplete):
		return
	Flags([QuestFlags.ForeignEchoOpeningComplete, QuestFlags.ForeignEchoStart, QuestFlags.ShadowAnomalySeen, QuestFlags.AshenveilEntered])
	TryAutoStartQuest(QuestIds.Q_FE01)

func OnMarenDoorComplete() -> void:
	if not IsForeignEcho():
		return
	Flags([QuestFlags.MarenMetForeignEcho, QuestFlags.VossCantIdentifyForeignEcho, QuestFlags.AxiosResonanceExplained])
	UpdateObjective(QuestIds.Q_FE01, "obj_follow_shadow_maren")

func OnMarenMissionGiven() -> void:
	if not IsForeignEcho():
		return
	Flags([QuestFlags.MarenMissionGiven, QuestFlags.ForeignEchoInvisibleToTracking, QuestFlags.ChamberTargetKnown])
	UpdateObjective(QuestIds.Q_FE01, "obj_understand_maren_need")

func OnMireyaMet() -> void:
	if not IsForeignEcho():
		return
	Flags([QuestFlags.MireyaMetForeignEcho, QuestFlags.MireyaMet, QuestFlags.LurkerPatrolData])
	UpdateObjective(QuestIds.Q_FE01, "obj_speak_mireya")

func OnChicoMet(accepted: bool) -> void:
	if not IsForeignEcho():
		return
	Flags([QuestFlags.ChicoMet, QuestFlags.AwamoriIncomingKnown])
	if accepted:
		StoryFlags.Add(QuestFlags.AxiosFrequencyShared)
	UpdateObjective(QuestIds.Q_FE01, "obj_meet_chico")

func OnVossDay3Complete() -> void:
	if not IsForeignEcho():
		return
	Flags([QuestFlags.VossDay3ForeignEcho, QuestFlags.ChamberFrequencyWarning, QuestFlags.VossCannotTrackForeignEcho])
	UpdateObjective(QuestIds.Q_FE01, "obj_speak_voss_day3")

func OnThreeCrystalsSeen() -> void:
	if IsForeignEcho():
		StoryFlags.Add(QuestFlags.ThreeCrystalsSeen)

func OnFourthSlotResonates() -> void:
	if IsForeignEcho():
		StoryFlags.Add(QuestFlags.FourthSlotResonatesForeignEcho)

func OnOriginatingRecordDetected() -> void:
	if not IsForeignEcho():
		return
	Flags([QuestFlags.OriginatingRecordBelow, QuestFlags.AxiosAnomalyIdentified])
	UpdateObjective(QuestIds.Q_FE01, "obj_identify_axios_anomaly")

func OnQuestComplete() -> void:
	if IsForeignEcho():
		CompleteOr(QuestIds.Q_FE01, [QuestFlags.ForeignEchoQuest1Done, QuestFlags.ChamberInteriorSeen])

static func ChamberDetectionMultiplier() -> float:
	var m := 1.0
	if StoryFlags.Has(QuestFlags.LurkerPatrolData):
		m -= 0.40
	if StoryFlags.Has(QuestFlags.ChamberFrequencyWarning):
		m -= 0.15
	return clampf(m, 0.0, 1.0)
