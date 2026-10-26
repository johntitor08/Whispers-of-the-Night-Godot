class_name LanguageManager

const Key := "game_language"
static var _current := -1
static var OnLanguageChanged := UEvent.new()

static var Current: int:
	get:
		if _current < 0:
			_current = U.GetInt(Key, GameLanguage.EN)
		return _current

static func SetLanguage(lang: int) -> void:
	_current = lang
	U.SetInt(Key, lang)
	U.PrefsSave()
	OnLanguageChanged.Invoke(lang)

static func Toggle() -> void:
	SetLanguage(GameLanguage.TR if Current == GameLanguage.EN else GameLanguage.EN)
