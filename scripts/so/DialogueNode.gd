class_name DialogueNode
extends DialogueNodeFields

static func make() -> DialogueNode:
	var n := DialogueNode.new()
	n.d = {"speakerName": "NPC", "speakerPortrait": null, "speakerNameColor": UIPalette.Gold, "lines": [], "speakerNameTR": "", "linesTR": [], "choices": [], "autoAdvance": 0, "autoAdvanceDelay": 3.0, "onEnter": null, "onExit": null, "characterImage": null, "backgroundImage": null, "fadeToBlack": 0, "sceneContext": 0, "flagsToSetOnExit": [], "isFinalNode": 0, "conditionalLines": [], "name": "Runtime"}
	return n

var DisplaySpeaker: String:
	get:
		return Loc.Pick(d.get("speakerName"), d.get("speakerNameTR"))

func GetDisplayLine(i: int) -> String:
	var tr = d.get("linesTR")
	if LanguageManager.Current == GameLanguage.TR and tr != null and i >= 0 and i < tr.size() and not U.empty(tr[i]):
		return str(tr[i])
	var ls = d.get("lines")
	return str(ls[i]) if ls != null and i >= 0 and i < ls.size() and ls[i] != null else ""

static func CondApplies(c) -> bool:
	if not U.empty(c.get("requiredFlag")) and not StoryFlags.Has(c.requiredFlag):
		return false
	if not U.empty(c.get("blockedByFlag")) and StoryFlags.Has(c.blockedByFlag):
		return false
	if not U.empty(c.get("requiredOrigin")):
		var o = OriginManager.Instance.CurrentOrigin if OriginManager.Instance != null else null
		if o == null or o.originID != c.requiredOrigin:
			return false
	if not U.empty(c.get("affinityCharacter")):
		var v: int = AffinityManager.Instance.Get(c.affinityCharacter) if AffinityManager.Instance != null else 0
		if v < int(c.get("minAffinity", 0)) or v > int(c.get("maxAffinity", 9999)):
			return false
	return not U.empty(c.get("line"))

static func CondLine(c) -> String:
	return Loc.Pick(c.get("line"), c.get("lineTR"))

static func ChoiceText(c) -> String:
	return Loc.Pick(c.get("choiceText"), c.get("choiceTextTR"))
