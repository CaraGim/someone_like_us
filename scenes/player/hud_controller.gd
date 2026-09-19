extends CanvasLayer
class_name HudController

## Owns the player's HUD primitives and only ever reacts to signals — it
## never reaches out and pulls state from Player itself.

@onready var reticle: ColorRect = $Reticle
@onready var phone_panel: Control = $PhonePanel
@onready var prompt_label: Label = $PromptLabel

func set_focused(is_focused: bool) -> void:
	reticle.color = Color(0.2, 1.0, 0.4) if is_focused else Color(1, 1, 1, 0.6)

## Centers the reticle on screen_pos (e.g. the mouse cursor in Sandbox mode).
func set_reticle_screen_position(screen_pos: Vector2) -> void:
	reticle.position = screen_pos - reticle.size / 2.0

## Snaps the reticle back to true screen-center (Quest-stage / first-person).
func center_reticle() -> void:
	var viewport_size: Vector2 = reticle.get_viewport().get_visible_rect().size
	set_reticle_screen_position(viewport_size / 2.0)

func set_prompt(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = text != ""
	if text != "":
		prompt_label.reset_size() # so .size is correct immediately, not next idle frame

## screen_pos is the point in viewport pixels the label should hover just above.
func set_prompt_screen_position(screen_pos: Vector2) -> void:
	prompt_label.position = Vector2(
		screen_pos.x - prompt_label.size.x / 2.0,
		screen_pos.y - prompt_label.size.y - 12.0
	)

func set_phone_open(is_open: bool) -> void:
	phone_panel.visible = is_open
