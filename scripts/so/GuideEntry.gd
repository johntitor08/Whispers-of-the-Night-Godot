class_name GuideEntry
extends GuideEntryFields

var DisplayTitle: String:
	get:
		return Loc.Pick(d.get("title"), d.get("titleTR"))

var DisplayBody: String:
	get:
		return Loc.Pick(d.get("body"), d.get("bodyTR"))
