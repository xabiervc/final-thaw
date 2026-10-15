class_name GamePalette
extends RefCounted
## State colours by ROLE, remapped for the colour-blind palettes chosen in Options. Every state that uses these
## colours also has a non-colour cue (a symbol, a word, a shape or a position), so colour is never the only signal.
##   ok      - available / stable / safe        (green, or blue under deutan/protan, teal under tritan)
##   warn    - attention / suspicious / pending (amber, or yellow/orange variants)
##   danger  - tripped / alert / locked         (red, or orange-red / magenta variants)
##   info    - scanning / Aster / neutral info  (cyan)
##   neutral - idle / off                       (dim grey)

const STANDARD := {
	"ok": Color(0.3, 1.0, 0.45),
	"warn": Color(1.0, 0.8, 0.25),
	"danger": Color(1.0, 0.18, 0.1),
	"info": Color(0.35, 1.0, 0.95),
	"neutral": Color(0.15, 0.17, 0.18),
}
const DEUTAN := {"ok": Color(0.15, 0.6, 1.0), "warn": Color(1.0, 0.82, 0.2), "danger": Color(1.0, 0.45, 0.05)}
const PROTAN := {"ok": Color(0.15, 0.62, 1.0), "warn": Color(1.0, 0.85, 0.3), "danger": Color(1.0, 0.55, 0.1)}
const TRITAN := {"ok": Color(0.1, 0.85, 0.75), "warn": Color(1.0, 0.55, 0.75), "danger": Color(0.9, 0.12, 0.5)}


static func color(role: String) -> Color:
	var base: Color = STANDARD.get(role, STANDARD["neutral"])
	match AccessibilityManager.colorblind_mode():
		1:
			return DEUTAN.get(role, base)
		2:
			return PROTAN.get(role, base)
		3:
			return TRITAN.get(role, base)
	return base


## The recovery unit's eye: idle reads warm amber in the standard palette (a working light, not a warning).
static func unit_color(role: String) -> Color:
	if role == "neutral":
		return Color(0.95, 0.75, 0.3) if AccessibilityManager.colorblind_mode() != 3 else Color(0.85, 0.85, 0.9)
	return color(role)
