class_name CreditsPanel
extends Mono

var panel
var buttonPanel
var titleText
var bodyText
var openButton
var closeButton

func Start() -> void:
	if openButton != null:
		openButton.onClick.AddListener(Open)
	if closeButton != null:
		closeButton.onClick.AddListener(Close)
	if panel != null:
		U.SetActive(panel, false)

func Update() -> void:
	if panel != null and panel.visible and U.GetKeyDown(KEY_ESCAPE):
		Close()

func Open() -> void:
	Refresh()
	if buttonPanel != null:
		U.SetActive(buttonPanel, false)
	U.SetActive(panel, true)

func Close() -> void:
	U.SetActive(panel, false)
	if buttonPanel != null:
		U.SetActive(buttonPanel, true)

func Refresh() -> void:
	if titleText != null:
		titleText.text = Loc.T("Credits", "Emeği Geçenler")
	if bodyText == null:
		return
	bodyText.text = Loc.T("<b>A game by noraStudios</b>\n\n<b>Music</b>\n\"Angevin\", \"Five Armies\", \"Lord of the Land\", \"Night Vigil\", \"Suonatore di Liuto\"\nKevin MacLeod (incompetech.com)\nLicensed under Creative Commons: By Attribution 4.0\ncreativecommons.org/licenses/by/4.0\n\n<b>Icons</b>\nLorc, Delapouite, Guard13007, Skoll, Lucas, Faithtoken and Caro Asercion — game-icons.net\nLicensed under CC BY 3.0 (creativecommons.org/licenses/by/3.0). Some icons recoloured or modified.\n\n<b>Fonts</b>\nArvo (Anton Koovit), Roboto Slab (Christian Robertson), Liberation Sans (Red Hat)\nSIL Open Font License 1.1 / Apache License 2.0\n\nMade with Godot Engine (godotengine.org, MIT).\n\nThank you for playing.", "<b>noraStudios oyunu</b>\n\n<b>Müzik</b>\n\"Angevin\", \"Five Armies\", \"Lord of the Land\", \"Night Vigil\", \"Suonatore di Liuto\"\nKevin MacLeod (incompetech.com)\nCreative Commons Atıf 4.0 lisansı ile\ncreativecommons.org/licenses/by/4.0\n\n<b>İkonlar</b>\nLorc, Delapouite, Guard13007, Skoll, Lucas, Faithtoken ve Caro Asercion — game-icons.net\nCC BY 3.0 lisansı ile (creativecommons.org/licenses/by/3.0). Bazı ikonlar yeniden renklendirildi ya da değiştirildi.\n\n<b>Fontlar</b>\nArvo (Anton Koovit), Roboto Slab (Christian Robertson), Liberation Sans (Red Hat)\nSIL Open Font License 1.1 / Apache License 2.0\n\nGodot Engine ile yapıldı (godotengine.org, MIT).\n\nOynadığın için teşekkürler.")
