class_name LocalizedText
extends Mono

var en := ""
var tr := ""
var _text

func Awake() -> void:
	_text = gameObject

func OnEnable() -> void:
	LanguageManager.OnLanguageChanged.AddListener(OnLanguageChanged)
	Apply()

func OnDisable() -> void:
	LanguageManager.OnLanguageChanged.RemoveListener(OnLanguageChanged)

func OnLanguageChanged(_lang) -> void:
	Apply()

func Apply() -> void:
	if _text == null:
		_text = gameObject
	var value := tr if LanguageManager.Current == GameLanguage.TR else en
	if not U.empty(value) and _text is UText:
		_text.text = value
