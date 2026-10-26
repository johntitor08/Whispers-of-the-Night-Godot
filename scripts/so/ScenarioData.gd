class_name ScenarioData
extends ScenarioDataFields

static func StepApplies(step) -> bool:
	return (U.empty(step.get("requiredFlag")) or StoryFlags.Has(step.requiredFlag)) and (U.empty(step.get("blockedByFlag")) or not StoryFlags.Has(step.blockedByFlag))
