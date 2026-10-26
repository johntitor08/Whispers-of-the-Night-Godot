class_name BoundArchivistQuestController
extends OriginQuestBase

static func IsBoundArchivist() -> bool:
	return StoryFlags.Has(QuestFlags.BoundArchivistStart)

static func HasElisNotes() -> bool:
	return StoryFlags.Has(QuestFlags.ThreeLocationsKnown)

static func HasEowToken() -> bool:
	return StoryFlags.Has(QuestFlags.BoundArchivistEowToken)

func OnOpeningSceneComplete() -> void:
	if StoryFlags.Has(QuestFlags.BoundArchivistOpeningComplete):
		return
	Flags([QuestFlags.BoundArchivistOpeningComplete, QuestFlags.BoundArchivistStart, QuestFlags.BrahmaLeft, QuestFlags.SealedFileTaken])
	TryAutoStartQuest(QuestIds.Q_BA01)

func OnMarenGateMet() -> void:
	if not IsBoundArchivist():
		return
	Flags([QuestFlags.MarenMetBoundArchivist, QuestFlags.AshenveilEntered])
	UpdateObjective(QuestIds.Q_BA01, "obj_speak_maren_gate")

func OnMarenKitchenComplete() -> void:
	if not IsBoundArchivist():
		return
	Flags([QuestFlags.MarenDialogueDone, QuestFlags.ReversalClauseKnown, QuestFlags.ChurchRuinsClue])
	UpdateObjective(QuestIds.Q_BA01, "obj_learn_maren_knowledge")

func OnElisMet() -> void:
	if not IsBoundArchivist():
		return
	Flags([QuestFlags.ElisMet, QuestFlags.ThreeLocationsKnown])
	UpdateObjective(QuestIds.Q_BA01, "obj_find_elis")

func OnEowOperativeMet(token: bool) -> void:
	if not IsBoundArchivist():
		return
	Flags([QuestFlags.EowOperativeMet, QuestFlags.EowWatching])
	if token:
		StoryFlags.Add(QuestFlags.BoundArchivistEowToken)
	UpdateObjective(QuestIds.Q_BA01, "obj_handle_eow_operative")

func OnVossDay3Complete() -> void:
	if not IsBoundArchivist():
		return
	Flags([QuestFlags.VossDay3BoundArchivist, QuestFlags.RecordNotChurchConfirmed, QuestFlags.VossMovedRecord])
	UpdateObjective(QuestIds.Q_BA01, "obj_speak_voss_day3")

func OnCrossReferenceComplete() -> void:
	if not IsBoundArchivist():
		return
	Flags([QuestFlags.RecordLocationNarrowed, QuestFlags.WitnessRequiredKnown])
	UpdateObjective(QuestIds.Q_BA01, "obj_cross_reference")

func OnQuestComplete(eow_invited: bool) -> void:
	if not IsBoundArchivist():
		return
	if eow_invited:
		StoryFlags.Add(QuestFlags.BoundArchivistQ1EowInvited)
	CompleteOr(QuestIds.Q_BA01, [QuestFlags.BoundArchivistQuest1Done])

static func GetPreferredWitness() -> String:
	if HasEowToken():
		return "eow"
	if StoryFlags.Has(QuestFlags.ElisMet):
		return "elis"
	return "maren"
