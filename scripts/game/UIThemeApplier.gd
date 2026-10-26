class_name UIThemeApplier
extends Mono

enum Role { PanelBackground, PanelBorder, Header, Body, Muted, Accent, ButtonBackground, ButtonText, Surface, SurfaceLift, Slot, Hairline, Scrim, DialogueSurface }
var theme
var role := 0
var applyOnEnable := true

func _on_injected(_root: Node) -> void:
	Apply()

func OnEnable() -> void:
	if applyOnEnable:
		Apply()

func Apply() -> void:
	if theme == null:
		return
	var c := Resolve(role)
	var go = gameObject
	if go is UImage and go.has_graphic:
		go.color = c
		ApplySurfaceSprite(go)
	elif go is UText:
		go.color = c

func ApplySurfaceSprite(img) -> void:
	if img.type == UImage.Type.FILLED:
		return
	match role:
		Role.Surface, Role.SurfaceLift, Role.DialogueSurface:
			img.sprite = UISprites.Rounded(int(theme.radiusPanel))
			img.type = UImage.Type.SLICED
		Role.Slot:
			img.sprite = UISprites.Rounded(int(theme.radiusSlot))
			img.type = UImage.Type.SLICED
		Role.Hairline, Role.Scrim:
			img.sprite = UISprites.Solid()
			img.type = UImage.Type.SIMPLE

func Resolve(r: int) -> Color:
	var key := ["panelBackground", "panelBorder", "headerText", "bodyText", "mutedText", "accent", "buttonBackground", "buttonText", "panelBackground", "panelLift", "buttonBackground", "hairline", "shade", "dialogueSurface"]
	if r < 0 or r >= key.size():
		return Color.WHITE
	var v = theme.get(key[r])
	return v if v is Color else Color.WHITE
