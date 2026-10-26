class_name Loc

static func T(en: String, tr: String) -> String:
	return tr if LanguageManager.Current == GameLanguage.TR else en

static func Pick(en, tr) -> String:
	if LanguageManager.Current == GameLanguage.TR and not U.empty(tr):
		return str(tr)
	return "" if en == null else str(en)
