class_name DialogueTrigger
extends Mono

var startNode
var triggerOnce := true
var requireInteraction := true
var interactionPrompt
var isExhausted := false

func Start() -> void:
	if interactionPrompt != null:
		U.SetActive(interactionPrompt, false)

func TriggerDialogue() -> void:
	if DialogueManager.Instance == null or DialogueManager.Instance.IsInDialogue():
		return
	DialogueManager.Instance.StartDialogue(startNode)
	if triggerOnce:
		isExhausted = true
		if interactionPrompt != null:
			U.SetActive(interactionPrompt, false)
