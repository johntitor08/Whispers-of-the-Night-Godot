class_name PlayerProfile
extends RefCounted

var playerName := "Player"
var level := 1
var experience := 0
var experienceToNextLevel := 100
var profileIconID := "default"
var unlockedIconIDs: Array = ["default"]
var statPoints := 0

static func from_dict(d) -> PlayerProfile:
	var p := PlayerProfile.new()
	if d is Dictionary:
		p.playerName = str(d.get("playerName", "Player"))
		p.level = int(d.get("level", 1))
		p.experience = int(d.get("experience", 0))
		p.experienceToNextLevel = int(d.get("experienceToNextLevel", 100))
		p.profileIconID = str(d.get("profileIconID", "default"))
		var u = d.get("unlockedIconIDs")
		if u is Array:
			p.unlockedIconIDs = u.duplicate()
		p.statPoints = int(d.get("statPoints", 0))
	return p
