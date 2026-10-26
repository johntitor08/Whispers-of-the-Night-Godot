class_name ActiveStatusEffect
extends RefCounted

var data
var remainingDuration := 0.0
var nextTickTime := 0.0
var currentStacks := 1
var particleInstance
var remainingRounds := 0

func _init(d) -> void:
	data = d
	remainingDuration = float(d.duration)
	nextTickTime = float(d.tickInterval)
	currentStacks = 1
	remainingRounds = int(d.durationRounds)

func IsExpired() -> bool:
	return not data.isPermanent and remainingDuration <= 0.0

func RefreshDuration() -> void:
	remainingDuration = float(data.duration)
	remainingRounds = int(data.durationRounds)

func AddStack() -> void:
	if data.canStack and currentStacks < int(data.maxStacks):
		currentStacks += 1
