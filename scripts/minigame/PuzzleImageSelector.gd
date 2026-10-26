class_name PuzzleImageSelector
extends Mono

var puzzleImages: Array = []
var randomizeOnStart := true
var previewImage
var imageNameText
var currentIndex := -1
var selectedImage

func Start() -> void:
	if randomizeOnStart:
		SelectNewRandomImage()

func SelectNewRandomImage() -> void:
	if puzzleImages.is_empty():
		return
	var newIndex := currentIndex
	if puzzleImages.size() > 1:
		while newIndex == currentIndex:
			newIndex = randi_range(0, puzzleImages.size() - 1)
	else:
		newIndex = 0
	currentIndex = newIndex
	ApplySelection()

func SelectImageByIndex(index: int) -> void:
	if index < 0 or index >= puzzleImages.size():
		return
	currentIndex = index
	ApplySelection()

func NextImage() -> void:
	if puzzleImages.is_empty():
		return
	currentIndex = (currentIndex + 1) % puzzleImages.size()
	ApplySelection()

func PreviousImage() -> void:
	if puzzleImages.is_empty():
		return
	currentIndex = (currentIndex - 1 + puzzleImages.size()) % puzzleImages.size()
	ApplySelection()

func ApplySelection() -> void:
	selectedImage = puzzleImages[currentIndex]
	if previewImage != null:
		previewImage.sprite = selectedImage
	if imageNameText != null:
		imageNameText.text = selectedImage.name
	PuzzleEvents.OnImageChanged.Invoke(selectedImage)

func GetSelectedImage():
	return selectedImage

func GetImageCount() -> int:
	return puzzleImages.size()

func GetImageByIndex(i: int):
	return puzzleImages[i]
