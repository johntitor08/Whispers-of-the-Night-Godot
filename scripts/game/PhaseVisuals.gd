class_name PhaseVisuals
extends Mono

var overlay
var morning := Color(1, 0.85, 0.7, 0.15)
var noon := Color(1, 1, 1, 0)
var evening := Color(1, 0.6, 0.4, 0.25)
var night := Color(0.2, 0.3, 0.6, 0.45)
var fadeSpeed := 2.0
var target := Color(1, 1, 1, 0)

func Start() -> void:
	U.on(TimePhaseManager.Instance.OnPhaseChanged, ApplyPhase)
	ApplyPhase(TimePhaseManager.Instance.currentPhase)

func ApplyPhase(p: int) -> void:
	target = [morning, noon, evening, night][p] if p >= 0 and p < 4 else noon

func Update() -> void:
	overlay.color = overlay.color.lerp(target, clampf(U.deltaTime * fadeSpeed, 0.0, 1.0))
