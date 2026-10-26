class_name DialogueNodeFields
extends SO

var speakerName:
	get:
		return d.get("speakerName", "NPC")
	set(v):
		d["speakerName"] = v

var speakerPortrait:
	get:
		return d.get("speakerPortrait", null)
	set(v):
		d["speakerPortrait"] = v

var speakerNameColor:
	get:
		return d.get("speakerNameColor", null)
	set(v):
		d["speakerNameColor"] = v

var lines:
	get:
		return d.get("lines", [])
	set(v):
		d["lines"] = v

var speakerNameTR:
	get:
		return d.get("speakerNameTR", "")
	set(v):
		d["speakerNameTR"] = v

var linesTR:
	get:
		return d.get("linesTR", [])
	set(v):
		d["linesTR"] = v

var choices:
	get:
		return d.get("choices", [])
	set(v):
		d["choices"] = v

var autoAdvance:
	get:
		return d.get("autoAdvance", false)
	set(v):
		d["autoAdvance"] = v

var autoAdvanceDelay:
	get:
		return d.get("autoAdvanceDelay", 3.0)
	set(v):
		d["autoAdvanceDelay"] = v

var onEnter:
	get:
		return d.get("onEnter", null)
	set(v):
		d["onEnter"] = v

var onExit:
	get:
		return d.get("onExit", null)
	set(v):
		d["onExit"] = v

var changeCameraOnEnter:
	get:
		return d.get("changeCameraOnEnter", false)
	set(v):
		d["changeCameraOnEnter"] = v

var cameraTargetTag:
	get:
		return d.get("cameraTargetTag", "MainCamera")
	set(v):
		d["cameraTargetTag"] = v

var characterImage:
	get:
		return d.get("characterImage", null)
	set(v):
		d["characterImage"] = v

var backgroundImage:
	get:
		return d.get("backgroundImage", null)
	set(v):
		d["backgroundImage"] = v

var fadeToBlack:
	get:
		return d.get("fadeToBlack", false)
	set(v):
		d["fadeToBlack"] = v

var sceneContext:
	get:
		return d.get("sceneContext", SceneProgress.Scene1)
	set(v):
		d["sceneContext"] = v

var flagsToSetOnExit:
	get:
		return d.get("flagsToSetOnExit", [])
	set(v):
		d["flagsToSetOnExit"] = v

var isFinalNode:
	get:
		return d.get("isFinalNode", false)
	set(v):
		d["isFinalNode"] = v

var conditionalLines:
	get:
		return d.get("conditionalLines", [])
	set(v):
		d["conditionalLines"] = v
