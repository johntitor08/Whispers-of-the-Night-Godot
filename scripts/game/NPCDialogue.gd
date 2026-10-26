class_name NPCDialogue
extends Mono

var startNode

func OnPointerClick(_e) -> void:
	if DialogueManager.Instance == null or DialogueManager.WorldClicksBlocked():
		return
	DialogueManager.Instance.StartDialogue(startNode)
